# Weather Impact Assessment

## Purpose

Weather isn't just data — it's the primary driver of every ranch decision. This skill connects Slim's weather observations to Clint's livestock management decisions, Roy's purchasing, and Waylon's coordination. It's the bridge between "what's the weather" and "what does it mean for the herd."

## Weather Decision Framework

### Not Just "What's the Weather" — "What Does It Mean?"

| Weather Event | Livestock Impact | Supply Impact | Financial Impact |
|--------------|-----------------|---------------|-----------------|
| **Heat >95°F** | Heat stress, reduced feed intake, water consumption doubles | Water demand spikes | Higher water/fuel costs |
| **Cold <10°F** | Calf frostbite risk, increased feed demand (20-30%) | Fuel demand spikes | Higher feed/fuel costs |
| **Heavy rain >2"/24hr** | Pasture damage, hoof problems, disease risk | Delivery delays | Possible flood damage |
| **Drought** | BCS decline, reduced forage, reproductive issues | Hay prices spike | Feed cost surge, possible herd reduction |
| **High wind >30mph** | Stress, equipment operation risk, fencing risk | Delivery risk | Repair costs |
| **Early freeze** | Forage quality drops, increased feed need | Hay demand spikes | Feed cost increase |
| **Tornado/hail warning** | Immediate safety risk, infrastructure damage | Immediate supply needs | Emergency repair costs |

## Slim's Observation Protocol

### Daily Weather Observation

```python
g.observe(
    node_id="concept-ranch-field",
    obs_type="measurement",
    value=94.0,  # High temp °F
    sigma=2.0,
    source="slim_weather_report",
    source_url="https://forecast.weather.gov/MapClick.php?lat=XX.X&lon=-YY.Y",
    notes="Today: 94°F, partly cloudy, SW 12mph. 3-day: Hot through Thu, possible storms Fri (60% chance). Drought monitor: D1 (Abnormally Dry) expanding in region. Creek flow: 40% of seasonal norm."
)
```

### Alert Threshold Observations

When weather crosses a threshold, write an **assessment** (not just a measurement):

```python
# Heat stress alert
g.observe(
    node_id="concept-ranch-field",
    obs_type="assessment",
    value=0.75,  # probability of significant impact
    sigma=0.1,
    source="slim_weather_report",
    notes="HEAT ALERT: 3+ days above 95°F forecast. Cattle heat stress risk elevated. Water consumption will double. Shade access critical for south pastures. Consider moving herd to Section 5 (natural shade, creek access)."
)

# Drought assessment
g.observe(
    node_id="concept-ranch-field",
    obs_type="assessment",
    value=0.65,  # drought probability
    sigma=0.15,
    source="slim_weather_report",
    notes="DROUGHT WATCH: 14-day forecast below average precip. Section 3 score 3.8/10 and declining. Creek at 40% seasonal norm. Regional D1 expanding. Trigger point: if no rain by June 25, activate drought mitigation plan."
)
```

## Cross-Domain Impact Chain

When Slim writes a weather observation, it cascades through the graph:

```
Weather → Pasture → Livestock → Supply → Finance

Example cascade:
Drought (Slim) → Pasture degrades (Slim) → BCS drops (Clint)
                → Hay prices rise (Roy) → Cash flow tightens (Belle)
                → Need supplemental feed (Roy) → Budget impact (Belle)
```

### How Each Agent Responds

**Slim** writes the initial observation. Then:

**Clint** reads the weather observation and assesses livestock impact:
```python
g.observe(
    node_id="concept-ranch-livestock",
    obs_type="assessment",
    value=0.7,
    sigma=0.15,
    source="clint_livestock_assessment",
    notes="Heat stress risk for 2 head already below BCS 4.0. Water consumption monitoring increased. Shade access at Section 5 adequate for 150 head — need to move 95 head from Section 3."
)
```

**Roy** reads it and assesses supply impact:
```python
g.observe(
    node_id="concept-ranch-supply",
    obs_type="assessment",
    value=0.6,
    sigma=0.2,
    source="roy_supply_assessment",
    notes="Heat event will increase water demand 2x. Current tank capacity adequate for 48 hours. Mineral consumption will increase — 5-day supply on hand, need reorder."
)
```

**Belle** reads it and assesses financial impact:
```python
g.observe(
    node_id="concept-ranch-finance",
    obs_type="assessment",
    value=0.5,
    sigma=0.2,
    source="belle_finance_assessment",
    notes="Heat event adds ~$200/day in supplemental water and mineral. If drought mitigation triggers, supplemental feed costs rise $3-5/head/day. 14-day heat event: ~$2,800-4,200 additional cost."
)
```

**Waylon** synthesizes:
```python
g.write_synthesis(
    cluster_ids=["concept-ranch-field", "concept-ranch-livestock", 
                 "concept-ranch-supply", "concept-ranch-finance"],
    label="Heat-Drought Compound Risk",
    content="3+ day heat wave + drought conditions creating compound risk. Section 3 pasture at 3.8/10 with 2 head below BCS 4.0. Water demand doubling. Supplemental costs estimated $200/day (heat) rising to $3-5/head/day if drought plan triggers. Action: Move herd to Section 5, reorder mineral, monitor for drought trigger by June 25.",
    edge_type="CAUSES",
    confidence=0.78,
    provenance="ranch_operations",
    tags=["heat", "drought", "compound-risk", "livestock"]
)
```

## Weather Sources (Priority Order)

1. **NWS local forecast** — Official, free, reliable
2. **USDA drought monitor** — Weekly, regional context
3. **Local ag weather station** — Ground truth for microclimate
4. **On-site rain gauge** — Actual precipitation measurement
5. **Sky observation** — Slim's own assessment of approaching weather

## Seasonal Weather Patterns to Watch

| Season | Risk | Watch For | Trigger |
|--------|------|-----------|---------|
| **Winter** | Freeze, blizzard | Sub-zero forecasts, wind chill | <10°F for >24 hours |
| **Spring** | Flooding, late freeze | Rain totals, frost dates | >2" rain in 24hr, frost after green-up |
| **Summer** | Heat, drought | Heat index, precip deficit | >95°F for 3+ days, D1 drought monitor |
| **Fall** | Early freeze, mud | First frost date, rain patterns | Freeze before Oct 15, saturated pastures |

## Historical Weather Node

Create a weather tracking node so observations accumulate over time:

```python
g.create_node(
    id="weather-ranch-2026",
    label="Ranch Weather 2026",
    type="weather-series",
    tags=["weather", "ranch-field", "2026"]
)
```

This lets Slim write daily observations to the same node, building a time series that can be analyzed for seasonal patterns.