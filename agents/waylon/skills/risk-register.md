# Risk Register

## Purpose

Every ranch has risks that cut across domains — drought, market crashes, disease outbreaks, regulatory changes. This skill teaches agents to write risk observations and teaches Waylon to synthesize them into a living risk register in the knowledge graph.

## Risk Categories

| Category | Examples | Primary Agent | Supporting Agents |
|----------|---------|---------------|-------------------|
| **Weather & Climate** | Drought, flood, early freeze, heat wave | Slim | Clint, Roy |
| **Market & Price** | Cattle price crash, feed cost spike, fuel surge | Belle | Roy |
| **Animal Health** | Disease outbreak, calving complications, predator loss | Clint | Virgil |
| **Regulatory** | H-2A changes, OSHA, tax code, environmental regs | Virgil | Belle |
| **Supply Chain** | Vendor bankruptcy, delivery delays, quality failure | Roy | Magnus |
| **Equipment** | Critical failure, parts shortage, obsolescence | Magnus | Belle |
| **Labor** | Worker shortage, key person loss, safety incident | Virgil | Clint |
| **Financial** | LOC freeze, interest rate spike, cash crunch | Belle | Roy |

## Risk Observation Format

Each risk gets a node in OHM with a specific naming convention:

```
risk-{category}-{short-name}
```

Examples:
- `risk-weather-drought` — Multi-season drought
- `risk-market-cattle-crash` — Cattle price decline >20%
- `risk-health-brd-outbreak` — Bovine respiratory disease outbreak
- `risk-regulatory-h2a-changes` — H-2A program modifications
- `risk-supply-hay-shortage` — Regional hay supply disruption
- `risk-equipment-tractor-failure` — Primary tractor out of service
- `risk-labor-seasonal-shortage` — Insufficient seasonal workers
- `risk-finance-loc-freeze` — Line of credit unavailable

## Risk Assessment Matrix

Each risk observation includes:

```python
g.observe(
    node_id="risk-weather-drought",
    obs_type="assessment",
    value=0.65,  # Probability (0-1)
    sigma=0.15,  # Uncertainty in probability estimate
    source="slim_field_report",
    notes="Drought risk elevated. Section 3 pasture score 3.8/10 (target 5-7). Creek running at 40% seasonal norm. 30-day forecast below average precip. Regional drought monitor shows D1 (Abnormally Dry) expanding. If no rain in 14 days, triggers supplemental feed requirement."
)
```

### Impact Assessment

| Impact Level | Financial | Operational | Timeline |
|-------------|-----------|-------------|----------|
| **Critical (5)** | >$50K or >20% of revenue | Herd health at risk, operation halts | Immediate |
| **High (4)** | $25-50K or 10-20% of revenue | Major disruption, workarounds needed | Days |
| **Medium (3)** | $10-25K or 5-10% of revenue | Moderate disruption, manageable | Weeks |
| **Low (2)** | $5-10K or 2-5% of revenue | Minor inconvenience | Months |
| **Minimal (1)** | <$5K or <2% of revenue | Barely noticeable | Whenever |

### Risk Scoring

```
Risk Score = Probability × Impact × Urgency

Where:
  Probability = 0-1 (from observation value)
  Impact = 1-5 (from assessment matrix above)
  Urgency = time factor (1 = can wait, 2 = act this month, 3 = act this week, 4 = act now)
```

**Risk Score ≥ 3.0** = Active concern, requires mitigation plan
**Risk Score ≥ 6.0** = Critical, requires immediate action

## Creating Risk Nodes

```python
g.create_node(
    id="risk-weather-drought",
    label="Drought Risk 2026",
    type="risk",
    tags=["ranch-field", "risk", "drought", "weather"]
)

# Assess probability
g.observe(
    node_id="risk-weather-drought",
    obs_type="assessment",
    value=0.65,
    sigma=0.15,
    source="slim_field_report",
    notes="Section 3 pasture score 3.8/10, creek at 40% seasonal norm, D1 drought monitor expanding."
)

# Link to affected domains
g.create_edge(
    from_node="risk-weather-drought",
    to_node="concept-ranch-livestock",
    type="THREATENS",
    layer="L3",
    confidence=0.7
)
g.create_edge(
    from_node="risk-weather-drought",
    to_node="concept-ranch-supply",
    type="INFLUENCES",
    layer="L3",
    confidence=0.8
)
```

## Pre-Defined Risks (Seed the Register)

### High Priority (Assess First)

```python
# Drought
g.create_node(id="risk-weather-drought", label="Drought", type="risk", tags=["risk", "weather", "drought"])
g.observe(node_id="risk-weather-drought", obs_type="assessment", value=0.3, sigma=0.15,
          source="slim_field_report", notes="Initial assessment. Updates as conditions change.")

# Market crash
g.create_node(id="risk-market-cattle-crash", label="Cattle Price Crash", type="risk", tags=["risk", "market", "price"])
g.observe(node_id="risk-market-cattle-crash", obs_type="assessment", value=0.15, sigma=0.1,
          source="belle_market_analysis", notes="CME futures currently stable. Risk increases with recession indicators.")

# Disease outbreak
g.create_node(id="risk-health-brd-outbreak", label="BRD Outbreak", type="risk", tags=["risk", "health", "disease"])
g.observe(node_id="risk-risk-health-brd-outbreak", obs_type="assessment", value=0.2, sigma=0.1,
          source="clint_livestock_assessment", notes="Standard risk. Increases with shipping stress, weather changes, new arrivals.")

# Regulatory change
g.create_node(id="risk-regulatory-h2a-changes", label="H-2A Program Changes", type="risk", tags=["risk", "regulatory", "labor"])
g.observe(node_id="risk-regulatory-h2a-changes", obs_type="assessment", value=0.25, sigma=0.2,
          source="virgil_hr_assessment", notes="Periodic regulatory risk. AEWR increases are likely.")
```

## Waylon's Risk Dashboard

Every heartbeat, Waylon queries the risk register:

```python
# Get all risk nodes and their current assessments
risk_nodes = g.search(query="risk", tags=["risk"])
for risk in risk_nodes:
    neighborhood = g.neighborhood(risk["id"], depth=1)
    latest_obs = [o for o in neighborhood.get("observations", [])
                  if o.get("obs_type") == "assessment"]
    if latest_obs:
        latest = latest_obs[-1]
        impact = 3  # Default medium
        urgency = 2  # Default monthly
        score = latest["value"] * impact * urgency
        if score >= 3.0:
            print(f"  ⚠️ {risk['label']}: P={latest['value']:.2f}, Score={score:.1f} — {latest['notes'][:60]}")
        if score >= 6.0:
            print(f"  🚨 CRITICAL: {risk['label']} — IMMEDIATE ACTION REQUIRED")
```

## Mitigation Tracking

When a mitigation plan is created, write it as a synthesis connected to the risk:

```python
g.write_synthesis(
    cluster_ids=["risk-weather-drought", "concept-ranch-supply", "concept-ranch-livestock"],
    label="Drought Mitigation Plan",
    content="If drought conditions persist 14+ days: (1) Lock in remaining 40% hay at contract price, (2) Move herd from Section 3 to Section 5 (better water access), (3) Begin supplemental feed program for BCS <4.0 head, (4) Reduce stocking rate by 10% via early cull sales.",
    edge_type="MITIGATES",
    confidence=0.75,
    provenance="ranch_operations",
    tags=["risk", "drought", "mitigation", "plan"]
)
```