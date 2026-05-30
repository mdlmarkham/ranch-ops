# Herd Database Queries

## Purpose

The Herd DB is your source of truth for individual animal records — weights, BCS, vaccinations, breeding, calving, movements, and lifecycle events. OHM gets *aggregates* (herd averages, alerts, patterns). The Herd DB gets *individuals* (which cow, which calf, which pasture).

**Rule:** If your question starts with "which," "how many," or "when did" a specific animal — query the Herd DB. If it starts with "why" or "what should we" — that's OHM territory.

## Connection

```python
import duckdb

HERD_DB = "/var/lib/ohm-ranch/herd.duckdb"

def query_herd(sql, params=None):
    """Read-only query against the herd database."""
    con = duckdb.connect(HERD_DB, read_only=True)
    try:
        if params:
            result = con.execute(sql, params).fetchall()
            columns = [desc[0] for desc in con.description]
        else:
            result = con.execute(sql).fetchall()
            columns = [desc[0] for desc in con.description]
        return [dict(zip(columns, row)) for row in result]
    finally:
        con.close()
```

Or from the command line:

```bash
duckdb /var/lib/ohm-ranch/herd.duckdb -readonly -c "SELECT * FROM animals WHERE status='active'"
```

## Common Queries by Agent

### Clint (Livestock Manager) — Most Frequent User

```sql
-- Which cows are open past 82 days?
SELECT a.tag, a.breed, ab.bred_date, ab.preg_result, ab.preg_check_date,
       CURRENT_DATE - ac.calving_date AS days_postpartum
FROM animals a
LEFT JOIN animal_breeding ab ON a.id = ab.animal_id
LEFT JOIN animal_calvings ac ON a.id = ac.dam_id
WHERE a.status = 'active' AND a.sex = 'F' AND a.purpose = 'brood'
  AND (ab.preg_result IS NULL OR ab.preg_result IN ('negative', 'open'))
  AND ac.calving_date IS NOT NULL
  AND CURRENT_DATE - ac.calving_date > 82
ORDER BY days_postpartum DESC;

-- Which cows are due to calve in the next 30 days?
SELECT a.tag, ac.due_date, a.current_pasture,
       (ac.due_date - CURRENT_DATE) AS days_until_due
FROM animals a
JOIN animal_breeding ab ON a.id = ab.animal_id
LEFT JOIN animal_calvings ac ON a.id = ac.dam_id
WHERE a.status = 'active' AND ab.preg_result = 'positive'
  AND ac.due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 30
ORDER BY ac.due_date;

-- Herd BCS summary (most recent per cow)
WITH latest_bcs AS (
    SELECT animal_id, bcs, bcs_date,
           ROW_NUMBER() OVER (PARTITION BY animal_id ORDER BY bcs_date DESC) as rn
    FROM animal_bcs
)
SELECT a.tag, a.purpose, lb.bcs, lb.bcs_date, a.current_pasture
FROM animals a
JOIN latest_bcs lb ON a.id = lb.animal_id AND lb.rn = 1
WHERE a.status = 'active' AND a.sex = 'F'
ORDER BY lb.bcs ASC;

-- Cows below BCS threshold (< 4.5)
WITH latest_bcs AS (
    SELECT animal_id, bcs,
           ROW_NUMBER() OVER (PARTITION BY animal_id ORDER BY bcs_date DESC) as rn
    FROM animal_bcs
)
SELECT a.tag, lb.bcs, a.current_pasture
FROM animals a
JOIN latest_bcs lb ON a.id = lb.animal_id AND lb.rn = 1
WHERE a.status = 'active' AND a.sex = 'F' AND lb.bcs < 4.5
ORDER BY lb.bcs ASC;

-- Vaccinations due in the next 14 days
SELECT a.tag, av.vaccine_name, av.next_due, a.current_pasture
FROM animal_vaccinations av
JOIN animals a ON a.id = av.animal_id
WHERE a.status = 'active'
  AND av.next_due BETWEEN CURRENT_DATE AND CURRENT_DATE + 14
ORDER BY av.next_due;

-- Vaccinations overdue
SELECT a.tag, av.vaccine_name, av.next_due,
       CURRENT_DATE - av.next_due AS days_overdue
FROM animal_vaccinations av
JOIN animals a ON a.id = av.animal_id
WHERE a.status = 'active'
  AND av.next_due < CURRENT_DATE
ORDER BY days_overdue DESC;

-- Calving ease summary for this season
SELECT calving_ease, COUNT(*) as count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as pct
FROM animal_calvings
WHERE EXTRACT(YEAR FROM calving_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY calving_ease
ORDER BY count DESC;

-- Calf death loss by cause this year
SELECT calf_status, COUNT(*) as count
FROM animal_calvings
WHERE EXTRACT(YEAR FROM calving_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY calf_status;
```

### Slim (Field Scout)

```sql
-- Animals in a specific pasture
SELECT tag, breed, sex, purpose, status
FROM animals
WHERE current_pasture = 'North Pasture' AND status = 'active'
ORDER BY purpose, tag;

-- Recent health events (last 7 days)
SELECT a.tag, ah.event_date, ah.event_type, ah.diagnosis, ah.treatment
FROM animal_health ah
JOIN animals a ON a.id = ah.animal_id
WHERE ah.event_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY ah.event_date DESC;

-- Recent movements (last 14 days)
SELECT a.tag, am.move_date, am.from_pasture, am.to_pasture, am.reason
FROM animal_movements am
JOIN animals a ON a.id = am.animal_id
WHERE am.move_date >= CURRENT_DATE - INTERVAL '14 days'
ORDER BY am.move_date DESC;

-- BCS trend for a specific cow
SELECT bcs_date, bcs
FROM animal_bcs
WHERE animal_id = (SELECT id FROM animals WHERE tag = '0083')
ORDER BY bcs_date;

-- Weight gain for calves (ADG calculation)
SELECT a.tag, aw.weight_date, aw.weight_lbs,
       LAG(aw.weight_lbs) OVER (PARTITION BY a.id ORDER BY aw.weight_date) as prev_weight,
       LAG(aw.weight_date) OVER (PARTITION BY a.id ORDER BY aw.weight_date) as prev_date,
       ROUND((aw.weight_lbs - LAG(aw.weight_lbs) OVER (PARTITION BY a.id ORDER BY aw.weight_date))
             / (aw.weight_date - LAG(aw.weight_date) OVER (PARTITION BY a.id ORDER BY aw.weight_date)), 2) as adg
FROM animal_weights aw
JOIN animals a ON a.id = aw.animal_id
WHERE a.status = 'active' AND a.purpose = 'feeder'
ORDER BY a.tag, aw.weight_date;
```

### Roy (Supply Chain)

```sql
-- Herd count by purpose (for feed/med ordering)
SELECT purpose, COUNT(*) as count
FROM animals
WHERE status = 'active'
GROUP BY purpose
ORDER BY count DESC;

-- Total breeding females (for bull ratio and feed planning)
SELECT COUNT(*) as brood_cows
FROM animals
WHERE status = 'active' AND sex = 'F' AND purpose = 'brood';

-- Health treatment costs this month
SELECT ah.event_type, COUNT(*) as events, SUM(ah.cost) as total_cost
FROM animal_health ah
WHERE EXTRACT(YEAR FROM ah.event_date) = EXTRACT(YEAR FROM CURRENT_DATE)
  AND EXTRACT(MONTH FROM ah.event_date) = EXTRACT(MONTH FROM CURRENT_DATE)
GROUP BY ah.event_type
ORDER BY total_cost DESC;
```

### Belle (Finance)

```sql
-- Cost per head this year (health + purchase costs)
SELECT
    (SELECT COALESCE(SUM(cost), 0) FROM animal_health
     WHERE EXTRACT(YEAR FROM event_date) = EXTRACT(YEAR FROM CURRENT_DATE))
    +
    (SELECT COALESCE(SUM(price), 0) FROM animal_lifecycle
     WHERE event_type = 'purchased'
     AND EXTRACT(YEAR FROM event_date) = EXTRACT(YEAR FROM CURRENT_DATE))
    AS total_health_purchase_cost;

-- Revenue from sales this year
SELECT SUM(price) as total_sales, COUNT(*) as head_sold
FROM animal_lifecycle
WHERE event_type = 'sold'
  AND EXTRACT(YEAR FROM event_date) = EXTRACT(YEAR FROM CURRENT_DATE);

-- Average weaning weight by sire (genetic value analysis)
SELECT a_sire.tag AS sire_tag, ROUND(AVG(aw.weight_lbs), 1) AS avg_wean_weight, COUNT(*) AS n
FROM animals a
JOIN animal_calvings ac ON a.id = ac.calf_id
JOIN animals a_sire ON ac.dam_id = a_sire.id  -- Note: this is dam, need sire from breeding
JOIN animal_weights aw ON a.id = aw.animal_id
WHERE (aw.weight_date - a.birth_date) BETWEEN 180 AND 230
  AND a.status = 'active'
GROUP BY a_sire.tag
ORDER BY avg_wean_weight DESC;

-- Culling summary this year
SELECT reason, COUNT(*) as count, AVG(price) as avg_price
FROM animal_lifecycle
WHERE event_type = 'culled'
  AND EXTRACT(YEAR FROM event_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY reason;
```

### Virgil (HR & Labor)

```sql
-- Treatment withdrawal times (for slaughter scheduling)
SELECT a.tag, ah.medication, ah.dosage, ah.withdrawal_days,
       ah.event_date + INTERVAL (ah.withdrawal_days || ' days') AS clear_date
FROM animal_health ah
JOIN animals a ON a.id = ah.animal_id
WHERE ah.withdrawal_days IS NOT NULL
  AND ah.event_date + INTERVAL (ah.withdrawal_days || ' days') > CURRENT_DATE
ORDER BY clear_date;

-- Vaccination compliance rate
SELECT
    ROUND(COUNT(CASE WHEN av.next_due >= CURRENT_DATE THEN 1 END) * 100.0
          / NULLIF(COUNT(*), 0), 1) AS compliance_pct
FROM animal_vaccinations av
JOIN animals a ON a.id = av.animal_id
WHERE a.status = 'active';
```

### Waylon (Operations Lead)

```sql
-- Full herd inventory dashboard
SELECT purpose, sex, COUNT(*) as count,
       ROUND(AVG((SELECT bcs FROM animal_bcs WHERE animal_id = a.id ORDER BY bcs_date DESC LIMIT 1)), 1) AS avg_bcs
FROM animals a
WHERE status = 'active'
GROUP BY purpose, sex
ORDER BY purpose, sex;

-- Calving progress this season
SELECT
    COUNT(*) AS total_calvings,
    COUNT(CASE WHEN calf_status = 'alive' THEN 1 END) AS live_births,
    COUNT(CASE WHEN calf_status IN ('stillborn', 'died') THEN 1 END) AS losses,
    ROUND(COUNT(CASE WHEN calf_status = 'alive' THEN 1 END) * 100.0
          / NULLIF(COUNT(*), 0), 1) AS live_pct,
    ROUND(AVG(birth_weight_lbs), 1) AS avg_birth_weight,
    COUNT(CASE WHEN calving_ease = 'unassisted' THEN 1 END) AS unassisted,
    COUNT(CASE WHEN calving_ease IN ('hard pull', 'c-section') THEN 1 END) AS assisted
FROM animal_calvings
WHERE EXTRACT(YEAR FROM calving_date) = EXTRACT(YEAR FROM CURRENT_DATE);

-- Conception rate by breeding method
SELECT ab.method, COUNT(*) AS total_bred,
       COUNT(CASE WHEN ab.preg_result = 'positive' THEN 1 END) AS confirmed_preg,
       ROUND(COUNT(CASE WHEN ab.preg_result = 'positive' THEN 1 END) * 100.0
             / NULLIF(COUNT(*), 0), 1) AS conception_pct
FROM animal_breeding ab
WHERE ab.season = EXTRACT(YEAR FROM CURRENT_DATE)::text || '-spring'
GROUP BY ab.method;

-- Animals that need attention (combined alert)
SELECT 'Thin Cow' AS alert_type, a.tag, a.current_pasture,
       CAST(lb.bcs AS TEXT) AS detail, NULL::DATE AS due_date
FROM animals a
JOIN (SELECT animal_id, bcs, ROW_NUMBER() OVER (PARTITION BY animal_id ORDER BY bcs_date DESC) AS rn
      FROM animal_bcs) lb ON a.id = lb.animal_id AND lb.rn = 1
WHERE a.status = 'active' AND a.sex = 'F' AND lb.bcs < 4.5

UNION ALL

SELECT 'Overdue Vaccination', a.tag, a.current_pasture,
       av.vaccine_name, av.next_due
FROM animal_vaccinations av
JOIN animals a ON a.id = av.animal_id
WHERE a.status = 'active' AND av.next_due < CURRENT_DATE

UNION ALL

SELECT 'Open >82 Days', a.tag, a.current_pasture,
       CAST((CURRENT_DATE - ac.calving_date) AS TEXT), NULL::DATE
FROM animals a
LEFT JOIN animal_calvings ac ON a.id = ac.dam_id
WHERE a.status = 'active' AND a.sex = 'F' AND a.purpose = 'brood'
  AND ac.calving_date IS NOT NULL
  AND CURRENT_DATE - ac.calving_date > 82
  AND a.id NOT IN (SELECT animal_id FROM animal_breeding WHERE preg_result = 'positive')

ORDER BY alert_type, tag;
```

## Writing to the Herd DB

**Only Clint and Waylon write individual animal records.** Other agents read and aggregate.

```python
import duckdb

HERD_DB = "/var/lib/ohm-ranch/herd.duckdb"

def write_herd(sql, params=None):
    """Write to the herd database. Use for new records and updates."""
    con = duckdb.connect(HERD_DB, read_only=False)
    try:
        if params:
            con.execute(sql, params)
        else:
            con.execute(sql)
        con.commit()
    finally:
        con.close()

# Examples:

# Record a new BCS score
write_herd("""
    INSERT INTO animal_bcs (animal_id, bcs_date, bcs, observer)
    VALUES ((SELECT id FROM animals WHERE tag = ?), ?, ?, ?)
""", ['0083', '2026-05-30', 5.5, 'slim'])

# Record a weight
write_herd("""
    INSERT INTO animal_weights (animal_id, weight_date, weight_lbs, method)
    VALUES ((SELECT id FROM animals WHERE tag = ?), ?, ?, ?)
""", ['0247', '2026-05-30', 485.0, 'scale'])

# Record a vaccination
write_herd("""
    INSERT INTO animal_vaccinations (animal_id, vaccine_date, vaccine_name, vaccine_type, route, administrator, next_due)
    VALUES ((SELECT id FROM animals WHERE tag = ?), ?, ?, ?, ?, ?, ?)
""", ['0083', '2026-05-30', '7-way Clostridial', 'killed', 'SQ', 'Dr. Martinez', '2027-05-30'])

# Record a calving
write_herd("""
    INSERT INTO animal_calvings (dam_id, calf_id, calving_date, calving_ease, birth_weight_lbs, calf_sex, calf_status)
    VALUES ((SELECT id FROM animals WHERE tag = ?),
            (SELECT id FROM animals WHERE tag = ?),
            ?, ?, ?, ?, ?)
""", ['0083', '0312', '2026-03-15', 'unassisted', 82.0, 'M', 'alive'])

# Move an animal to a new pasture
write_herd("""
    INSERT INTO animal_movements (animal_id, move_date, from_pasture, to_pasture, reason, moved_by)
    VALUES ((SELECT id FROM animals WHERE tag = ?), ?, ?, ?, ?, ?)
""", ['0083', '2026-05-30', 'North Pasture', 'Creek Bottom', 'rotation', 'slim'])

# Update current pasture on the animal record
write_herd("""
    UPDATE animals SET current_pasture = ?
    WHERE tag = ?
""", ['Creek Bottom', '0083'])
```

## Decision Framework: Herd DB vs. OHM

| Question Type | Database | Example |
|---------------|----------|---------|
| "Which cow?" | Herd DB | "Which cows have BCS < 4.5?" |
| "How many?" | Herd DB | "How many calves born this week?" |
| "When did?" | Herd DB | "When was Cow #83 last vaccinated?" |
| "What's the average?" | Herd DB → OHM | "Average weaning weight" (compute in DB, sync to OHM) |
| "Why?" | OHM | "Why is BCS declining across the herd?" |
| "What should?" | OHM | "Should we cull or feed through?" |
| "What connects?" | OHM | "How does drought × feed cost × BCS connect?" |

## Schema Quick Reference

| Table | What It Holds | Key Fields |
|-------|---------------|------------|
| `animals` | Identity & current status | tag, breed, sex, birth_date, status, current_pasture |
| `animal_weights` | Growth tracking | animal_id, weight_date, weight_lbs, method |
| `animal_bcs` | Body condition history | animal_id, bcs_date, bcs (1.0-9.0), observer |
| `animal_health` | Medical records | animal_id, event_date, diagnosis, treatment, medication, cost |
| `animal_vaccinations` | Shot records | animal_id, vaccine_date, vaccine_name, next_due |
| `animal_breeding` | Reproduction | animal_id, season, bred_date, method, sire, preg_result, due_date |
| `animal_calvings` | Calving events | dam_id, calf_id, calving_date, calving_ease, birth_weight |
| `animal_movements` | Pasture moves | animal_id, move_date, from_pasture, to_pasture |
| `animal_lifecycle` | Cradle-to-grave audit | animal_id, event_date, event_type, price, reason |

Full schema: `shared/herd/schema.sql`
Sync script: `shared/herd/herd_to_ohm.py`
Architecture decision: `shared/herd-tracking-architecture.md`