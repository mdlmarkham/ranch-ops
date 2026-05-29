# Supply Chain & Purchasing Skill

## Purpose
Manage vendor relationships, bulk purchasing, seasonal procurement, price tracking, and supply chain risk for ranch operations.

## Core Purchasing Categories

| Category | Annual Budget % | Lead Time | Key Vendors |
|----------|-----------------|-----------|-------------|
| Feed (hay, grain, supplements) | 35-45% | 1-2 weeks (spot), 3-6 months (contract) | Local co-ops, direct from producers |
| Veterinary supplies | 8-12% | 2-5 days (routine), 1-2 weeks (specialty) | Vet distributors, online pharmaceuticals |
| Fuel & lubricants | 10-15% | 1-3 days | Bulk fuel suppliers, cardlock |
| Fencing materials | 5-8% | 1-2 weeks | Agricultural suppliers, bulk wire dealers |
| Equipment parts | 8-12% | 1 day (common) to 4 weeks (specialty) | Dealership, aftermarket, salvage |
| Crop inputs (seed, fertilizer, chemical) | 10-15% | Seasonal — order early | Co-op, direct from manufacturers |

## Price Tracking Protocol

### Daily Price Points
- **Hay**: Local auction prices, USDA hay reports (weekly)
- **Grain**: CBOT futures for corn, soybean meal spot
- **Fuel**: OPIS rack prices, local cardlock pricing
- **Cattle**: CME live cattle futures, local auction weighted averages

### Bulk Purchasing Rules

1. **Feed**: Buy 6-month supply in summer when prices dip. Never buy hay in winter unless emergency.
2. **Fuel**: Contract 60% of annual need, spot-buy the rest. Monitor seasonal dips.
3. **Vet supplies**: Bulk-buy vaccines pre-season. Maintain 30-day emergency stock.
4. **Fencing**: Buy wire and posts in late winter before spring rush.
5. **Equipment parts**: Keep critical spares on-hand (belts, filters, hydraulic hoses).

## Vendor Scorecard

For each major vendor, track:
- **Price competitiveness** (1-5): How do they compare to market?
- **Reliability** (1-5): Do they deliver on time?
- **Quality** (1-5): Product meets spec consistently?
- **Relationship** (1-5): Do they hold orders, extend credit, work with us?
- **Total score ≥ 14** = preferred vendor

## OHM Integration

Create nodes tagged `ranch-supply` for:
- Price shifts (commodity, category, % change)
- Vendor changes (new, dropped, terms changed)
- Supply disruptions (shortages, delays, quality issues)
- Contract milestones (signing, delivery, renewal)

Write observations when:
- Feed prices shift >5% in a week
- Fuel prices shift >10%
- Lead times extend beyond normal range
- New vendor becomes available or preferred vendor drops quality