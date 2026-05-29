# Ranch Operations Coordination Skill

## Purpose
Coordinate daily ranch operations across all domains: livestock, supply, inventory, HR, finance, and field conditions.

## Daily Operations Brief Format

```markdown
## Ranch Operations Brief — {DATE}

### Weather
- Today: [conditions]
- 3-day forecast: [summary]
- Alerts: [flood, freeze, heat, wind]

### Livestock (from Clint)
- Herd status: [head count, health alerts]
- Calving/breeding status: [active events]
- Feed/pasture concerns: [rotations needed]

### Supply Chain (from Roy)
- Orders in transit: [what, when, cost]
- Price alerts: [significant shifts]
- Reorder flags: [what's running low]

### Inventory (from Magnus)
- Equipment status: [what's operational, what's down]
- Feed stock levels: [days on hand]
- Reorder points hit: [immediate actions]

### Labor (from Virgil)
- Crew status: [who's on, who's off]
- Seasonal hiring: [upcoming needs]
- Safety incidents: [any in last 24h]

### Finance (from Belle)
- Cash position: [current vs projection]
- Payables/receivables: [aging]
- Budget alerts: [variances >10%]

### Field (from Slim)
- Fence line status: [damage reports]
- Water sources: [levels, concerns]
- Pasture conditions: [by section]

### Cross-Domain Dependencies
- [Operations that depend on weather, supply, or labor]
- [Conflicts or bottlenecks to resolve]
```

## Coordination Rules

1. **Weather governs everything**: If Slim reports weather risk, all outdoor operations get flagged
2. **Feed is the #1 cost**: Roy and Belle must align on any purchase > $500
3. **Labor constraints bind all**: If Virgil flags labor shortage, Waylon adjusts the day's priorities
4. **Equipment downtime cascades**: If Magnus reports a sprayer down, Clint adjusts pasture treatment schedule
5. **Cash flow is the ultimate constraint**: Belle has veto on any purchase that threatens 30-day cash position

## OHM Synthesis Patterns

When you see these clusters, write syntheses:
- 3+ price observations → supply chain trend
- Weather + pasture + livestock → grazing pressure pattern
- Equipment + labor + finance → operational bottleneck
- Seasonal cycle observations → annual planning insight