# Field Operations & Scouting Skill

## Purpose
Real-time field intelligence: weather monitoring, fence line inspection, water source management, pasture condition assessment. The scout who goes, looks, and reports.

## Daily Scout Protocol

### Morning Check (0600-0800)
1. **Weather**: Current conditions + 3-day forecast
2. **Fence lines**: Drive/walk perimeter sections (rotating daily)
3. **Water sources**: Check tank levels, creek flow, well pressure
4. **Pasture conditions**: Visual assessment by section
5. **Cattle locations**: Verify herd placement matches rotation plan

### Weather Monitoring

#### Sources (cross-reference 3+)
- NWS forecast (official)
- NOAA radar (precipitation)
- Local ag weather station (if available)
- Sky observation (ground truth)

#### Alert Thresholds
- **Temperature**: >95°F (heat stress) or <10°F (water freezing, calf risk)
- **Wind**: >30 mph (fence risk, equipment operation risk)
- **Precipitation**: >2" in 24 hours (flooding, pasture damage)
- **Severe weather**: Any tornado warning, hail >1", or flash flood watch

### Fence Line Inspection

#### Per Section
- Post condition (rotted, loose, leaning)
- Wire condition (broken, sagging, rusted)
- Gate function (latch, hinge, clearance)
- Creek crossing condition (washout, debris)

#### Severity Rating
1. **Routine**: Minor sag, cosmetic — schedule within 2 weeks
2. **Priority**: Wire down or post broken — repair within 48 hours
3. **Urgent**: Fence breach (cattle out or could get out) — repair immediately

### Water Source Assessment

| Source Type | Check | Alert Level |
|-------------|-------|-------------|
| Stock tank | Level, algae, heater | <50% capacity or algae bloom |
| Creek/river | Flow rate, debris, ice | Below seasonal norm or ice forming |
| Well | Pressure, clarity, pump | Any change in output or clarity |
| Pond | Level, algae, livestock access | <70% capacity or access erosion |

### Pasture Condition Scoring (1-10)

Score each section on:
- **Forage availability** (1=none, 10=abundant)
- **Forage quality** (1=dead/dormant, 10=peak green growing)
- **Utilization** (1=ungrazed, 10=overgrazed — target 5-6)
- **Weed pressure** (1=clean, 10=infested)
- **Soil moisture** (1=cracked dry, 10=saturated)

**Composite score**: Average of all factors. Target 5-7 for active grazing, 7-9 for rest.

## Reporting Format

```
FIELD REPORT — {DATE} {TIME}
Observer: Slim

WEATHER: [conditions], [forecast 3-day], [alerts]
FENCE: Section [X] - [condition rating] [notes]
       Section [Y] - [condition rating] [notes]
WATER: [Source] - [status] [concerns]
PASTURE: Section [A] - Score [X/10] [notes]
         Section [B] - Score [X/10] [notes]
CATTLE: [Location] [count] [condition notes]
ALERTS: [Any priority or urgent items]
```

## OHM Integration

Create nodes tagged `ranch-field` for:
- Weather events (significant shifts, storms, drought)
- Fence damage (location, severity, repair time)
- Water level changes (by source)
- Pasture condition scores (by section, monthly)

Write observations when:
- Weather alerts trigger (heat, cold, wind, precip thresholds)
- Fence damage detected
- Water levels drop below 50% or rise above flood stage
- Pasture composite score drops below 4 or exceeds 8