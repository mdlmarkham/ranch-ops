# Finance & Accounting Skill

## Purpose
Manage cash flow, budgets, tax planning, cost analysis, and margin tracking for ranch operations. Ensure the ranch stays solvent and profitable.

## Core Financial Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Net Ranch Income | Positive annually | <0 (any single year) |
| Operating Expense Ratio | <65% of gross | >75% |
| Cost per Cow (annual) | <$900 | >$1,100 |
| Breakeven on Calves ($/lb) | <market price | Within $0.10 of market |
| Current Ratio (current assets/liabilities) | >2.0 | <1.5 |
| Debt-to-Asset Ratio | <0.30 | >0.45 |
| Cash Flow (30-day) | Positive | <14 days of expenses |

## Enterprise Accounting

Track each enterprise separately:

### Cow-Calf
- Revenue: Calf sales, cull cow sales
- Direct costs: Feed, vet, breeding, pasture maintenance
- Overhead allocation: % of total based on head count

### Stockers (if applicable)
- Revenue: Gain-based sales
- Direct costs: Purchase cost, feed, health, pasture
- Margin: Cost of gain vs. sale price per lb

### Hay (if selling)
- Revenue: Bale sales
- Direct costs: Fertilizer, equipment, labor
- Opportunity cost: Could be feeding own cattle

### Custom Work (if offering)
- Revenue: Per-acre or per-hour rates
- Direct costs: Fuel, equipment wear, labor

## Cash Flow Calendar

| Month | Inflows | Outflows | Net |
|-------|---------|----------|-----|
| Jan | Minimal | Feed, equipment payments | Negative |
| Feb | Cull cow sales | Calving supplies, vet | Slightly negative |
| Mar | Tax refund? | Spring fertilizer, seed | Negative |
| Apr | Minimal | Fuel, fencing supplies | Negative |
| May | Hay sales (if surplus) | Seasonal labor, equipment | Variable |
| Jun | Hay sales | Fuel, spray, labor | Slightly positive |
| Jul | Minimal | Feed, vet, insurance | Negative |
| Aug | Minimal | Fuel, equipment maintenance | Negative |
| Sep | Minimal | Pre-weaning supplies | Negative |
| Oct | Calf sales (big month!) | Fall supplies | Positive |
| Nov | Cull cow sales | Winter feed prep | Positive |
| Dec | Year-end tax planning | Property tax, insurance | Variable |

## Tax Planning

### Key Deductions
- Section 179: Up to $1.16M equipment expensing (2026)
- Bonus depreciation: 40% (2026, phasing down)
- Feed expense: Deduct when purchased (cash basis) or consumed (accrual)
- Prepaid expenses: Up to 50% of total schedule C deductions
- Conservation easements: Permanent deduction for qualified land

### Estimated Tax Calendar
- **Jan 15**: Q4 estimated payment
- **Apr 15**: Q1 estimated payment + annual return
- **Jun 15**: Q2 estimated payment
- **Sep 15**: Q3 estimated payment

## OHM Integration

Create nodes tagged `ranch-finance` for:
- Cash flow projections (weekly updates)
- Commodity price shifts (cattle, feed, fuel)
- Budget variances (monthly, by enterprise)
- Tax planning milestones

Write observations when:
- Cash position drops below 14-day expense coverage
- Commodity prices shift >5% (cattle, feed, fuel)
- Budget variances exceed 10% in any enterprise
- Loan covenant thresholds approach