#!/usr/bin/env python3
"""Seed the Ranch OHM knowledge graph on a fresh instance.

Usage:
    python3 seed-ranch-ohm.py [--port PORT] [--token TOKEN]

Defaults:
    PORT: 8711
    TOKEN: ranch-waylon-u0-REPLACE_WITH_SECURE_TOKEN (override with generated token)
"""

import argparse
import json
import sys
import requests

def main():
    parser = argparse.ArgumentParser(description="Seed Ranch OHM knowledge graph")
    parser.add_argument("--port", type=int, default=8711, help="OHM daemon port")
    parser.add_argument("--token", required=True, help="Waylon token for authentication")
    parser.add_argument("--host", default="127.0.0.1", help="OHM daemon host")
    args = parser.parse_args()

    base = f"http://{args.host}:{args.port}"
    headers = {"Authorization": f"Bearer {args.token}", "Content-Type": "application/json"}

    # Test connectivity
    try:
        r = requests.get(f"{base}/stats", headers=headers, timeout=5)
        r.raise_for_status()
        print(f"Connected to OHM at {base}")
        stats = r.json()
        print(f"  Existing nodes: {stats.get('total_nodes', '?')}")
    except Exception as e:
        print(f"ERROR: Cannot connect to OHM at {base}: {e}")
        sys.exit(1)

    # Create hub node
    nodes = [
        {"id": "concept-ranch-operations-hub", "label": "Ranch Operations Hub", "type": "concept", "tags": ["ranch-operations", "pilot", "ranch"]},
        {"id": "concept-ranch-livestock", "label": "Livestock Management", "type": "concept", "tags": ["ranch-livestock", "ranch"]},
        {"id": "concept-ranch-supply", "label": "Supply Chain & Purchasing", "type": "concept", "tags": ["ranch-supply", "ranch"]},
        {"id": "concept-ranch-inventory", "label": "Inventory & Asset Tracking", "type": "concept", "tags": ["ranch-inventory", "ranch"]},
        {"id": "concept-ranch-hr", "label": "HR & Labor Management", "type": "concept", "tags": ["ranch-hr", "ranch"]},
        {"id": "concept-ranch-finance", "label": "Finance & Accounting", "type": "concept", "tags": ["ranch-finance", "ranch"]},
        {"id": "concept-ranch-field", "label": "Field Operations & Scouting", "type": "concept", "tags": ["ranch-field", "ranch"]},
    ]

    print("\nCreating nodes...")
    for node in nodes:
        r = requests.post(f"{base}/node", headers=headers, json=node)
        created = r.json().get("created", False) if r.status_code < 300 else False
        print(f"  {'✓' if created else '→'} {node['label']} ({node['id']})")

    # Create edges
    edges = [
        {"from": "concept-ranch-livestock", "to": "concept-ranch-operations-hub", "type": "PART_OF", "layer": "L1", "confidence": 1.0},
        {"from": "concept-ranch-supply", "to": "concept-ranch-operations-hub", "type": "PART_OF", "layer": "L1", "confidence": 1.0},
        {"from": "concept-ranch-inventory", "to": "concept-ranch-operations-hub", "type": "PART_OF", "layer": "L1", "confidence": 1.0},
        {"from": "concept-ranch-hr", "to": "concept-ranch-operations-hub", "type": "PART_OF", "layer": "L1", "confidence": 1.0},
        {"from": "concept-ranch-finance", "to": "concept-ranch-operations-hub", "type": "PART_OF", "layer": "L1", "confidence": 1.0},
        {"from": "concept-ranch-field", "to": "concept-ranch-operations-hub", "type": "PART_OF", "layer": "L1", "confidence": 1.0},
    ]

    print("\nCreating edges...")
    for edge in edges:
        r = requests.post(f"{base}/edge", headers=headers, json=edge)
        ok = r.status_code < 300
        print(f"  {'✓' if ok else '✗'} {edge['from']} → {edge['to']} ({edge['type']})")

    # Verify
    print("\nVerifying...")
    r = requests.get(f"{base}/stats", headers=headers, timeout=5)
    stats = r.json()
    print(f"  Total nodes: {stats.get('total_nodes', '?')}")
    print(f"  Total edges: {stats.get('total_edges', '?')}")

    print("\n✓ Ranch OHM seeded successfully!")

if __name__ == "__main__":
    main()