# Cost Per Head Analysis

## Purpose

Cost per head is the single most important financial metric on a cow-calf operation. It connects everything — feed, labor, vet, equipment, financing — into one number that determines whether the ranch is profitable. This skill teaches Clint, Roy, and Belle to write observations that feed into this calculation, and teaches Belle to synthesize the final number.

## The Formula

```
Cost Per Head = Total Annual Operating Expenses ÷ Average Cow Inventory

Where:
  Total Annual Operating Expenses = 
      Feed (hay + grain + supplement + mineral)
    + Veterinary & Health (vaccines, dewormer, vet calls, medicine)
    + Labor (wages + benefits + seasonal help)
    + Equipment & Maintenance (fuel, repairs, depreciation)
    + Pasture (fertilizer, spraying, seeding, water)
    + Financing (interest on operating note, LOC costs)
    + Overhead (insurance, property tax, utilities, office)
    - Less: Income from cull cows, other livestock products

  Average Cow Inventory = 
    (Opening inventory + Closing inventory) ÷ 2
```

## Data Inputs by Agent

### Clint → Livestock Data
| Input | Observation | Frequency |
|-------|------------|-----------|
| Average cow inventory | `obs_type: "measurement"`, value = head count, sigma = 0 (counted) | Monthly |
| Calf crop percentage | `obs_type: "measurement"`, value = %, sigma = 2 | At weaning |
| Death loss | `obs_type: "event"`, value = 1, notes = cause | As occurred |
| BCS average | `obs_type: "measurement"`, value = score, sigma = 0.3 | Monthly |
| Vet calls per month | `obs_type: "measurement"`, value = count | Monthly |

```python
g.observe(
    node_id="concept-ranch-livestock",
    obs_type="measurement",
    value=245,  # head count
    sigma=0,    # counted, not estimated
    source="clint_head_count",
    notes="June 1 inventory: 245 brood cows, 12 bulls, 3 replacement heifers. Down 3 from May (1 death loss, 2 culls sold)."
)
```

### Roy → Feed & Supply Costs
| Input | Observation | Frequency |
|-------|------------|-----------|
| Hay cost per ton | `obs_type: "measurement"`, value = $/ton | Weekly during buying season |
| Grain/supplement cost per ton | `obs_type: "measurement"`, value = $/ton | Monthly |
| Total monthly feed spend | `obs_type: "measurement"`, value = $ | Monthly |
| Vet supply spend | `obs_type: "measurement"`, value = $ | Monthly |

```python
g.observe(
    node_id="concept-ranch-supply",
    obs_type="measurement",
    value=245.0,  # $/ton alfalfa
    sigma=5.0,    # spot price varies
    source="roy_coop_price_report",
    source_url="https://www.ams.usda.gov/mnreports/nw_gr110.txt",
    notes="Alfalfa spot $245/ton at local co-op. Contracted 60% at $210. Spot premium widening."
)
```

### Magnus → Equipment & Overhead
| Input | Observation | Frequency |
|-------|------------|-----------|
| Fuel cost per month | `obs_type: "measurement"`, value = $ | Monthly |
| Equipment repair cost | `obs_type: "measurement"`, value = $ | As occurred |
| Depreciation (annual) | `obs_type: "measurement"`, value = $ | Quarterly |

### Virgil → Labor Costs
| Input | Observation | Frequency |
|-------|------------|-----------|
| Total labor cost per month | `obs_type: "measurement"`, value = $ | Monthly |
| Seasonal labor hours | `obs_type: "measurement"`, value = hours | Monthly |

### Belle → Synthesis & Calculation

Belle's job is to pull all these observations together every month and compute:

```python
# Monthly cost per head calculation
total_expenses_ytd = sum([
    feed_costs_ytd,
    vet_costs_ytd,
    labor_costs_ytd,
    equipment_costs_ytd,
    pasture_costs_ytd,
    financing_costs_ytd,
    overhead_ytd
])
avg_cow_inventory = (opening_inventory + current_inventory) / 2
cost_per_head_ytd = total_expenses_ytd / avg_cow_inventory

# Projected annual cost per head
projected_annual = cost_per_head_ytd * (12 / months_elapsed)

g.observe(
    node_id="concept-ranch-finance",
    obs_type="measurement",
    value=projected_annual,
    sigma=50.0,  # projection uncertainty
    source="belle_cost_per_head_analysis",
    notes=f"Projected annual cost/head: ${projected_annual:.0f}. YTD ${cost_per_head_ytd:.0f}/head over {months_elapsed} months. Trend: {'rising' if projected_annual > last_year else 'stable'}."
)
```

## Benchmark Ranges

| Metric | Below Average | Average | Above Average | Red Flag |
|--------|--------------|---------|---------------|----------|
| Cost per cow (annual) | < $650 | $750-$900 | $900-$1,100 | > $1,100 |
| Feed cost % of total | < 50% | 55-65% | > 70% | > 75% |
| Labor cost % of total | < 10% | 12-18% | > 20% | > 25% |
| Vet cost per head | < $25 | $35-$50 | > $60 | > $80 |
| Calf crop % | > 92% | 85-90% | < 80% | < 75% |

## Synthesis Pattern: Cost Driver Alert

When cost per head crosses a threshold, write a synthesis connecting the drivers:

```python
g.write_synthesis(
    cluster_ids=["concept-ranch-livestock", "concept-ranch-supply", "concept-ranch-finance"],
    label="Rising Cost Per Head — Feed-Driven",
    content="Projected annual cost/head at $985, up $135 from last year. Primary driver: alfalfa spot at $245/ton (contract at $210 covering 60% of needs). Secondary: 2 additional vet calls for respiratory issues. If spot prices hold through Q3, cost/head will exceed $1,000 — above the $900 target. Consider: (1) lock remaining 40% at current contract price, (2) evaluate alternative forage, (3) defer non-essential equipment maintenance.",
    edge_type="CAUSES",
    confidence=0.85,
    provenance="belle_cost_per_head_analysis",
    tags=["cost-per-head", "feed-cost", "budget-alert"]
)
```