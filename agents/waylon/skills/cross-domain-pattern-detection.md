# Cross-Domain Pattern Detection

## Purpose

The core value of OHM on a ranch: when observations from different domains land in the same graph, patterns emerge that no single agent would see alone. This skill teaches Waylon (and any coordinating agent) to find those patterns, synthesize them, and surface decisions that cross domain boundaries.

## Why This Matters

Clint sees a BCS drop. Roy sees a feed price spike. Slim sees drought conditions on Section 3. Belle sees a cash flow squeeze. **None of them see the full picture.** Waylon's job is to query the graph, find the cluster, and synthesize: "Drought is pushing feed costs up while reducing pasture quality, which is dropping BCS, which will push costs higher and squeeze cash flow before fall calf sales."

That synthesis doesn't exist in any single domain. It only emerges from the graph.

## The Detection Cycle

### 1. Listen (Every Heartbeat)

```python
from ohm.sdk import connect_http
g = connect_http("http://127.0.0.1:8711", actor="waylon",
                 token="ranch-…N")

# What's new in the last 6 hours?
recent = g.listen(since="2026-05-29T06:00:00")
for obs in recent.get("observations", []):
    print(f"  [{obs['source']}] {obs['node_id']}: {obs['notes']}")
```

### 2. Find Clusters

Look for observations that share:
- **Tags** (same `ranch-*` domain tags)
- **Time** (observations within the same 24-48 hour window)
- **Implied causality** (weather → pasture → livestock → feed cost → cash flow)

```python
# Find nodes that share tags with recent observations
suggestions = g.suggest(method="shared_tags", min_shared=2)
for s in suggestions:
    print(f"  {s['from']} ↔ {s['to']} (shared: {s['shared_tags']})")
```

### 3. Synthesize

When 3+ observations form a cluster, write a synthesis:

```python
g.write_synthesis(
    cluster_ids=["concept-ranch-livestock", "concept-ranch-supply", "concept-ranch-field"],
    label="Drought-Feed-BCS Cascade",
    content="Drought conditions on Section 3 are reducing pasture quality while simultaneously driving up hay prices ($245/ton spot, up $15/week). BCS dropped to 5.2 average with 2 head below 4.0. If this continues for 2+ weeks, supplemental feed costs will spike further, compressing margins before fall calf sales.",
    edge_type="CAUSES",
    confidence=0.82,
    provenance="ranch_operations",
    tags=["drought", "feed-cost", "bcs", "cash-flow", "cascade"]
)
```

### 4. Challenge

When another agent's synthesis doesn't match your ground truth:

```python
g.challenge(
    edge_id="edge-id-here",
    reason="BCS drop may be seasonal, not drought-related. Need 2 more weeks of data to confirm causation.",
    confidence=0.6
)
```

## Pattern Catalog

These are the cross-domain patterns most likely to emerge on a ranch. Watch for them:

### Pattern 1: Drought Cascade
**Domains:** Field → Supply → Livestock → Finance
**Trigger:** Slim reports drought conditions (pasture score < 4)
**Cascade:** Pasture degrades → Roy reports hay prices rising → Clint reports BCS dropping → Belle reports cash flow squeeze
**Decision:** Lock in hay contract now (before prices rise further), move herd to better pasture, plan supplemental feed budget

### Pattern 2: Calving Season Labor Squeeze
**Domains:** Livestock → HR → Finance
**Trigger:** Clint reports calving approaching (30 days out)
**Cascade:** Virgil reports labor shortage for night watches → Belle reports overtime costs rising
**Decision:** Pre-position seasonal labor, adjust budget for overtime

### Pattern 3: Equipment Failure Ripple
**Domains:** Inventory → Livestock → Supply → Finance
**Trigger:** Magnus reports sprayer down
**Cascade:** Clint can't apply pasture treatment → Roy can't source replacement parts quickly → Belle sees maintenance budget exceeded
**Decision:** Priority repair vs. defer pasture treatment, rental equipment option

### Pattern 4: Market Timing Window
**Domains:** Supply → Finance → Livestock
**Trigger:** Roy reports local auction prices spiking or Belle sees CME futures shift
**Cascade:** Belle recalculates breakeven → Clint assesses if calves are at shipping weight
**Decision:** Sell now at premium or hold for seasonal rally

### Pattern 5: Regulatory Change Impact
**Domains:** HR → Finance → Livestock
**Trigger:** Virgil reports new regulation (H-2A change, OSHA update, tax code change)
**Cascade:** Belle recalculates labor costs → Clint adjusts protocols to comply
**Decision:** Budget adjustment, compliance timeline

## Synthesis Quality Checklist

Before writing a synthesis, verify:
- [ ] 3+ observations from 2+ domains (otherwise it's a single-domain insight, not a synthesis)
- [ ] Causal chain is clear (A causes B causes C)
- [ ] Confidence is honest (0.7-0.9 is typical, not 0.99)
- [ ] Decision implication is stated (what should the human do about this?)
- [ ] Tags connect to existing nodes (not orphaned)

## Query Patterns

### Daily Briefing Query
```python
# Get all observations from last 24 hours, grouped by domain
for domain in ["concept-ranch-livestock", "concept-ranch-supply",
               "concept-ranch-inventory", "concept-ranch-hr",
               "concept-ranch-finance", "concept-ranch-field"]:
    obs = g.neighborhood(domain, depth=1)
    recent = [o for o in obs.get("observations", [])
              if o.get("timestamp", "") > yesterday]
    if recent:
        print(f"\n{domain}:")
        for o in recent:
            print(f"  [{o['source']}] {o['notes']}")
```

### Pattern Discovery Query
```python
# Find nodes that should be connected but aren't
orphans = g.orphans()
if orphans:
    print(f"  {len(orphans)} unconnected nodes — connect them")

suggestions = g.suggest(method="shared_tags", min_shared=2)
for s in suggestions[:5]:
    print(f"  {s['from']} ↔ {s['to']} ({s['shared_tags']})")
```

### Cross-Domain Impact Query
```python
# Given an observation in one domain, trace its impact
def trace_impact(g, node_id, depth=2):
    """Follow edges from a node to find cascading effects."""
    neighborhood = g.neighborhood(node_id, depth=depth)
    impacts = []
    for edge in neighborhood.get("edges", []):
        if edge.get("confidence", 0) > 0.5:
            impacts.append(f"{edge['from']} → {edge['to']} ({edge['type']}, conf={edge['confidence']})")
    return impacts
```