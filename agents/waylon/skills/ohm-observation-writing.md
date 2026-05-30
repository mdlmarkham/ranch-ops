# OHM Observation Writing

## Purpose

Teach every agent when, how, and why to write observations to the shared knowledge graph. This is the skill that makes OHM alive — without observations, the graph is empty. With good observations, patterns emerge that no single agent would see alone.

## When to Write an Observation

### Always Write When:
- A measurable value changes significantly (prices, weights, counts, scores)
- An event occurs (calving, equipment failure, weather event, hire/fire)
- A threshold is crossed (reorder point, alert level, budget variance)
- You learn something that changes a decision (vendor price change, regulation update, disease report)
- You disagree with another agent's observation (challenge, not overwrite)

### Never Write When:
- You're just confirming something already observed (unless you have new data)
- The information is speculative with confidence < 0.3
- It's operational noise (a routine check that found nothing — unless "nothing" is itself notable)

## Observation Format

Every observation has these fields:

```json
{
  "node_id": "concept-ranch-livestock",
  "obs_type": "measurement",
  "value": 5.2,
  "sigma": 0.3,
  "source": "clint_field_observation",
  "source_url": null,
  "notes": "BCS average for breeding herd. 2 of 45 head below 4.0 — flagged for supplemental feed."
}
```

### Field Guide

| Field | What | When to vary |
|-------|------|-------------|
| `node_id` | Which domain node this relates to | Use the most specific node. If it's about feed prices, use `concept-ranch-supply`, not the hub |
| `obs_type` | `measurement` (numeric), `event` (occurrence), `assessment` (qualitative) | Use `event` for things that happened, `measurement` for numbers, `assessment` for judgments |
| `value` | The number or 1 (for events) | For events, use 1. For measurements, use the actual number |
| `sigma` | Uncertainty (±) | Be honest. If you measured it, sigma is small (0.1-0.5). If you estimated, sigma is larger (1-3). If you heard it second-hand, sigma is largest (3-5) |
| `source` | Who/what reported this | Use your provenance tag: `clint_field_observation`, `roy_vendor_report`, `belle_cash_flow_analysis` |
| `source_url` | Link to external source if applicable | Use for market data, weather reports, regulatory documents. Leave null for direct observations |
| `notes` | Context that makes this useful | This is where the value lives. Not "BCS 5.2" but "BCS 5.2, two head below 4.0, flagged for supplemental feed" |

### Provenance Tags

Each agent uses their provenance tag consistently:

| Agent | Provenance Tag |
|-------|---------------|
| Waylon | `ranch_operations` |
| Clint | `ranch_livestock` |
| Roy | `ranch_supply` |
| Magnus | `ranch_inventory` |
| Virgil | `ranch_hr` |
| Belle | `ranch_finance` |
| Slim | `ranch_field` |

## Observation Examples by Domain

### Clint (Livestock)
```json
{
  "node_id": "concept-ranch-livestock",
  "obs_type": "measurement",
  "value": 5.2,
  "sigma": 0.3,
  "source": "clint_field_observation",
  "notes": "BCS average for breeding herd. 2 of 45 below 4.0 — flagged supplemental."
}
```

### Roy (Supply Chain)
```json
{
  "node_id": "concept-ranch-supply",
  "obs_type": "measurement",
  "value": 245.0,
  "sigma": 5.0,
  "source": "roy_coop_price_report",
  "source_url": "https://www.ams.usda.gov/mnreports/nw_gr110.txt",
  "notes": "Alfalfa hay spot price $245/ton at local co-op. Up $15 from last week. 6-month contract still at $210."
}
```

### Slim (Field)
```json
{
  "node_id": "concept-ranch-field",
  "obs_type": "event",
  "value": 1,
  "sigma": 0,
  "source": "slim_field_report",
  "notes": "Section 3 north fence line: 2 posts down, barbed wire intact. Priority repair, not urgent. Est. 2 hours labor."
}
```

### Belle (Finance)
```json
{
  "node_id": "concept-ranch-finance",
  "obs_type": "measurement",
  "value": -4200.0,
  "sigma": 500.0,
  "source": "belle_cash_flow_analysis",
  "notes": "June cash flow projection revised to -$4,200. Feed cost up 12% MoM. Calf sales not until October. Need to draw on LOC."
}
```

## Confidence Discipline

| Confidence | What it means | What you do |
|------------|--------------|-------------|
| ≥ 0.8 | You measured it, or it's from a verified source | Write the observation. Own it. |
| 0.5–0.7 | You see a pattern but need more data | Write the observation. Flag it as emerging. Ask for verification. |
| < 0.5 | Something might be there but you're not sure | Don't write yet. Discuss with Waylon or the domain specialist first. |

## Writing to OHM

```python
from ohm.sdk import connect_http
g = connect_http("http://127.0.0.1:8711", actor="clint",
                 token="ranch-…N")

# Write an observation
g.observe(
    node_id="concept-ranch-livestock",
    obs_type="measurement",
    value=5.2,
    sigma=0.3,
    source="clint_field_observation",
    source_url=None,
    notes="BCS average for breeding herd. 2 of 45 below 4.0."
)
```

## Common Mistakes

1. **Writing too many observations** — Not every routine check needs a graph entry. Only when something changes.
2. **Vague notes** — "Feed prices up" is useless. "Alfalfa spot $245/ton, up $15/week, co-op contract at $210" is useful.
3. **Wrong node** — Supply chain observations go to `concept-ranch-supply`, not `concept-ranch-operations-hub`. Be specific.
4. **Missing sigma** — An observation without uncertainty is a fact without context. Always include sigma.
5. **Overwriting instead of challenging** — If you disagree with another agent's observation, write a challenge, not a replacement.