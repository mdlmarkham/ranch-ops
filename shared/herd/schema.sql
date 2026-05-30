-- Ranch Herd Database Schema
-- DuckDB | Cradle-to-grave animal tracking
-- Complements OHM (knowledge graph) for individual entity records
-- OHM gets aggregates; this holds the ground truth per animal

-- Core animal table
CREATE TABLE IF NOT EXISTS animals (
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
CREATE TABLE IF NOT EXISTS animal_weights (
    id INTEGER PRIMARY KEY,
    animal_id INTEGER REFERENCES animals(id),
    weight_date DATE NOT NULL,
    weight_lbs DECIMAL(6,1) NOT NULL,
    method VARCHAR(20) DEFAULT 'scale',     -- scale, estimate, tape
    notes TEXT,
    UNIQUE(animal_id, weight_date, method)
);

-- Body condition scoring
CREATE TABLE IF NOT EXISTS animal_bcs (
    id INTEGER PRIMARY KEY,
    animal_id INTEGER REFERENCES animals(id),
    bcs_date DATE NOT NULL,
    bcs DECIMAL(2,1) NOT NULL CHECK (bcs BETWEEN 1.0 AND 9.0),
    observer VARCHAR(50),
    notes TEXT,
    UNIQUE(animal_id, bcs_date)
);

-- Health events
CREATE TABLE IF NOT EXISTS animal_health (
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
CREATE TABLE IF NOT EXISTS animal_vaccinations (
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
CREATE TABLE IF NOT EXISTS animal_breeding (
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
CREATE TABLE IF NOT EXISTS animal_calvings (
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
CREATE TABLE IF NOT EXISTS animal_movements (
    id INTEGER PRIMARY KEY,
    animal_id INTEGER REFERENCES animals(id),
    move_date DATE NOT NULL,
    from_pasture VARCHAR(50),
    to_pasture VARCHAR(50),
    reason VARCHAR(100),
    moved_by VARCHAR(50)
);

-- Lifecycle events (the cradle-to-grave audit trail)
CREATE TABLE IF NOT EXISTS animal_lifecycle (
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
CREATE INDEX IF NOT EXISTS idx_animals_status ON animals(status);
CREATE INDEX IF NOT EXISTS idx_animals_pasture ON animals(current_pasture);
CREATE INDEX IF NOT EXISTS idx_weights_animal_date ON animal_weights(animal_id, weight_date);
CREATE INDEX IF NOT EXISTS idx_bcs_animal_date ON animal_bcs(animal_id, bcs_date);
CREATE INDEX IF NOT EXISTS idx_health_animal_date ON animal_health(animal_id, event_date);
CREATE INDEX IF NOT EXISTS idx_vax_animal_date ON animal_vaccinations(animal_id, vaccine_date);
CREATE INDEX IF NOT EXISTS idx_breeding_animal ON animal_breeding(animal_id, season);
CREATE INDEX IF NOT EXISTS idx_calvings_dam ON animal_calvings(dam_id, calving_date);
CREATE INDEX IF NOT EXISTS idx_lifecycle_animal ON animal_lifecycle(animal_id, event_date);