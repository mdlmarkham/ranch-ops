# Seasonal Planning

## Purpose

Ranching is a seasonal business. Income is lumpy (calf sales in fall), costs are continuous, and every season has different risks and requirements. This skill maps the annual cycle to OHM: when to observe, when to synthesize, and when to act.

## The Annual Cycle

```
        WINTER (Dec-Feb)              SPRING (Mar-May)
   ┌─────────────────────┐     ┌─────────────────────┐
   │ • Calving prep       │     │ • Calving season     │
   │ • Highest feed cost  │     │ • Vaccinations       │
   │ • Equipment service  │     │ • Pasture assessment  │
   │ • Tax planning       │     │ • Spring fencing      │
   │ • Budget review      │     │ • Hire seasonal help  │
   └─────────┬───────────┘     └─────────┬───────────┘
             │                           │
    SUMMER (Jun-Aug)              FALL (Sep-Nov)
   ┌─────────────────────┐     ┌─────────────────────┐
   │ • Breeding season    │     │ • Weaning            │
   │ • Hay production     │     │ • Pregnancy checking  │
   │ • Pasture rotation   │     │ • Calf sales ★        │
   │ • Heat stress mgmt   │     │ • Cull cow sales      │
   │ • Fly control        │     │ • Winter prep         │
   └─────────┬───────────┘     └─────────┬───────────┘
             │                           │
             └───────────┬───────────────┘
                    ANNUAL CYCLE
```

## OHM Observation Calendar

### What to observe and when:

#### Winter (Dec-Feb)
| Agent | What to Observe | Frequency | Node |
|-------|----------------|-----------|------|
| Clint | BCS trends, calving readiness, feed intake | Weekly | `concept-ranch-livestock` |
| Roy | Hay prices (buying season!), winter feed contracts | Weekly | `concept-ranch-supply` |
| Magnus | Equipment maintenance status, feed inventory levels | Biweekly | `concept-ranch-inventory` |
| Virgil | Labor availability, seasonal hiring needs for spring | Monthly | `concept-ranch-hr` |
| Belle | Tax deadlines, annual budget review, LOC draws | Monthly | `concept-ranch-finance` |
| Slim | Freeze risk, water source status, snow conditions | Daily | `concept-ranch-field` |

#### Spring (Mar-May)
| Agent | What to Observe | Frequency | Node |
|-------|----------------|-----------|------|
| Clint | Calving progress, calf health, BCS post-calving | Daily during peak | `concept-ranch-livestock` |
| Roy | Vaccine/supply orders, spring equipment needs | Weekly | `concept-ranch-supply` |
| Magnus | Fencing materials inventory, sprayer readiness | Weekly | `concept-ranch-inventory` |
| Virgil | New hires, safety training completion | Weekly | `concept-ranch-hr` |
| Belle | Spring cash flow (negative months), LOC status | Biweekly | `concept-ranch-finance` |
| Slim | Pasture conditions, flood risk, fence damage from winter | Daily | `concept-ranch-field` |

#### Summer (Jun-Aug)
| Agent | What to Observe | Frequency | Node |
|-------|----------------|-----------|------|
| Clint | Breeding success, BCS, heat stress indicators | Weekly | `concept-ranch-livestock` |
| Roy | Hay contract pricing (buy for winter NOW), fuel costs | Weekly | `concept-ranch-supply` |
| Magnus | Hay inventory (production vs. needs), equipment hours | Weekly | `concept-ranch-inventory` |
| Virgil | Haying crew performance, heat safety compliance | Biweekly | `concept-ranch-hr` |
| Belle | Hay sales revenue (if surplus), cost-per-head tracking | Biweekly | `concept-ranch-finance` |
| Slim | Drought monitoring, pasture rotation status, water levels | Daily | `concept-ranch-field` |

#### Fall (Sep-Nov)
| Agent | What to Observe | Frequency | Node |
|-------|----------------|-----------|------|
| Clint | Weaning weights, pregnancy check results, cull decisions | Weekly | `concept-ranch-livestock` |
| Roy | Winter feed orders, market price tracking for calf sales | Weekly | `concept-ranch-supply` |
| Magnus | Winter equipment prep, facility readiness | Monthly | `concept-ranch-inventory` |
| Virgil | End-of-season labor, offboarding, safety review | Monthly | `concept-ranch-hr` |
| Belle | Calf sale revenue, tax-loss selling, year-end planning | Weekly | `concept-ranch-finance` |
| Slim | Fall pasture conditions, water prep for freeze, fencing | Weekly | `concept-ranch-field` |

## Synthesis Triggers by Season

### Winter Synthesis: "Are We Ready for Calving?"
**Cluster:** Clint (BCS/calf readiness) + Roy (supplies on hand) + Magnus (equipment ready) + Virgil (labor scheduled)
**Trigger:** 30 days before projected first calving date
**Decision:** Do we have everything? What's still needed?

### Spring Synthesis: "How's Calving Going?"
**Cluster:** Clint (calving progress, calf losses) + Slim (weather impact) + Virgil (labor sufficiency)
**Trigger:** Weekly during calving season
**Decision:** Interventions needed? Labor adequate? Weather affecting survival?

### Summer Synthesis: "Feed Strategy"
**Cluster:** Roy (hay prices) + Clint (pasture condition) + Slim (drought risk) + Belle (budget for winter feed)
**Trigger:** When hay prices shift >5% or drought conditions emerge
**Decision:** Lock in contract now, wait, or find alternative feed?

### Fall Synthesis: "Sell or Hold?"
**Cluster:** Belle (breakeven analysis) + Roy (market prices) + Clint (calf readiness) + Slim (weather forecast for shipping)
**Trigger:** When CME futures shift or local auction reports come in
**Decision:** Sell at current prices or hold for seasonal rally?

## Annual Planning Node

Each year, create an annual planning node in OHM:

```python
g.create_node(
    id=f"plan-ranch-{year}",
    label=f"Ranch Annual Plan {year}",
    type="plan",
    tags=["ranch-operations", "annual-plan", f"year-{year}"]
)
```

Connect seasonal observations to the annual plan, creating a living document that evolves throughout the year rather than being written once and forgotten.