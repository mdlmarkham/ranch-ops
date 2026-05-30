#!/usr/bin/env python3
"""Sync herd database aggregates to OHM knowledge graph.

Run daily or on heartbeat. Reads aggregate metrics from the herd
DuckDB and writes observations to OHM. This is a one-way sync:
Herd DB → OHM. OHM never writes individual animal records back.

Usage:
    python3 herd_to_ohm.py [--db /var/lib/ohm-ranch/herd.duckdb] [--dry-run]
"""

import argparse
import json
from datetime import date, datetime
from pathlib import Path

import duckdb

# OHM connection
OHM_URL = "http://127.0.0.1:8711"
WAYLON_TOKEN = "ranch-waylon-u0-REPLACE_WITH_SECURE_TOKEN"

def query_herd(db_path, sql, params=None):
    """Execute a query against the herd DuckDB."""
    con = duckdb.connect(db_path, read_only=True)
    try:
        if params:
            result = con.execute(sql, params).fetchall()
        else:
            result = con.execute(sql).fetchall()
        return result
    finally:
        con.close()

def get_herd_stats(db_path):
    """Get aggregate herd statistics."""
    stats = {}
    
    # Total active animals by purpose
    rows = query_herd(db_path, """
        SELECT purpose, COUNT(*) as count
        FROM animals
        WHERE status = 'active'
        GROUP BY purpose
    """)
    stats['animals_by_purpose'] = {r[0]: r[1] for r in rows}
    stats['total_active'] = sum(stats['animals_by_purpose'].values())
    
    # Average BCS (most recent per animal)
    rows = query_herd(db_path, """
        WITH latest_bcs AS (
            SELECT animal_id, bcs,
                   ROW_NUMBER() OVER (PARTITION BY animal_id ORDER BY bcs_date DESC) as rn
            FROM animal_bcs
        )
        SELECT AVG(bcs) as avg_bcs, COUNT(*) as n
        FROM latest_bcs
        WHERE rn = 1
    """)
    if rows and rows[0][1] > 0:
        stats['avg_bcs'] = round(rows[0][0], 2)
        stats['bcs_count'] = rows[0][1]
    
    # Cows below BCS 4.5
    rows = query_herd(db_path, """
        WITH latest_bcs AS (
            SELECT animal_id, bcs,
                   ROW_NUMBER() OVER (PARTITION BY animal_id ORDER BY bcs_date DESC) as rn
            FROM animal_bcs
        )
        SELECT COUNT(*) as thin_count
        FROM latest_bcs lb
        JOIN animals a ON a.id = lb.animal_id
        WHERE lb.rn = 1 AND lb.bcs < 4.5 AND a.status = 'active' AND a.sex = 'F'
    """)
    stats['thin_cows'] = rows[0][0] if rows else 0
    
    # Open cows past 82 days post-calving
    rows = query_herd(db_path, """
        SELECT COUNT(*) as open_count
        FROM animals a
        LEFT JOIN animal_breeding ab ON a.id = ab.animal_id
        LEFT JOIN animal_calvings ac ON a.id = ac.dam_id
        WHERE a.status = 'active'
          AND a.sex = 'F'
          AND a.purpose = 'brood'
          AND (ab.preg_result IS NULL OR ab.preg_result = 'negative' OR ab.preg_result = 'open')
          AND ac.calving_date IS NOT NULL
          AND CURRENT_DATE - ac.calving_date > 82
    """)
    stats['open_past_82'] = rows[0][0] if rows else 0
    
    # Calves born this season
    year = date.today().year
    rows = query_herd(db_path, """
        SELECT COUNT(*) as calf_count
        FROM animal_calvings
        WHERE EXTRACT(YEAR FROM calving_date) = ?
    """, [year])
    stats['calves_born_this_year'] = rows[0][0] if rows else 0
    
    # Average weaning weight (adjusted 205-day)
    rows = query_herd(db_path, """
        WITH weaning_data AS (
            SELECT aw.animal_id, aw.weight_lbs, aw.weight_date,
                   a.birth_date,
                   (aw.weight_date - a.birth_date) as age_days
            FROM animal_weights aw
            JOIN animals a ON a.id = aw.animal_id
            WHERE age_days BETWEEN 180 AND 230
        )
        SELECT AVG(weight_lbs) as avg_wean_wt, COUNT(*) as n
        FROM weaning_data
    """)
    if rows and rows[0][1] > 0:
        stats['avg_weaning_weight'] = round(rows[0][0], 1)
        stats['weaning_count'] = rows[0][1]
    
    # Vaccination compliance (animals with due vaccines overdue)
    rows = query_herd(db_path, """
        SELECT COUNT(*) as overdue_count
        FROM animal_vaccinations
        WHERE next_due IS NOT NULL AND next_due < CURRENT_DATE
    """)
    stats['overdue_vaccinations'] = rows[0][0] if rows else 0
    
    # Mortality this year
    rows = query_herd(db_path, """
        SELECT COUNT(*) as deaths
        FROM animal_lifecycle
        WHERE event_type IN ('died', 'dead')
          AND EXTRACT(YEAR FROM event_date) = ?
    """, [year])
    stats['deaths_this_year'] = rows[0][0] if rows else 0
    
    return stats

def write_ohm_observations(stats, dry_run=False):
    """Write aggregate observations to OHM."""
    import requests
    
    headers = {"Authorization": f"Bearer {WAYLON_TOKEN}", "Content-Type": "application/json"}
    today = date.today().isoformat()
    total = stats.get('total_active', 0)
    
    observations = []
    
    # Herd average BCS
    if 'avg_bcs' in stats:
        observations.append({
            "node_id": "ranch-herd-bcs-average",
            "obs_type": "measurement",
            "value": stats['avg_bcs'],
            "sigma": 0.2,
            "source": "waylon_herd_sync",
            "notes": f"Herd average BCS {today}. N={stats['bcs_count']}. Target 5.0-6.0."
        })
    
    # Thin cow alert
    thin = stats.get('thin_cows', 0)
    brood_count = stats.get('animals_by_purpose', {}).get('brood', 0)
    if brood_count > 0 and thin > 0:
        thin_pct = thin / brood_count
        if thin_pct > 0.15:
            observations.append({
                "node_id": "concept-ranch-field",
                "obs_type": "assessment",
                "value": round(0.5 + thin_pct, 2),  # Scale: 0.5 base + actual pct
                "sigma": 0.1,
                "source": "waylon_herd_sync",
                "notes": f"WARNING: {thin}/{brood_count} ({thin_pct:.0%}) cows BCS <4.5. Supplementation needed."
            })
    
    # Open cows alert
    open_cows = stats.get('open_past_82', 0)
    if open_cows > 0:
        observations.append({
            "node_id": "concept-ranch-reproduction",
            "obs_type": "assessment",
            "value": min(0.9, 0.3 + (open_cows * 0.05)),
            "sigma": 0.1,
            "source": "waylon_herd_sync",
            "notes": f"{open_cows} cows open past 82 days postpartum. Breeding audit recommended."
        })
    
    # Calves born this year
    calves = stats.get('calves_born_this_year', 0)
    if calves > 0:
        observations.append({
            "node_id": "ranch-calf-crop-pct",
            "obs_type": "measurement",
            "value": calves,
            "sigma": 0,
            "source": "waylon_herd_sync",
            "notes": f"Calves born {date.today().year}: {calves}. Running calf crop tracking."
        })
    
    # Average weaning weight
    if 'avg_weaning_weight' in stats:
        observations.append({
            "node_id": "ranch-avg-weaning-weight",
            "obs_type": "measurement",
            "value": stats['avg_weaning_weight'],
            "sigma": 15.0,
            "source": "waylon_herd_sync",
            "notes": f"Avg weaning weight {today}. N={stats['weaning_count']}. Target 450-550 lbs."
        })
    
    # Overdue vaccinations
    overdue = stats.get('overdue_vaccinations', 0)
    if overdue > 0:
        observations.append({
            "node_id": "concept-ranch-health",
            "obs_type": "assessment",
            "value": min(0.9, 0.3 + (overdue * 0.1)),
            "sigma": 0.1,
            "source": "waylon_herd_sync",
            "notes": f"WARNING: {overdue} vaccinations overdue. Compliance gap."
        })
    
    # Write to OHM
    for obs in observations:
        if dry_run:
            print(f"  [DRY RUN] {obs['node_id']}: {obs['value']} — {obs['notes']}")
        else:
            try:
                r = requests.post(
                    f"{OHM_URL}/observations",
                    headers=headers,
                    json=obs,
                    timeout=10
                )
                status = "✓" if r.status_code < 300 else f"✗ {r.status_code}"
                print(f"  {status} {obs['node_id']}: {obs['value']}")
            except Exception as e:
                print(f"  ✗ {obs['node_id']}: {e}")
    
    return len(observations)

def main():
    parser = argparse.ArgumentParser(description="Sync herd DB aggregates to OHM")
    parser.add_argument("--db", default="/var/lib/ohm-ranch/herd.duckdb",
                        help="Path to herd DuckDB file")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print observations without writing to OHM")
    args = parser.parse_args()
    
    if not Path(args.db).exists():
        print(f"Herd database not found at {args.db}. Initialize with schema.sql first.")
        return
    
    print("Syncing herd statistics to OHM...")
    stats = get_herd_stats(args.db)
    
    print(f"\nHerd Summary:")
    print(f"  Active animals: {stats.get('total_active', 0)}")
    print(f"  Average BCS: {stats.get('avg_bcs', 'N/A')}")
    print(f"  Thin cows (<4.5): {stats.get('thin_cows', 0)}")
    print(f"  Open >82 days: {stats.get('open_past_82', 0)}")
    print(f"  Calves born this year: {stats.get('calves_born_this_year', 0)}")
    print(f"  Avg weaning weight: {stats.get('avg_weaning_weight', 'N/A')} lbs")
    print(f"  Overdue vaccinations: {stats.get('overdue_vaccinations', 0)}")
    print(f"  Deaths this year: {stats.get('deaths_this_year', 0)}")
    
    n = write_ohm_observations(stats, dry_run=args.dry_run)
    print(f"\nWrote {n} observations to OHM.")

if __name__ == "__main__":
    main()