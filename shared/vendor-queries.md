# Vendor & Procurement Database Queries

## Purpose

The Vendor DB tracks who you buy from, what you pay, what you've ordered, and whether they delivered. It's the operational backbone for Roy (supply chain), Belle (finance), and Magnus (inventory).

**Rule:** If it's about a specific vendor, PO, contract, or invoice — it's the Vendor DB. If it's about *why* prices are moving or *whether* to switch suppliers — that's OHM.

## Connection

```python
import duckdb

VENDOR_DB = "/var/lib/ohm-ranch/vendor.duckdb"

def query_vendor(sql, params=None):
    """Read-only query against the vendor database."""
    con = duckdb.connect(VENDOR_DB, read_only=True)
    try:
        if params:
            result = con.execute(sql, params).fetchall()
            columns = [desc[0] for desc in con.description]
        else:
            result = con.execute(sql).fetchall()
            columns = [desc[0] for desc in con.description]
        return [dict(zip(columns, row)) for row in result]
    finally:
        con.close()
```

Or from the command line:

```bash
duckdb /var/lib/ohm-ranch/vendor.duckdb -readonly -c "SELECT * FROM vendors WHERE status='active'"
```

## Common Queries by Agent

### Roy (Supply Chain) — Primary User

```sql
-- Active vendors by category
SELECT v.short_name, v.vendor_type, v.payment_terms, v.status
FROM vendors v
WHERE v.status = 'active'
ORDER BY v.vendor_type, v.short_name;

-- Vendor scorecard summary (latest scores)
SELECT v.short_name, v.vendor_type, vs.score_date,
       vs.price_competitiveness, vs.reliability, vs.quality, vs.relationship,
       vs.total_score,
       CASE WHEN vs.total_score >= 14 THEN 'preferred'
            WHEN vs.total_score >= 10 THEN 'acceptable'
            ELSE 'review' END AS rating
FROM vendors v
JOIN vendor_scorecards vs ON v.id = vs.vendor_id
WHERE v.status = 'active'
  AND vs.score_date = (
      SELECT MAX(score_date) FROM vendor_scorecards WHERE vendor_id = v.id
  )
ORDER BY vs.total_score DESC;

-- Compare prices for a product across vendors
SELECT v.short_name, vp.current_price, vp.bulk_price, vp.bulk_minimum,
       vp.lead_time_days, vp.available, vp.price_as_of
FROM vendor_products vp
JOIN vendors v ON v.id = vp.vendor_id
JOIN products p ON p.id = vp.product_id
WHERE p.name ILIKE '%alfalfa%'
  AND v.status = 'active'
ORDER BY vp.current_price ASC;

-- Purchase orders needing follow-up
SELECT po.po_number, v.short_name, po.order_date, po.expected_delivery,
       po.status, po.total,
       CURRENT_DATE - po.expected_delivery AS days_overdue
FROM purchase_orders po
JOIN vendors v ON v.id = po.vendor_id
WHERE po.status IN ('submitted', 'confirmed', 'partial')
  AND po.expected_delivery < CURRENT_DATE
ORDER BY days_overdue DESC;

-- Active contracts expiring in next 90 days
SELECT v.short_name, c.contract_type, c.end_date, c.annual_value,
       c.renewal_date,
       c.end_date - CURRENT_DATE AS days_remaining
FROM contracts c
JOIN vendors v ON v.id = c.vendor_id
WHERE c.status = 'active'
  AND c.end_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 90
ORDER BY c.end_date;

-- Open POs by vendor
SELECT v.short_name, COUNT(*) AS open_pos, SUM(po.total) AS total_value
FROM purchase_orders po
JOIN vendors v ON v.id = po.vendor_id
WHERE po.status IN ('submitted', 'confirmed', 'partial')
GROUP BY v.short_name
ORDER BY total_value DESC;

-- Recent price history for a product (for trend analysis)
SELECT ph.price_date, v.short_name, ph.price, ph.price_unit, ph.source
FROM price_history ph
JOIN vendors v ON v.id = ph.vendor_id
JOIN products p ON p.id = ph.product_id
WHERE p.name ILIKE '%alfalfa%'
ORDER BY ph.price_date DESC
LIMIT 20;

-- Vendor interaction log (recent calls/visits)
SELECT v.short_name, vi.interaction_date, vi.interaction_type,
       vi.direction, vi.subject, vi.follow_up
FROM vendor_interactions vi
JOIN vendors v ON v.id = vi.vendor_id
WHERE vi.interaction_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY vi.interaction_date DESC;
```

### Belle (Finance)

```sql
-- Monthly spend by vendor
SELECT v.short_name, v.vendor_type,
       SUM(po.total) AS month_total,
       COUNT(*) AS po_count
FROM purchase_orders po
JOIN vendors v ON v.id = po.vendor_id
WHERE EXTRACT(YEAR FROM po.order_date) = EXTRACT(YEAR FROM CURRENT_DATE)
  AND EXTRACT(MONTH FROM po.order_date) = EXTRACT(MONTH FROM CURRENT_DATE)
GROUP BY v.short_name, v.vendor_type
ORDER BY month_total DESC;

-- Spend by category (for budget tracking)
SELECT p.category, SUM(poi.line_total) AS total_spend, COUNT(*) AS line_items
FROM purchase_order_items poi
JOIN products p ON p.id = poi.product_id
JOIN purchase_orders po ON po.id = poi.po_id
WHERE EXTRACT(YEAR FROM po.order_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY p.category
ORDER BY total_spend DESC;

-- Overdue invoices
SELECT v.short_name, i.invoice_number, i.invoice_date, i.due_date,
       i.total, i.status,
       CURRENT_DATE - i.due_date AS days_overdue
FROM invoices i
JOIN vendors v ON v.id = i.vendor_id
WHERE i.status IN ('received', 'approved')
  AND i.due_date < CURRENT_DATE
ORDER BY days_overdue DESC;

-- Contract spend vs. budget this year
SELECT c.contract_type, c.annual_value,
       COALESCE(SUM(po.total), 0) AS spent_ytd
FROM contracts c
LEFT JOIN purchase_orders po ON po.vendor_id = c.vendor_id
  AND po.order_date BETWEEN c.start_date AND LEAST(c.end_date, CURRENT_DATE)
WHERE c.status = 'active'
GROUP BY c.contract_type, c.annual_value
ORDER BY c.annual_value DESC;

-- Feed cost trend (last 12 months)
SELECT DATE_TRUNC('month', ph.price_date) AS month,
       p.name, p.category, AVG(ph.price) AS avg_price,
       MIN(ph.price) AS min_price, MAX(ph.price) AS max_price
FROM price_history ph
JOIN products p ON p.id = ph.product_id
WHERE p.category LIKE 'feed%'
  AND ph.price_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', ph.price_date), p.name, p.category
ORDER BY month, p.name;

-- Total procurement spend by month
SELECT DATE_TRUNC('month', po.order_date) AS month,
       SUM(po.total) AS total_spend,
       COUNT(*) AS po_count
FROM purchase_orders po
WHERE po.order_date >= CURRENT_DATE - INTERVAL '12 months'
  AND po.status NOT IN ('draft', 'cancelled')
GROUP BY DATE_TRUNC('month', po.order_date)
ORDER BY month;
```

### Magnus (Inventory)

```sql
-- Deliveries received this week
SELECT d.delivery_date, v.short_name, d.condition, d.carrier, d.received_by
FROM deliveries d
JOIN vendors v ON v.id = d.vendor_id
WHERE d.delivery_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY d.delivery_date DESC;

-- Items received vs. ordered (open POs with short shipments)
SELECT po.po_number, v.short_name, p.name,
       poi.quantity_ordered, poi.quantity_received,
       poi.quantity_ordered - poi.quantity_received AS short_by
FROM purchase_order_items poi
JOIN purchase_orders po ON po.id = poi.po_id
JOIN products p ON p.id = poi.product_id
JOIN vendors v ON v.id = po.vendor_id
WHERE poi.quantity_received < poi.quantity_ordered
  AND po.status IN ('partial', 'confirmed')
ORDER BY short_by DESC;

-- Products near reorder (based on delivery history)
SELECT p.name, p.category, p.minimum_order, p.lead_time_days,
       COALESCE(SUM(di.quantity_accepted), 0) AS received_last_30_days
FROM products p
LEFT JOIN delivery_items di ON di.product_id = p.id
LEFT JOIN deliveries d ON d.id = di.delivery_id
  AND d.delivery_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY p.id, p.name, p.category, p.minimum_order, p.lead_time_days
ORDER BY p.category, p.name;

-- Contract delivery compliance
SELECT v.short_name, c.contract_type, c.delivery_schedule,
       COUNT(d.id) AS deliveries_ytd,
       SUM(CASE WHEN d.condition = 'good' THEN 1 ELSE 0 END) AS on_spec,
       SUM(CASE WHEN d.condition IN ('damaged', 'short', 'rejected') THEN 1 ELSE 0 END) AS issues
FROM contracts c
JOIN vendors v ON v.id = c.vendor_id
LEFT JOIN deliveries d ON d.vendor_id = v.id
  AND d.delivery_date BETWEEN c.start_date AND CURRENT_DATE
WHERE c.status = 'active'
GROUP BY v.short_name, c.contract_type, c.delivery_schedule;
```

### Waylon (Operations Lead)

```sql
-- Full procurement dashboard
SELECT 'Active Vendors' AS metric, COUNT(*) AS value FROM vendors WHERE status = 'active'
UNION ALL
SELECT 'Active Contracts', COUNT(*) FROM contracts WHERE status = 'active'
UNION ALL
SELECT 'Open POs', COUNT(*) FROM purchase_orders WHERE status IN ('submitted', 'confirmed', 'partial')
UNION ALL
SELECT 'Overdue Invoices', COUNT(*) FROM invoices WHERE status IN ('received', 'approved') AND due_date < CURRENT_DATE
UNION ALL
SELECT 'Contracts Expiring 90d', COUNT(*) FROM contracts WHERE status = 'active' AND end_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 90;

-- Vendor performance summary (for quarterly review)
SELECT v.short_name, v.vendor_type,
       vs.total_score AS latest_score,
       COUNT(DISTINCT po.id) AS pos_ytd,
       COALESCE(SUM(po.total), 0) AS spend_ytd,
       SUM(CASE WHEN d.condition = 'good' THEN 1 ELSE 0 END) AS good_deliveries,
       SUM(CASE WHEN d.condition IN ('damaged', 'short', 'rejected') THEN 1 ELSE 0 END) AS problem_deliveries
FROM vendors v
LEFT JOIN vendor_scorecards vs ON v.id = vs.vendor_id
  AND vs.score_date = (SELECT MAX(score_date) FROM vendor_scorecards WHERE vendor_id = v.id)
LEFT JOIN purchase_orders po ON po.vendor_id = v.id
  AND EXTRACT(YEAR FROM po.order_date) = EXTRACT(YEAR FROM CURRENT_DATE)
LEFT JOIN deliveries d ON d.vendor_id = v.id
  AND EXTRACT(YEAR FROM d.delivery_date) = EXTRACT(YEAR FROM CURRENT_DATE)
WHERE v.status = 'active'
GROUP BY v.id, v.short_name, v.vendor_type, vs.total_score
ORDER BY spend_ytd DESC;

-- Top 10 vendors by spend this year
SELECT v.short_name, v.vendor_type, SUM(po.total) AS total_spend
FROM purchase_orders po
JOIN vendors v ON v.id = po.vendor_id
WHERE EXTRACT(YEAR FROM po.order_date) = EXTRACT(YEAR FROM CURRENT_DATE)
  AND po.status NOT IN ('draft', 'cancelled')
GROUP BY v.short_name, v.vendor_type
ORDER BY total_spend DESC
LIMIT 10;

-- Procurement alerts: contracts expiring, POs overdue, invoices past due
SELECT 'CONTRACT EXPIRING' AS alert_type, c.contract_number AS ref,
       v.short_name, c.end_date AS detail, NULL::DECIMAL AS amount
FROM contracts c JOIN vendors v ON v.id = c.vendor_id
WHERE c.status = 'active' AND c.end_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 60

UNION ALL

SELECT 'PO OVERDUE', po.po_number, v.short_name,
       po.expected_delivery::TEXT, po.total
FROM purchase_orders po JOIN vendors v ON v.id = po.vendor_id
WHERE po.status IN ('submitted', 'confirmed') AND po.expected_delivery < CURRENT_DATE

UNION ALL

SELECT 'INVOICE PAST DUE', i.invoice_number, v.short_name,
       i.due_date::TEXT, i.total
FROM invoices i JOIN vendors v ON v.id = i.vendor_id
WHERE i.status IN ('received', 'approved') AND i.due_date < CURRENT_DATE

ORDER BY alert_type, detail;
```

### Virgil (HR & Compliance)

```sql
-- Vendors requiring 1099 (payments > $600 this year)
SELECT v.name, v.tax_id, SUM(po.total) AS total_paid
FROM vendors v
JOIN purchase_orders po ON po.vendor_id = v.id
WHERE po.status NOT IN ('draft', 'cancelled')
  AND EXTRACT(YEAR FROM po.order_date) = EXTRACT(YEAR FROM CURRENT_DATE)
  AND po.payment_status = 'paid'
GROUP BY v.name, v.tax_id
HAVING SUM(po.total) > 600
ORDER BY total_paid DESC;

-- W-9 compliance (vendors without tax_id)
SELECT name, vendor_type, short_name
FROM vendors
WHERE status = 'active' AND (tax_id IS NULL OR tax_id = '');

-- Disputed invoices
SELECT v.short_name, i.invoice_number, i.invoice_date, i.total, i.status, i.notes
FROM invoices i
JOIN vendors v ON v.id = i.vendor_id
WHERE i.status = 'disputed'
ORDER BY i.invoice_date;
```

## Writing to the Vendor DB

**Roy writes:** purchase orders, price history, vendor interactions, scorecards
**Magnus writes:** delivery receipts, receiving records
**Belle writes:** invoices, payments
**Waylon writes:** contracts, vendor master data (approve new vendors)

```python
import duckdb

VENDOR_DB = "/var/lib/ohm-ranch/vendor.duckdb"

def write_vendor(sql, params=None):
    """Write to the vendor database."""
    con = duckdb.connect(VENDOR_DB, read_only=False)
    try:
        if params:
            con.execute(sql, params)
        else:
            con.execute(sql)
        con.commit()
    finally:
        con.close()

# Examples:

# Add a vendor
write_vendor("""
    INSERT INTO vendors (name, short_name, vendor_type, contact_name, phone, email, payment_terms)
    VALUES (?, ?, ?, ?, ?, ?, ?)
""", ['Valley Co-Op', 'Valley', 'feed', 'Jim Peterson', '555-0142', 'jim@valleycoop.com', 'Net 30'])

# Record a price quote
write_vendor("""
    INSERT INTO price_history (product_id, vendor_id, price_date, price, price_unit, source)
    VALUES ((SELECT id FROM products WHERE name ILIKE ?),
            (SELECT id FROM vendors WHERE short_name = ?),
            CURRENT_DATE, ?, ?, ?)
""", ['Alfalfa Hay Supreme', 'Valley', 245.00, 'ton', 'vendor_quote'])

# Create a purchase order
write_vendor("""
    INSERT INTO purchase_orders (po_number, vendor_id, order_date, expected_delivery, status, subtotal, tax, freight, total, created_by)
    VALUES (?, (SELECT id FROM vendors WHERE short_name = ?),
            CURRENT_DATE, CURRENT_DATE + 7, 'submitted', ?, 0, 0, ?, ?)
""", ['PO-2026-0043', 'Valley', 2450.00, 2450.00, 'roy'])

# Record a vendor scorecard
write_vendor("""
    INSERT INTO vendor_scorecards (vendor_id, score_date, price_competitiveness, reliability, quality, relationship, notes)
    VALUES ((SELECT id FROM vendors WHERE short_name = ?), CURRENT_DATE, ?, ?, ?, ?, ?)
""", ['Valley', 4, 5, 4, 3, 'Good hay quality, responsive, prices 5% above market average'])
```

## Sync to OHM

The `herd_to_ohm.py` sync pattern applies here too. Aggregate metrics flow from Vendor DB → OHM:

```python
# What syncs to OHM (not individual transactions)
g.observe(node_id="price-alfalfa-spot", ...)         # Price observations
g.observe(node_id="concept-ranch-supply", ...)        # Supply alerts
g.observe(node_id="concept-ranch-finance", ...)       # Cost trends

# What stays in Vendor DB (individual records)
# Purchase orders, invoices, deliveries, vendor scorecards
```

## Decision Framework

| Question Type | Database | Example |
|---------------|----------|---------|
| "Who sells alfalfa cheapest?" | Vendor DB | Compare vendor_products prices |
| "When is our hay contract up?" | Vendor DB | contracts.end_date |
| "Are we over budget on feed?" | Vendor DB → OHM | Spend in DB, margin analysis in OHM |
| "Should we switch suppliers?" | OHM | Pattern: quality declining + price rising |
| "Is hay price trending up?" | OHM | Price history accumulated as observations |
| "Did Smith Hay deliver on time?" | Vendor DB | deliveries table |

## Schema Quick Reference

| Table | What It Holds | Key Fields |
|-------|---------------|------------|
| `vendors` | Who you buy from | name, type, contact, payment_terms, status |
| `vendor_scorecards` | Vendor quality ratings | price, reliability, quality, relationship (1-5 each) |
| `products` | What you buy | name, category, unit, lead_time, shelf_life |
| `vendor_products` | Vendor-specific SKUs/prices | vendor_id + product_id, current_price, bulk_price |
| `purchase_orders` | POs | po_number, vendor, dates, status, total |
| `purchase_order_items` | PO line items | product, quantity, price, received |
| `contracts` | Supply contracts | vendor, type, dates, value, terms |
| `contract_prices` | Contract pricing tiers | product, price, volume_tier, effective dates |
| `price_history` | Price trends for OHM sync | product, vendor, date, price, source |
| `deliveries` | Receiving records | PO, date, condition, BOL |
| `delivery_items` | Received items | product, quantities accepted/rejected, lot#, expiry |
| `invoices` | Vendor invoices | invoice_number, vendor, dates, amounts, status |
| `vendor_interactions` | Call logs, visits, issues | date, type, subject, follow_up |

Full schema: `shared/vendor/schema.sql`
Architecture: `shared/herd-tracking-architecture.md`