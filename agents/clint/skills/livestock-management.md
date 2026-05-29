# Livestock Management Skill

## Purpose
Manage herd health, breeding, nutrition, pasture rotation, and veterinary coordination for ranch cattle operations.

## Core Metrics

| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| Body Condition Score (BCS) | 5-6 (1-9 scale) | <4 or >7 |
| Conception Rate | >90% | <85% |
| Calf Death Loss | <3% | >5% |
| Weaning Weight (205d adjusted) | 550-650 lbs | <500 or >700 |
| Days to First Heat Post-Calving | <60 | >80 |
| Pasture Utilization | 50-60% | >75% (overgrazed) |

## Seasonal Calendar

### Spring (March-May)
- Calving season: Monitor every 2 hours during peak
- Vaccination: Pre-breeding shots 30 days before turnout
- Pasture: Assess winter damage, plan rotation schedule
- Nutrition: Transition from winter ration to spring grass

### Summer (June-August)
- Breeding season: Bull turnout, AI if applicable
- Pasture rotation: Move every 3-5 days in intensive grazing
- Fly control: Begin treatment program
- Heat stress: Monitor water consumption, provide shade

### Fall (September-November)
- Weaning: Process calves, vaccinate, background
- Pregnancy check: Palpation or ultrasound 45-60 days post-breeding
- Pre-winter nutrition: Increase energy ration
- Marketing: Evaluate cull candidates, price forecasts

### Winter (December-February)
- Nutrition: Highest energy demand period
- Calving prep: Clean calving areas, stage supplies
- Water: Monitor tank heaters, prevent freezing
- Bedding: Ensure adequate straw

## Veterinary Protocols

- **Annual**: BVD, IBR, PI3, BRSV, Lepto, Vibrio, Clostridial (7-way)
- **Pre-breeding (30 days)**: BVD, IBR, Lepto, Vibrio
- **Pre-calving (6 weeks)**: Scours vaccine (rotavirus, coronavirus, E. coli)
- **Processing calves**: Clostridial, BVD, IBR, castration, dehorning
- **Deworming**: Strategic (not calendar-based) — fecal egg counts first

## Pasture Rotation

- **Rest period**: Minimum 30 days between grazing events
- **Stocking rate**: Calculate based on forage availability (lbs DM/acre)
- **Graze period**: 3-5 days maximum per paddock
- **Recovery**: 30-45 days spring, 45-60 days summer, 60-90 days fall

## OHM Integration

Create nodes tagged `ranch-livestock` for:
- Health events (type, severity, treatment, outcome)
- Breeding records (sire, dam, AI/natural, conception)
- Pasture conditions (section, forage quality, utilization)
- Nutrition changes (ration adjustments, feed conversion)

Write observations when:
- BCS averages shift by >0.5
- Disease outbreaks (even single cases of reportable conditions)
- Calving complications exceed 3%
- Pasture utilization exceeds 75%