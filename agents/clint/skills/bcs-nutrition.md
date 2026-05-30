# BCS Scoring and Nutrition Protocol

## Purpose
Evaluate body condition, project feeding programs, and calculate cost of gain for cattle groups. The core nutritional decision support for the ranch.

## When to Use
- When assessing herd condition (monthly, or when flags appear)
- When designing a feeding program for a new group
- When evaluating whether to continue, modify, or cut a feeding program
- When cost of gain approaches or exceeds market price

## BCS Scale (1-9)

| Score | Description | Visual | Action |
|-------|-------------|--------|--------|
| 1 | Emaciated | Emaciated, no fat, skeletal | IMMEDIATE vet + supplemental feeding |
| 2 | Thin | Borderline, visible ribs/spine | Aggressive nutrition intervention |
| 3 | Very Thin | Thin, no fat cover | Increase energy density |
| 4 | Thin | Slight fat cover, ribs still visible | Supplemental feeding program |
| 5 | Moderate | Acceptable, slight rib coverage | Maintain for maintenance |
| 6 | Good | Good fat cover, ribs not visible | Ideal for most production stages |
| 7 | Very Good | Fat over ribs, brisket filling | Monitor — may be over-conditioned |
| 8 | Obese | Very fat, brisket heavy | Reduce energy, increase exercise |
| 9 | Extremely Obese | Extremely fat | Aggressive reduction, vet consult |

**Thresholds:**
- BCS < 4 → Flag for supplemental feeding (URGENT)
- BCS 4-5 → Adjust ration upward
- BCS 5-6 → Maintain
- BCS > 7 → Reduce energy intake

## Feeding Program Design

### Stocker/Backgrounding (300-600 lbs gain target)
- Target ADG: 1.5-2.5 lbs/day
- Ration: 60-70% roughage, 30-40% concentrate
- Key metrics: Cost/lb gain, days on feed, total gain projected

### Finishing (market weight target)
- Target ADG: 3.0-4.0 lbs/day
- Ration: 40-50% roughage, 50-60% concentrate (stepping up)
- Key metrics: Cost/lb gain, feed conversion ratio, yield grade projection

### Cost of Gain Calculation
```
Cost of Gain ($/lb) = Total Feed Cost / Total Weight Gain

Where:
  Total Feed Cost = (Daily Ration Cost × Days on Feed) + Yardage + Health Costs
  Total Weight Gain = ADG × Days on Feed

CRITICAL: Compare Cost of Gain vs Market Price
  If COG > Market Price → FLAG FOR REVIEW
  If COG > 95% of Market Price → WARNING (margin compression)
```

## Nutrition Decision Flow

```
1. Assess current BCS distribution in group
2. Determine target BCS and target date
3. Calculate days available = (target date) - (today)
4. Calculate required ADG = (target weight - current weight) / days available
5. If required ADG > 4.0 → NOT ACHIEVABLE, extend timeline or reduce target
6. Design ration for required ADG
7. Calculate cost of gain
8. Compare COG to market price projection
9. If COG > market price → ESCALATE to Belle + Gavel
10. If COG OK → Submit feeding program to Roy for procurement
```

## Withdrawal Time Integration
- Any ration change involving medicated feed → check withdrawal times with Scrub Oak
- Ionophores (Rumensin/Bovatec): 0 days withdrawal
- Tylosin (Tylan): 0 days withdrawal  
- Chlortetracycline (CTC): varies by formulation, typically 0-2 days
- Any therapeutic treatment → ALWAYS verify withdrawal with Scrub Oak before marketing

## Output Format

```
📊 BCS & NUTRITION ASSESSMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Group: [description] | [head count] head | [location]
Date: [assessment date]

Current BCS Distribution:
  BCS 3: [X] head ([%])
  BCS 4: [X] head ([%])
  BCS 5: [X] head ([%])
  BCS 6: [X] head ([%])

Target: BCS [target] by [date]
Required ADG: [X.X] lbs/day
Days available: [X]

Proposed Ration:
  [Ration details with cost per head per day]

Projected Cost of Gain: $[X.XX]/lb
Current Market Price: $[X.XX]/lb
Margin: $[X.XX]/lb ([%] of market)

⚠️/✅ Status: [ASSESSMENT]
```

## Integration
- Writes observations to OHM: `observation-bcs-[group]-[date]`
- Tags: `ranch-livestock`, `ranch-supply`, `ranch-finance`
- Coordinates with Roy for feed procurement, Belle for cost tracking, Scrub Oak for withdrawal verification