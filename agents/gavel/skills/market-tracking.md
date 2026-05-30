# Market Price Tracking & Alert Protocol

## Purpose
Monitor cattle markets, compute basis, track margin compression, and trigger alerts when conditions warrant action. The financial early-warning system for the ranch.

## When to Use
- Daily market check (automated via heartbeat)
- Before any sale or purchase decision
- When evaluating whether to hold or sell
- When feed cost projections change

## Markets to Track

### CME Futures
- **Live Cattle (LE)** — Front month and nearby months
- **Feeder Cattle (GF)** — Front month and nearby months  
- **Corn (ZC)** — Feed cost proxy, front month

### Cash Markets
- **Local auction barn** — Weekly report
- **Direct trade** — Regional weighted average
- **Cull cow** — Local processor pricing

### Key Derived Metrics
- **Basis** = Cash price - Futures price (local vs CME)
- **Cost of Gain** → from Clint's nutrition assessments
- **Breakeven** = (Purchase price + Total feeding cost) / Sale weight
- **Margin** = Market price - Breakeven

## Alert Thresholds

| Metric | Alert Level | Action |
|--------|------------|--------|
| Basis narrowing < -$2/cwt | ⚠️ WARNING | Review sale timing |
| Basis widening > +$5/cwt | ✅ OPPORTUNITY | Consider forward contracting |
| Cost of Gain > 95% of market | ⚠️ WARNING | Review feeding program with Clint |
| Cost of Gain > 100% of market | 🚨 CRITICAL | Escalate to Matt immediately |
| Corn futures +10% week-over-week | ⚠️ WARNING | Project feed cost impact |
| Live cattle futures -5% week-over-week | ⚠️ WARNING | Review hold/sell decision |
| Breakeven > market price | 🚨 CRITICAL | Stop adding cattle, review program |

## Price Check Format

```
📈 MARKET CHECK — [DATE]
━━━━━━━━━━━━━━━━━━━━━━━

CME LIVE CATTLE (LE):
  Front month (M26): $[XX.XX]/cwt  ▲/▼ [$X.XX]
  Nearby (N26): $[XX.XX]/cwt
  
CME FEEDER CATTLE (GF):
  Front month: $[XX.XX]/cwt  ▲/▼ [$X.XX]
  
CME CORN (ZC):
  Front month: $[X.XX]/bu  ▲/▼ [$X.XX]

CASH MARKET:
  Local auction: $[XX.XX]/cwt
  Direct trade: $[XX.XX]/cwt
  Basis: $[+/-X.XX]/cwt

MARGIN ANALYSIS:
  Current COG: $[X.XX]/lb
  Market price: $[X.XX]/lb
  Margin: $[X.XX]/lb ([X]%)

ALERTS: [any threshold triggers]
NEXT CHECK: [date/time]
```

## Hedging Decision Framework

When basis is favorable and margin is compressing:
1. **Forward contract** — Lock in price for up to 6 months out. Simplest, lowest risk.
2. **Put options** — Floor price while maintaining upside. Cost is the premium.
3. **LRP insurance** — USDA subsidized. Good for small producers. Check USDA RMA for current premiums.
4. **Do nothing** — Accept basis risk. Only when margins are healthy (>15% above breakeven).

**Authority:** Hedging decisions >$50K equivalent → MUST escalate to Matt.

## Integration
- Writes market data to OHM: `observation-market-[date]`
- Tags: `ranch-finance`, `ranch-operations`
- Coordinates with Belle for P&L tracking, Waylon for sale timing