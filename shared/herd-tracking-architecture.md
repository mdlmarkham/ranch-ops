# Herd Tracking: OHM vs. Supplemental Database — Architecture Decision

## The Question

Should individual animal lifecycle tracking (cradle-to-grave) live in OHM, or in a supplemental database?

## What Each System Does Well

### OHM (Knowledge Graph)

**Strengths:**
- Pattern detection across the herd ("BCS declining herd-wide → nutrition problem")
- Causal reasoning ("drought → feed cost → thin cows → delayed rebreeding → calf crop drops")
- Cross-domain connections (market prices ↔ herd decisions ↔ financial outcomes)
- Challenge and verification of interpretations
- Shared concept layer across agents
- Temporal observations with confidence/sigma

**Weaknesses for entity tracking:**
- No primary key / unique entity enforcement (node IDs are strings, not PKs)
- No schema enforcement on properties (any node can have any tags/metadata)
- No transactional writes (eventual consistency)
- No referential integrity (edges dangle when nodes are deleted)
- No efficient range queries ("all calves born between March 1-15")
- No aggregate queries ("average weaning weight by sire")
- Observations are append-only time series, not mutable state
- 56 nodes, 77 edges currently — adding 500 head as individual nodes swells it 10x

### Dedicated Database (DuckDB/SQLite/PostgreSQL)

**Strengths:**
- Entity integrity (primary keys, unique constraints, foreign keys)
- Transactional consistency (ACID)
- Efficient range, aggregate, and join queries
- Mutable state (update a cow's current BCS, not just observe it)
- Bulk operations (vaccinate 50 calves, update all in one transaction)
- Standard schema enforcement
- Easy reporting (herd inventory, breeding summary, weaning weights)

**Weaknesses:**
- No cross-domain reasoning
- No causal inference
- No agent knowledge sharing
- Separate system to maintain
- Data can get stale if not actively synced

## The Key Insight: Two Different Questions

**OHM answers:** "What patterns are emerging? What's causing this? What should we do?"
**Herd DB answers:** "Which cows are open? What did Calf #247 weigh at weaning? When is Cow #83 due?"

These are fundamentally different operations:
- OHM = **analytics & reasoning** over aggregated observations
- Herd DB = **record-keeping & operations** over individual entities

## Recommendation: Both (Federated, Not Duplicated)

```
┌─────────────────────────────────────────────────────────────┐
│                     HERD DATABASE                            │
│                 (DuckDB or SQLite)                            │
│                                                             │
│  Individual animal records: ID, breed, birth, BCS, weight,  │
│  vaccinations, breeding, calving, health events, movements  │
│  Pasture assignments, feed records, medical treatments       │
│                                                             │
│  Queries: "Who's due in March?" "ADG by sire?"              │  ──► Aggregates
│          "Open cows > 60 days?" "BCS < 5?"                  │      written to
│                                                             │      OHM
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Aggregates, thresholds, patterns
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                        OHM (Knowledge Graph)                 │
│                                                             │
│  Herd-level concepts: conception rate, calf crop %,         │
│  average BCS, disease prevalence, cost-per-head             │
│                                                             │
│  Cross-domain: market price × weaning weight = revenue      │
│  Drought × feed cost × BCS = culling decision               │
│                                                             │
│  Reasoning: "BCS declining + hay price up = sell or feed?"  │
└─────────────────────────────────────────────────────────────┘
```

### What Lives in the Herd Database

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `animals` | Individual identity | id, tag, breed, sex, birth_date, dam_id, sire_id, status (active/sold/dead) |
| `animal_weights` | Growth tracking | animal_id, date, weight, method (scale/estimate) |
| `animal_bcs` | Body condition history | animal_id, date, bcs, observer |
| `animal_health` | Medical records | animal_id, date, event_type, diagnosis, treatment, vet, cost |
| `animal_vaccinations` | Vaccination log | animal_id, date, vaccine, lot, route, administrator |
| `animal_breeding` | Reproduction records | animal_id, season, bred_date, method (AI/natural), sire_id, preg_check, due_date |
| `animal_calvings` | Calving events | dam_id, date, calf_id, calving_ease, birth_weight, calf_sex |
| `animal_movements` | Location history | animal_id, date, from_pasture, to_pasture, reason |
| `animal_status_log` | Lifecycle events | animal_id, date, event (born/weaned/sold/died/culled), details, price |

### What Lives in OHM (Aggregated from Herd DB)

| OHM Node | What Feeds It | How Often |
|----------|---------------|-----------|
| `ranch-herd-bcs-average` | AVG(bcs) FROM animal_bcs WHERE date = current | Daily/weekly |
| `ranch-conception-rate` | COUNT(preg_check=positive) / COUNT(bred) | Per breeding season |
| `ranch-calf-crop-pct` | COUNT(calvings) / COUNT(cows_exposed) | Per season |
| `ranch-avg-weaning-weight` | AVG(weight) FROM animal_weights WHERE age=205d | At weaning |
| `ranch-calving-interval` | AVG(calving_interval) across herd | Per season |
| `ranch-mortality-rate` | COUNT(status=died) / COUNT(active) | Monthly |
| `ranch-disease-incidence` | COUNT(health events) by type | Monthly |
| `ranch-cost-per-head` | SUM(costs) / COUNT(active_animals) | Monthly |

### The Sync Pattern

```python
# Herd DB → OHM sync (run daily or on heartbeat)
# This is the ONLY data flow: Herd DB writes aggregates to OHM
# OHM never writes individual animal records back

def sync_herd_to_ohm():
    # 1. Aggregate BCS
    avg_bcs = herd_db.query("SELECT AVG(bcs) FROM animal_bcs WHERE date = CURRENT_DATE")
    g.observe(
        node_id="ranch-herd-bcs-average",
        obs_type="measurement",
        value=avg_bcs,
        sigma=0.2,
        source="waylon_herd_sync",
        notes=f"Herd average BCS on {today}. N={cow_count}."
    )
    
    # 2. Check thresholds → generate alerts in OHM
    thin_cows = herd_db.query("SELECT COUNT(*) FROM animal_bcs WHERE bcs < 4.5 AND date = CURRENT_DATE")
    if thin_cows > 0.15 * total_cows:
        g.observe(
            node_id="concept-ranch-field",
            obs_type="assessment",
            value=0.7,  # high probability of problem
            sigma=0.1,
            source="waylon_herd_sync",
            notes=f"WARNING: {thin_cows}/{total_cows} cows BCS <4.5. Supplementation needed."
        )
    
    # 3. Reproductive status
    open_cows = herd_db.query("SELECT COUNT(*) FROM animals WHERE status='active' AND sex='F' AND preg_status='open' AND days_postpartum > 82")
    if open_cows > 0.10 * total_bred:
        g.observe(
            node_id="concept-ranch-reproduction",
            obs_type="assessment",
            value=0.6,
            sigma=0.1,
            source="waylon_herd_sync",
            notes=f"ALERT: {open_cows} cows still open past 82 days. Breeding audit needed."
        )
```

## Why Not Just OHM?

1. **Entity integrity matters.** You need to know that Cow #83 is *the same* Cow #83 across all her observations. OHM's string-based node IDs don't enforce this. A typo creates a phantom cow. A duplicate creates a ghost.

2. **Operational queries are constant.** "Which pasture has the spring-calving cows?" "When did we last vaccinate this pen?" "How many calves were born this week?" These are CRUD, not reasoning. A graph traversal to answer "how many calves born this week" is absurdly expensive compared to `SELECT COUNT(*) FROM animal_calvings WHERE date BETWEEN ...`.

3. **Data volume.** A 250-head cow-calf operation generates ~2,500+ individual records per year (weights, BCS, vaccinations, movements, health events). Over 10 years, that's 25,000+ records. OHM at 56 nodes is a concept graph, not a 25K-record operational database.

4. **Mutation vs. observation.** When you update a cow's BCS from 5 to 4, you need to *replace* the current value in the herd DB. In OHM, you *append* an observation. Both patterns are correct for their systems, but you can't use one pattern to serve both needs.

5. **Compliance & audit.** Health records, vaccination logs, and treatment histories have regulatory requirements (FDA, USDA, state vet board). These need immutable, auditable, schema-enforced records. OHM's flexible schema doesn't enforce the fields a state inspector expects.

## Why Not Just a Herd DB?

1. **No reasoning.** A herd DB tells you 15% of cows are thin. It doesn't tell you *why* (drought → hay price → feed ration) or *what to do* (forward contract hay now, or cull the bottom 10%?).

2. **No cross-domain connections.** The herd DB knows cow weights. It doesn't connect those to CME futures, PCE inflation data, or H-2A labor costs.

3. **No multi-agent knowledge.** Roy knows feed prices. Slim knows BCS. Belle knows the budget. Without OHM, these stay in silos.

## Implementation: DuckDB (Recommended)

DuckDB is the right choice because:
- **Embedded** — runs in-process, zero infrastructure, same machine as the agents
- **Columnar** — fast analytical queries on herd data (averages, aggregates, ranges)
- **SQL** — every agent can query it directly
- **File-based** — single `.duckdb` file, easy backup, no server to manage
- **Already in the stack** — OHM uses DuckDB, the team knows it

### Schema

```sql
-- Core animal table
CREATE TABLE animals (
    id INTEGER PRIMARY KEY,
    tag VARCHAR(20) UNIQUE NOT NULL,       -- Visual ear tag
    rfid VARCHAR(50),                       -- Electronic ID if applicable
    breed VARCHAR(50),
    sex VARCHAR(1) CHECK (sex IN ('M','F')),
    birth_date DATE,
    dam_id INTEGER REFERENCES animals(id),
    sire_id INTEGER REFERENCES animals(id),
    status VARCHAR(20) DEFAULT 'active',    -- active, sold, dead, culled
    current_pasture VARCHAR(50),
    purpose VARCHAR(20),                    -- brood, replacement, feeder, bull
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Weight tracking
CREATE TABLE animal_weights (
    id INTEGER PRIMARY KEY,
    animal_id INTEGER REFERENCES animals(id),
    weight_date DATE NOT NULL,
    weight_lbs DECIMAL(6,1) NOT NULL,
    method VARCHAR(20) DEFAULT 'scale',     -- scale, estimate, tape
    notes TEXT,
    UNIQUE(animal_id, weight_date, method)
);

-- Body condition scoring
CREATE TABLE animal_bcs (
    id INTEGER PRIMARY KEY,
    animal_id INTEGER REFERENCES animals(id),
    bcs_date DATE NOT NULL,
    bcs DECIMAL(2,1) NOT NULL CHECK (bcs BETWEEN 1.0 AND 9.0),
    observer VARCHAR(50),
    notes TEXT,
    UNIQUE(animal_id, bcs_date)
);

-- Health events
CREATE TABLE animal_health (
    id INTEGER PRIMARY KEY,
    animal_id INTEGER REFERENCES animals(id),
    event_date DATE NOT NULL,
    event_type VARCHAR(50) NOT NULL,        -- diagnosis, treatment, surgery, injury
    diagnosis VARCHAR(100),
    treatment VARCHAR(200),
    vet_name VARCHAR(100),
    medication VARCHAR(100),
    dosage VARCHAR(100),
    withdrawal_days INTEGER,
    cost DECIMAL(8,2),
    notes TEXT
);

-- Vaccination log
CREATE TABLE animal_vaccinations (
    id INTEGER PRIMARY KEY,
    animal_id INTEGER REFERENCES animals(id),
    vaccine_date DATE NOT NULL,
    vaccine_name VARCHAR(100) NOT NULL,
    vaccine_type VARCHAR(20),               -- MLV, killed, subunit
    lot_number VARCHAR(50),
    route VARCHAR(20),                      -- SQ, IM, IN, oral
    administrator VARCHAR(50),
    next_due DATE,
    notes TEXT
);

-- Breeding records
CREATE TABLE animal_breeding (
    id INTEGER PRIMARY KEY,
    animal_id INTEGER REFERENCES animals(id),
    season VARCHAR(20),                      -- 2026-spring, etc.
    bred_date DATE,
    method VARCHAR(20),                      -- natural, AI, ET
    sire_id INTEGER REFERENCES animals(id),
    sire_name VARCHAR(100),
    ai_tech VARCHAR(50),
    preg_check_date DATE,
    preg_result VARCHAR(10),                 -- positive, negative, open
    due_date DATE,
    notes TEXT
);

-- Calving events
CREATE TABLE animal_calvings (
    id INTEGER PRIMARY KEY,
    dam_id INTEGER REFERENCES animals(id),
    calf_id INTEGER REFERENCES animals(id),
    calving_date DATE NOT NULL,
    calving_ease VARCHAR(20),               -- unassisted, easy pull, hard pull, c-section
    birth_weight_lbs DECIMAL(5,1),
    calf_sex VARCHAR(1),
    calf_status VARCHAR(20) DEFAULT 'alive', -- alive, stillborn, died
    calf_color VARCHAR(50),
    notes TEXT
);

-- Movement / pasture assignments
CREATE TABLE animal_movements (
    id INTEGER PRIMARY KEY,
    animal_id INTEGER REFERENCES animals(id),
    move_date DATE NOT NULL,
    from_pasture VARCHAR(50),
    to_pasture VARCHAR(50),
    reason VARCHAR(100),
    moved_by VARCHAR(50)
);

-- Lifecycle events (the cradle-to-grave audit trail)
CREATE TABLE animal_lifecycle (
    id INTEGER PRIMARY KEY,
    animal_id INTEGER REFERENCES animals(id),
    event_date DATE NOT NULL,
    event_type VARCHAR(30) NOT NULL,         -- born, weaned, sold, purchased, culled, died, transferred
    details TEXT,
    price DECIMAL(8,2),                      -- For sales/purchases
    buyer VARCHAR(100),
    reason TEXT,                             -- For culling/death
    recorded_by VARCHAR(50)
);

-- Indexes for common queries
CREATE INDEX idx_animals_status ON animals(status);
CREATE INDEX idx_animals_pasture ON animals(current_pasture);
CREATE INDEX idx_weights_animal_date ON animal_weights(animal_id, weight_date);
CREATE INDEX idx_bcs_animal_date ON animal_bcs(animal_id, bcs_date);
CREATE INDEX idx_health_animal_date ON animal_health(animal_id, event_date);
CREATE INDEX idx_vax_animal_date ON animal_vaccinations(animal_id, vaccine_date);
CREATE INDEX idx_breeding_animal ON animal_breeding(animal_id, season);
CREATE INDEX idx_calvings_dam ON animal_calvings(dam_id, calving_date);
CREATE INDEX idx_lifecycle_animal ON animal_lifecycle(animal_id, event_date);
```

### File Location

```
/var/lib/ohm-ranch/herd.duckdb     # The herd database
/root/olympus/ranch/shared/herd/   # Schema, sync scripts, queries
```

## Data Flow Summary

```
Individual Events           Aggregates & Patterns         Reasoning & Decisions
(CRUD, mutable)            (Observations, append)        (Synthesis, challenge)

Herd DB ──sync──► OHM ──agents──► Decisions
  │                  │                              │
  │                  │                              │
  ▼                  ▼                              ▼
"Tag #83 BCS 4.5"  "15% herd below BCS 4.5"     "Drought + hay up + BCS down
"Calved March 3"   "Calving 3 days late avg"      = cull bottom 10% or contract
"Vaccinated 4/15"  "Vaccination rate 98%"          hay at $200/ton?"
```

## What This Means for Each Agent

| Agent | Reads From | Writes To | What They Need |
|-------|-----------|-----------|----------------|
| **Waylon** | Herd DB + OHM | Both | Full access: operational queries + strategic reasoning |
| **Slim** | Herd DB (field data) + OHM | Herd DB (BCS, observations) + OHM (alerts) | Animal-level field data, weather-cattle patterns |
| **Roy** | OHM (market, feed cost) + Herd DB (inventory) | OHM (market obs) | Supply chain decisions need both individual and aggregate |
| **Virgil** | Herd DB (labor, compliance) + OHM | Herd DB (regulatory records) + OHM (alerts) | H-2A records are in herd DB (they're tied to operations) |
| **Belle** | OHM (financial) + Herd DB (cost records) | OHM (financial obs) | Cost-per-head needs both feed costs (OHM) and animal counts (Herd DB) |

## Migration Path

1. **Phase 1:** Create `herd.duckdb` with schema above. Empty. Start using it for new records.
2. **Phase 2:** Build sync script (`herd_to_ohm.py`) that runs on heartbeat. Writes aggregates + threshold alerts.
3. **Phase 3:** Agents query Herd DB directly for operational questions, OHM for strategic questions.
4. **Phase 4:** Historical data import if migrating from paper/existing system.

No rush on Phase 2-4. Phase 1 (schema) can go in now so the structure exists when animals enter the system.