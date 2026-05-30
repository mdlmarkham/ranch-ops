# Financial Threshold Monitor

## Purpose
Track ranch financial health in real-time. Monitor margin compression, cost of gain vs market price, cash flow, and regulatory deadlines. The only agent with veto authority over cattle movements on compliance/financial grounds.

## When to Use
- Daily margin check (automated)
- Before any cattle sale or purchase
- When feed costs change
- When market prices move >3% in a week
- Monthly P&L review
- Before any expenditure > $5,000

## Key Financial Metrics

### Cost of Gain (COG)
```
COG ($/lb) = (Feed Cost + Yardage + Health + Other) / Total Weight Gain

Components:
  Feed Cost = Ration cost ($/head/day) × Days on feed
  Yardage = Facility cost ($/head/day) × Days on feed  
  Health = Veterinary + medication per head
  Other = Death loss, shrink, interest on inventory
```

### Breakeven
```
Breakeven ($/cwt) = (Purchase Cost + Total Production Cost) / Sale Weight (cwt)

Where:
  Purchase Cost = Cost of animal at acquisition
  Total Production Cost = Feed + Yardage + Health + Interest + Death Loss
  Sale Weight = Projected sale weight in cwt
```

### Margin Analysis
```
Gross Margin ($/head) = (Sale Price × Sale Weight) - (Purchase Cost + Production Cost)
Margin % = Gross Margin / Total Cost × 100

Thresholds:
  Margin > 20%: ✅ HEALTHY
  Margin 10-20%: ⚠️ WATCH — review feed costs, market timing
  Margin 5-10%: 🔴 TIGHT — consider early marketing or hedging
  Margin < 5%: 🚨 CRITICAL — STOP adding inventory, review entire program
```

## Cash Flow Tracking

### Weekly Cash Position
- Opening balance
- Receivables (cattle sold, not yet collected)
- Payables (feed, veterinary, supplies, labor)
- Projected closing balance

### Monthly P&L Categories
| Category | Typical % of Revenue | Alert Threshold |
|----------|---------------------|-----------------|
| Feed | 60-70% | > 75% — REVIEW |
| Yardage | 3-5% | > 7% — REVIEW |
| Health/Vet | 2-4% | > 6% — DISEASE ALERT |
| Labor | 5-8% | > 12% — REVIEW |
| Interest | 2-4% | > 6% — REVIEW |
| Death loss | 1-2% | > 3% — CRITICAL |
| Net margin | 5-15% | < 5% — CRITICAL |

## Regulatory Calendar

Track these compliance deadlines:
- **Brand inspection renewal** — annual (state-specific)
- **Pesticide applicator license** — renewal varies by state
- **Water quality reports** — if applicable
- **Tax payments** — quarterly estimates, annual filing
- **USDA record requirements** — ongoing (source verification, age verification)
- **Insurance renewals** — cattle mortality, liability, property
- **Employee tax/reporting** — if applicable (Virgil domain, Belle tracks)

**Veto Rule:** Purse can VETO any cattle movement if:
1. Health certificates are expired or missing
2. Insurance coverage has lapsed
3. Required regulatory filings are overdue
4. Financial margins are below critical threshold AND no hedging is in place

## Financial Alert Format

```
💰 FINANCIAL THRESHOLD CHECK — [DATE]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MARGIN ANALYSIS:
  Current group: [description]
  Breakeven: $[XX.XX]/cwt
  Market: $[XX.XX]/cwt
  Margin: $[X.XX]/cwt ([X]%)
  Trend: [improving/stable/compressing] over last [X] days

COST BREAKDOWN ($/head):
  Purchase: $[XXX]
  Feed: $[XXX] ([X]% of total)
  Yardage: $[XX]
  Health: $[XX]
  Interest: $[XX]
  Other: $[XX]
  ─────────────────
  Total: $[XXXX]

ALERTS:
  [Any threshold triggers with severity]

RECOMMENDED ACTIONS:
  [Specific hedging, marketing, or cost-reduction recommendations]
```

## Integration
- Writes to OHM: `observation-financial-[date]`
- Tags: `ranch-finance`, `ranch-operations`
- Coordinates with Gavel for market timing
- Coordinates with Clint for COG updates
- Coordinates with Roy for feed cost projections
- Veto authority on compliance-blocking movements