# Daily Briefing Generation

## Purpose

The daily operations brief is Waylon's primary output — a concise, actionable summary of what's happening, what's at risk, and what needs attention today. This skill teaches Waylon to pull from all agents' observations and synthesize a briefing that connects the dots across domains.

## Briefing Format

```markdown
## 🤠 Ranch Operations Brief — {DATE}

### 🌡️ Weather
- **Today**: [conditions, high/low, wind]
- **3-Day**: [summary — any alerts?]
- **Alerts**: [freeze, heat, wind, flood — or "None"]

### 🐄 Livestock (Clint)
- **Herd**: [head count, health status, alerts]
- **Calving/Breeding**: [active events, progress]
- **Feed/Pasture**: [concerns, rotation needs]

### 📦 Supply Chain (Roy)
- **In Transit**: [what, when, cost]
- **Price Alerts**: [significant shifts this week]
- **Reorder Flags**: [what's running low]

### 📋 Inventory (Magnus)
- **Equipment**: [what's up, what's down, what's in the shop]
- **Feed Stock**: [days on hand for hay, grain, supplement]
- **Reorder Points Hit**: [immediate actions]

### 👷 Labor (Virgil)
- **Crew**: [who's on, who's off, coverage]
- **Seasonal**: [upcoming needs, hiring status]
- **Safety**: [incidents or near-misses in last 24h]

### 💰 Finance (Belle)
- **Cash Position**: [current vs. 30-day projection]
- **Payables/Aging**: [what's due this week]
- **Budget Alerts**: [variances >10%]

### 🏜️ Field (Slim)
- **Fence Lines**: [damage reports, priority repairs]
- **Water**: [source levels, concerns]
- **Pasture**: [section scores, rotation schedule]

### ⚠️ Cross-Domain Dependencies
- [Operations that depend on weather, supply, or labor]
- [Conflicts or bottlenecks to resolve]
- [Risk register items that moved this week]

### 📋 Today's Priorities
1. [Highest priority action]
2. [Second priority]
3. [Third priority]
```

## Generation Process

### Step 1: Pull Recent Observations

```python
from ohm.sdk import connect_http
from datetime import datetime, timedelta

g = connect_http("http://127.0.0.1:8711", actor="waylon",
                 token="ranch-…N")

yesterday = (datetime.now() - timedelta(days=1)).isoformat()
recent = g.listen(since=yesterday)
```

### Step 2: Organize by Domain

```python
domain_map = {
    "concept-ranch-livestock": [],
    "concept-ranch-supply": [],
    "concept-ranch-inventory": [],
    "concept-ranch-hr": [],
    "concept-ranch-finance": [],
    "concept-ranch-field": []
}

for obs in recent.get("observations", []):
    node = obs.get("node_id", "")
    if node in domain_map:
        domain_map[node].append(obs)
```

### Step 3: Flag Cross-Domain Connections

```python
# Find observations from different domains within 24 hours that might be related
cross_domain = []
domains_with_obs = [d for d, obs_list in domain_map.items() if obs_list]

if len(domains_with_obs) >= 2:
    # Check for time-proximate observations across domains
    for i, d1 in enumerate(domains_with_obs):
        for d2 in domains_with_obs[i+1:]:
            # Check if observations share temporal proximity
            # or reference similar conditions
            for o1 in domain_map[d1]:
                for o2 in domain_map[d2]:
                    # Simple heuristic: same day, potential connection
                    cross_domain.append({
                        "domain1": d1,
                        "domain2": d2,
                        "obs1": o1,
                        "obs2": o2
                    })
```

### Step 4: Check Risk Register

```python
# Get all active risks
risk_nodes = g.search(query="risk", tags=["risk"])
active_risks = []
for risk in risk_nodes:
    neighborhood = g.neighborhood(risk["id"], depth=1)
    assessments = [o for o in neighborhood.get("observations", [])
                   if o.get("obs_type") == "assessment"]
    if assessments:
        latest = assessments[-1]
        score = latest["value"] * 3 * 2  # P × impact × urgency defaults
        if score >= 3.0:
            active_risks.append({
                "label": risk["label"],
                "probability": latest["value"],
                "score": score,
                "notes": latest["notes"]
            })
```

### Step 5: Synthesize Priorities

Priority rules:
1. **Safety first**: Any safety incident or imminent danger
2. **Risk register**: Any risk with score ≥ 6.0 (critical)
3. **Time-sensitive**: Things that must happen today (shipments, vet visits, weather windows)
4. **Cross-domain**: Dependencies between domains
5. **Routine**: Everything else

## Briefing Delivery

The brief should be:
- **Concise**: Fits on a phone screen (≤ 500 words)
- **Actionable**: Every item either has an action or explicitly says "no action needed"
- **Connected**: Cross-domain items are surfaced, not buried in silos
- **Prioritized**: Top 3 items are clear

### Example Brief

```
🤠 Ranch Operations Brief — June 15, 2026

🌡️ Today: 94°F, partly cloudy, wind SW 12mph. 3-day: Hot through 
Thursday, possible storms Fri. No alerts.

🐄 245 head, 2 below BCS 4.0 (on supplemental feed). Breeding 
season Day 12 — 3 bulls active. No health alerts.

📦 Alfalfa spot up $15/ton to $245. Contract covers 60% at $210. 
Reorder: mineral blocks (5 days on hand).

📋 Primary tractor: operational. Feed truck: oil change due (over 
by 200 hrs). Hay inventory: 42 days on hand (target 60).

👷 Full crew today. Seasonal haying app: 2 of 4 positions filled.

💰 Cash: $34K. 30-day projection: -$4,200. LOC available at $50K. 
No payables due this week.

🏜️ Section 3: 3.8/10 (drought stress). Section 5: 6.2/10 (good). 
North fence: 2 posts down — Priority repair.

⚠️ CROSS-DOMAIN: Section 3 drought + hay price spike + BCS drops = 
compound risk. If no rain by June 25, trigger drought mitigation plan.

📋 Priorities:
1. Schedule fence repair (Section 3 north) — Slim
2. Lock in remaining 40% hay contract — Roy + Belle
3. Monitor Section 3 — if score drops below 3.5, move herd — Clint
```

## When to Skip the Brief

- No new observations in the last 24 hours AND no active risks ≥ 3.0
- In that case, send a minimal "All quiet" brief instead of generating noise