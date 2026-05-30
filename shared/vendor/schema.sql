-- Ranch Vendor & Procurement Database Schema
-- DuckDB | Vendor management, purchase orders, contracts, price history
-- Complements Herd DB (animals) and OHM (reasoning)
-- Herd DB = individual animals | Vendor DB = individual transactions | OHM = patterns

-- ============================================================
-- VENDORS
-- ============================================================

CREATE TABLE IF NOT EXISTS vendors (
    id INTEGER PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    short_name VARCHAR(50),                    -- "Smith Hay", "Valley Co-Op"
    vendor_type VARCHAR(50) NOT NULL,          -- feed, vet, fuel, equipment, fencing, seed, chemical, labor, other
    contact_name VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(200),
    address TEXT,
    website VARCHAR(300),
    tax_id VARCHAR(50),                        -- EIN for 1099 tracking
    payment_terms VARCHAR(50),                  -- Net 30, COD, Prepay, etc.
    credit_limit DECIMAL(10,2),
    account_number VARCHAR(50),                -- Our account number with vendor
    notes TEXT,
    status VARCHAR(20) DEFAULT 'active',       -- active, inactive, do-not-use
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vendor scorecards (updated periodically)
CREATE TABLE IF NOT EXISTS vendor_scorecards (
    id INTEGER PRIMARY KEY,
    vendor_id INTEGER REFERENCES vendors(id),
    score_date DATE NOT NULL,
    price_competitiveness SMALLINT CHECK (price_competitiveness BETWEEN 1 AND 5),
    reliability SMALLINT CHECK (reliability BETWEEN 1 AND 5),       -- delivers on time
    quality SMALLINT CHECK (quality BETWEEN 1 AND 5),              -- product meets spec
    relationship SMALLINT CHECK (relationship BETWEEN 1 AND 5),    -- credit, flexibility, communication
    total_score SMALLINT GENERATED ALWAYS AS (
        COALESCE(price_competitiveness,0) + COALESCE(reliability,0) +
        COALESCE(quality,0) + COALESCE(relationship,0)
    ) STORED,
    notes TEXT,
    UNIQUE(vendor_id, score_date)
);

-- ============================================================
-- PRODUCTS & CATALOG
-- ============================================================

CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY,
    name VARCHAR(200) NOT NULL,                -- "Alfalfa Hay Supreme", "7-Way Clostridial"
    category VARCHAR(50) NOT NULL,             -- feed_hay, feed_grain, feed_supplement, vet_vaccine, vet_medicine, vet_supply, fuel, fencing, equipment, seed, chemical, hardware, other
    unit VARCHAR(20) NOT NULL,                 -- ton, bale, gallon, head_dose, bag, roll, each
    unit_weight_lbs DECIMAL(8,2),             -- Weight per unit for storage/freight planning
    species_target VARCHAR(50),                -- cattle, general, livestock
    minimum_order INTEGER,                     -- Minimum order quantity
    lead_time_days INTEGER,                    -- Typical lead time
    storage_requirements VARCHAR(100),         -- "refrigerated", "dry", "frozen", "none"
    shelf_life_days INTEGER,                   -- Shelf life in days (for expiry tracking)
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vendor-specific product listings (same product, different vendor SKUs/prices)
CREATE TABLE IF NOT EXISTS vendor_products (
    id INTEGER PRIMARY KEY,
    vendor_id INTEGER REFERENCES vendors(id),
    product_id INTEGER REFERENCES products(id),
    vendor_sku VARCHAR(100),
    vendor_description TEXT,
    current_price DECIMAL(10,2),              -- Current list price per unit
    price_unit VARCHAR(20),                   -- ton, bale, gallon, dose
    price_as_of DATE,                         -- When current_price was last verified
    bulk_price DECIMAL(10,2),                 -- Bulk/contract price per unit
    bulk_minimum INTEGER,                     -- Minimum quantity for bulk price
    available VARCHAR(20) DEFAULT 'yes',       -- yes, no, seasonal, backorder
    lead_time_days INTEGER,                   -- Vendor-specific lead time
    notes TEXT,
    UNIQUE(vendor_id, product_id)
);

-- ============================================================
-- PURCHASE ORDERS
-- ============================================================

CREATE TABLE IF NOT EXISTS purchase_orders (
    id INTEGER PRIMARY KEY,
    po_number VARCHAR(20) UNIQUE NOT NULL,     -- "PO-2026-0042"
    vendor_id INTEGER REFERENCES vendors(id),
    order_date DATE NOT NULL,
    expected_delivery DATE,
    actual_delivery DATE,
    status VARCHAR(20) DEFAULT 'draft',        -- draft, submitted, confirmed, partial, received, cancelled
    payment_status VARCHAR(20) DEFAULT 'unpaid', -- unpaid, partial, paid, overdue
    subtotal DECIMAL(10,2),
    tax DECIMAL(10,2),
    freight DECIMAL(10,2),
    total DECIMAL(10,2),
    payment_method VARCHAR(30),                -- check, wire, card, on-account
    payment_due_date DATE,
    payment_date DATE,                         -- When actually paid
    notes TEXT,
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Line items within a PO
CREATE TABLE IF NOT EXISTS purchase_order_items (
    id INTEGER PRIMARY KEY,
    po_id INTEGER REFERENCES purchase_orders(id),
    product_id INTEGER REFERENCES products(id),
    vendor_product_id INTEGER REFERENCES vendor_products(id),  -- Links to vendor-specific listing
    quantity_ordered DECIMAL(10,2) NOT NULL,
    quantity_received DECIMAL(10,2) DEFAULT 0,
    unit_price DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20),
    line_total DECIMAL(10,2),                  -- quantity_ordered × unit_price
    received_date DATE,
    notes TEXT
);

-- ============================================================
-- CONTRACTS
-- ============================================================

CREATE TABLE IF NOT EXISTS contracts (
    id INTEGER PRIMARY KEY,
    vendor_id INTEGER REFERENCES vendors(id),
    contract_number VARCHAR(50) UNIQUE,
    contract_type VARCHAR(50) NOT NULL,         -- feed_supply, hay_contract, fuel_contract, vet_service, equipment_lease, labor, grazing_lease, other
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    renewal_date DATE,                         -- Auto-renewal date, if applicable
    status VARCHAR(20) DEFAULT 'active',       -- draft, active, expiring, expired, terminated
    total_value DECIMAL(12,2),
    annual_value DECIMAL(10,2),
    payment_terms VARCHAR(100),
    delivery_schedule TEXT,                     -- "Monthly delivery of 20 tons hay, first Monday"
    performance_clause TEXT,                    -- Quality specs, penalties for non-delivery
    cancellation_clause TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Contract price schedules (volume-based or seasonal pricing)
CREATE TABLE IF NOT EXISTS contract_prices (
    id INTEGER PRIMARY KEY,
    contract_id INTEGER REFERENCES contracts(id),
    product_id INTEGER REFERENCES products(id),
    price DECIMAL(10,2) NOT NULL,
    price_unit VARCHAR(20),
    minimum_quantity DECIMAL(10,2),
    effective_from DATE,
    effective_to DATE,
    volume_tier VARCHAR(30),                   -- "base", "100+", "500+", etc.
    notes TEXT
);

-- ============================================================
-- PRICE HISTORY (for trend analysis → OHM)
-- ============================================================

CREATE TABLE IF NOT EXISTS price_history (
    id INTEGER PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    vendor_id INTEGER REFERENCES vendors(id),
    price_date DATE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    price_unit VARCHAR(20),
    quantity DECIMAL(10,2),                     -- Quantity at this price (for bulk tracking)
    source VARCHAR(50),                         -- vendor_quote, market_report, futures, auction, invoice
    notes TEXT,
    UNIQUE(product_id, vendor_id, price_date, source)
);

-- ============================================================
-- DELIVERIES & RECEIVING
-- ============================================================

CREATE TABLE IF NOT EXISTS deliveries (
    id INTEGER PRIMARY KEY,
    po_id INTEGER REFERENCES purchase_orders(id),
    vendor_id INTEGER REFERENCES vendors(id),
    delivery_date DATE NOT NULL,
    carrier VARCHAR(100),
    bol_number VARCHAR(50),                     -- Bill of lading
    driver_name VARCHAR(100),
    received_by VARCHAR(50),
    condition VARCHAR(30) DEFAULT 'good',      -- good, damaged, short, rejected
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS delivery_items (
    id INTEGER PRIMARY KEY,
    delivery_id INTEGER REFERENCES deliveries(id),
    po_item_id INTEGER REFERENCES purchase_order_items(id),
    product_id INTEGER REFERENCES products(id),
    quantity_delivered DECIMAL(10,2),
    quantity_accepted DECIMAL(10,2),
    quantity_rejected DECIMAL(10,2),
    rejection_reason VARCHAR(200),
    lot_number VARCHAR(50),                     -- For traceability
    expiry_date DATE,                           -- For perishable items
    storage_location VARCHAR(100),              -- "Hay barn", "Shop chemical cabinet"
    notes TEXT
);

-- ============================================================
-- INVOICES & PAYMENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS invoices (
    id INTEGER PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    vendor_id INTEGER REFERENCES vendors(id),
    po_id INTEGER REFERENCES purchase_orders(id),
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal DECIMAL(10,2),
    tax DECIMAL(10,2),
    total DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'received',      -- received, approved, paid, disputed, void
    payment_date DATE,
    payment_method VARCHAR(30),
    payment_ref VARCHAR(100),                   -- Check number, wire confirmation, etc.
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- VENDOR INTERACTIONS (calls, visits, issues)
-- ============================================================

CREATE TABLE IF NOT EXISTS vendor_interactions (
    id INTEGER PRIMARY KEY,
    vendor_id INTEGER REFERENCES vendors(id),
    interaction_date DATE NOT NULL,
    interaction_type VARCHAR(30) NOT NULL,      -- call, visit, email, text, meeting
    direction VARCHAR(10),                      -- inbound, outbound
    subject VARCHAR(200),
    details TEXT,
    follow_up DATE,                            -- Follow-up date if needed
    follow_up_done BOOLEAN DEFAULT FALSE,
    recorded_by VARCHAR(50)
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_vendors_type ON vendors(vendor_type);
CREATE INDEX IF NOT EXISTS idx_vendors_status ON vendors(status);
CREATE INDEX IF NOT EXISTS idx_vendor_products_vendor ON vendor_products(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_products_product ON vendor_products(product_id);
CREATE INDEX IF NOT EXISTS idx_po_vendor ON purchase_orders(vendor_id);
CREATE INDEX IF NOT EXISTS idx_po_status ON purchase_orders(status);
CREATE INDEX IF NOT EXISTS idx_po_date ON purchase_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_po_delivery ON purchase_orders(expected_delivery);
CREATE INDEX IF NOT EXISTS idx_po_items_po ON purchase_order_items(po_id);
CREATE INDEX IF NOT EXISTS idx_contracts_vendor ON contracts(vendor_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON contracts(status);
CREATE INDEX IF NOT EXISTS idx_contracts_dates ON contracts(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_price_history_product ON price_history(product_id, price_date);
CREATE INDEX IF NOT EXISTS idx_price_history_vendor ON price_history(vendor_id, price_date);
CREATE INDEX IF NOT EXISTS idx_price_history_date ON price_history(price_date);
CREATE INDEX IF NOT EXISTS idx_deliveries_date ON deliveries(delivery_date);
CREATE INDEX IF NOT EXISTS idx_deliveries_vendor ON deliveries(vendor_id);
CREATE INDEX IF NOT EXISTS idx_invoices_vendor ON invoices(vendor_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);
CREATE INDEX IF NOT EXISTS idx_invoices_due ON invoices(due_date);
CREATE INDEX IF NOT EXISTS idx_interactions_vendor_date ON vendor_interactions(vendor_id, interaction_date);