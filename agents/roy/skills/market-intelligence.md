# Market Intelligence

## Purpose

Fetch, interpret, and write observations about cattle and feed markets. This skill bridges external data (CME futures, USDA reports, local auctions) with internal decisions (sell/hold, lock in contracts, hedge risk). Roy and Belle share this skill — Roy watches prices, Belle watches margins.

## Data Sources

### Cattle Markets

| Source | What | URL | Frequency |
|--------|------|-----|-----------|
| CME Live Cattle Futures | Futures prices, contracts | `cmegroup.com/markets/agriculture/live-cattle.html` | Daily |
| USDA LM_CT180 | Direct cattle reporting, 5-area weighted avg | `https://www.ams.usda.gov/mnreports/lm_ct180.txt` | Weekly |
| Local Auction | Cash prices, head count, quality breakdown | Varies | Weekly |
| CME Feeder Cattle | Feeder futures | `cmegroup.com/markets/agriculture/feeder-cattle.html` | Daily |

### Feed Markets

| Source | What | URL | Frequency |
|--------|------|-----|-----------|
| USDA Hay Reports | Regional hay prices by grade | `https://www.ams.usda.gov/mnreports/nw_gr110.txt` | Weekly |
| CBOT Corn | Corn futures (feed cost proxy) | `cmegroup.com/markets/agriculture/corn.html` | Daily |
| CBOT Soybean Meal | Protein supplement cost proxy | `cmegroup.com/markets/agriculture/soybean-meal.html` | Daily |
| Local Co-Op | Spot prices, contract availability | Phone/in-person | Weekly |

### Fuel & Inputs

| Source | What | Frequency |
|--------|------|-----------|
| OPIS Rack Prices | Diesel, gasoline spot | Daily |
| Local Cardlock | Bulk fuel pricing | Weekly |
| Fertilizer (if applicable) | DAP, urea, potash | Monthly |

## Observation Protocol

### Price Observations

Write an observation when price moves >5% in a week or >10% in a month:

```python
g.observe(
    node_id="concept-ranch-supply",
    obs_type="measurement",
    value=168.50,  # $/cwt live cattle
    sigma=2.00,    # daily variation
    source="roy_cme_futures",
    source_url="https://www.cmegroup.com/markets/agriculture/live-cattle.html",
    notes="Live cattle futures June contract: $168.50/cwt. Up $3.75 from last week (+2.3%). August contract: $172.25. Cash-market spread widening."
)
```

### Market Shift Observations

Write an observation when the market structure changes (not just price):

```python
g.observe(
    node_id="concept-ranch-supply",
    obs_type="assessment",
    value=0.7,  # confidence that this is a structural shift
    sigma=0.15,
    source="roy_market_analysis",
    notes="Cash-futures spread inverting: June futures $168.50 vs 5-area cash $165.20. Typically indicates weakening demand or increasing placements. Monitor for trend confirmation."
)
```

### Breakeven Observations (Belle)

```python
g.observe(
    node_id="concept-ranch-finance",
    obs_type="measurement",
    value=155.00,  # $/cwt breakeven
    sigma=10.00,   # uncertainty in cost projections
    source="belle_breakeven_analysis",
    notes="Fall calf breakeven at $155/cwt (based on $985/head cost projection, 635lb avg weaning weight). Current August futures at $172.25 — margin of $17.25/cwt ($109/head). Margin shrinking from last month's $21/cwt."
)
```

## Key Metrics to Track

| Metric | Calculation | Alert Threshold |
|--------|------------|-----------------|
| Live cattle price | CME near-month futures | >5% week-over-week move |
| Feed cost ratio | Total feed cost ÷ head count ÷ days | >$3.50/head/day |
| Breakeven price | Total cost per head ÷ avg weaning weight | Within $0.10/lb of market |
| Cash-futures basis | Cash price - futures price | Spreading or inverting |
| Feed cost as % of total | Feed spend ÷ total operating cost | >65% |
| Margin per head | (Weaning weight × market price) - total cost per head | <$100/head |

## Synthesis: Market Timing

When Roy and Belle's observations converge, write a market timing synthesis:

```python
g.write_synthesis(
    cluster_ids=["concept-ranch-supply", "concept-ranch-finance", "concept-ranch-livestock"],
    label="Fall Calf Market Window Assessment",
    content="August futures at $172.25/cwt. Breakeven at $155/cwt. Margin of $17.25/cwt ($109/head) — down from $21/cwt last month. Feed costs rising (alfalfa spot $245, corn $4.82). If feed continues up 5%/month and cattle hold steady, margin compresses to $12/cwt by September. Consider: (1) early weaning to capture August contract, (2) lock in feed costs now, (3) evaluate lightweight selling vs. backgrounding to heavier weights.",
    edge_type="INFLUENCES",
    confidence=0.78,
    provenance="ranch_supply",
    tags=["market", "sell-or-hold", "calf-prices", "feed-cost"]
)
```

## Price History Node Pattern

Create nodes for key price series so observations accumulate:

```python
# Create once
g.create_node(
    id="price-live-cattle-cme",
    label="CME Live Cattle Futures Price",
    type="price-series",
    tags=["price", "cattle", "market", "ranch-supply"]
)

g.create_node(
    id="price-alfalfa-spot",
    label="Alfalfa Hay Spot Price",
    type="price-series",
    tags=["price", "hay", "feed", "ranch-supply"]
)

g.create_node(
    id="price-corn-cbot",
    label="CBOT Corn Futures Price",
    type="price-series",
    tags=["price", "corn", "feed", "ranch-supply"]
)

# Write observations to these nodes over time
g.observe(
    node_id="price-live-cattle-cme",
    obs_type="measurement",
    value=168.50,
    sigma=2.00,
    source="roy_cme_futures",
    notes="June contract $168.50/cwt"
)
```

Over time, these price-series nodes accumulate observations that Belle can use for trend analysis and breakeven projections.