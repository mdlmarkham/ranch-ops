# Inventory & Asset Tracking Skill

## Purpose
Track every physical asset on the ranch: equipment, vehicles, fencing, feed inventory, tools, and supplies. Manage depreciation, maintenance schedules, and reorder points.

## Asset Categories

| Category | Track Method | Depreciation | Reorder Point |
|----------|-------------|-------------|---------------|
| Vehicles (trucks, ATVs, tractors) | VIN, hours, fuel log | MACRS 5yr | Replace at 8,000 hrs or 15 years |
| Equipment (sprayers, balers, mowers) | Serial, hours, maintenance log | MACRS 7yr | Replace when maintenance >30% of replacement |
| Fencing | Section map, post count, wire gauge | Straight-line 15yr | Inspect quarterly, replace sections as needed |
| Feed stock | Weight, bale count, age | N/A (expense) | Reorder at 30-day supply |
| Fuel | Gallons, storage capacity | N/A (expense) | Reorder at 50% capacity |
| Veterinary supplies | Expiry tracking, count | N/A (expense) | Reorder at 14-day supply |
| Tools & hardware | Count, condition | N/A (expense) | Reorder at minimum count |

## Inventory Count Protocol

### Daily
- Fuel levels (bulk tank + vehicle tanks)
- Feed consumption (by head count × daily ration)
- Critical spare parts count

### Weekly
- Full feed inventory (hay bales, grain bins, supplement)
- Veterinary supply count
- Fuel consumption vs. budget

### Monthly
- Complete physical inventory
- Equipment hours and condition assessment
- Fencing condition by section

### Quarterly
- Depreciation schedule update
- Asset valuation review
- Capital expenditure planning

## Maintenance Scheduling

### Preventive Maintenance Intervals
- **Tractors**: Oil every 250 hrs, filters every 500 hrs, major service every 1,000 hrs
- **Trucks**: Oil every 5,000 miles, tires every 40,000 miles, brakes inspected every 20,000
- **Sprayers**: Clean after every use, calibrate monthly, rebuild pumps annually
- **Fencing**: Drive lines monthly (weather permitting), repair within 24 hours of detection

### Maintenance Cost Threshold
- **< $500**: Approve and execute same day
- **$500 - $2,000**: Flag for Waylon, schedule within 3 days
- **> $2,000**: Route to Belle for budget review, schedule within 1 week (or emergency)

## OHM Integration

Create nodes tagged `ranch-inventory` for:
- Asset acquisitions, disposals, transfers
- Maintenance events (scheduled, emergency, deferred)
- Inventory level changes at reorder points
- Depreciation milestones

Write observations when:
- Inventory hits reorder point
- Equipment goes down (unscheduled maintenance)
- Asset value shifts (major repair, market price change)
- Shrinkage or loss detected