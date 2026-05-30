# Weather Impact Assessment

## Purpose
Assess weather conditions and forecasts for their impact on ranch operations: cattle welfare, pasture conditions, working conditions, and feed requirements.

## When to Use
- Daily operations brief (morning, automated)
- Before any cattle movement or working
- When extreme weather is forecast
- During calving season (heightened sensitivity)
- When planning feed deliveries or infrastructure work

## Temperature-Humidity Index (THI) for Cattle

| THI | Stress Level | Impact | Action |
|-----|-------------|--------|--------|
| < 68 | None | Comfortable | Normal operations |
| 68-72 | Mild | Slight feed intake reduction | Increase water access |
| 72-79 | Moderate | Reduced intake, increased respiration | Shade, misters, avoid handling |
| 79-83 | Severe | Significant production loss | NO working/cattle movement |
| > 83 | Emergency | Life-threatening heat stress | Emergency cooling, vet on standby |

**Calculation:** THI = Temperature(°F) - (0.55 × (1 - Humidity/100)) × (Temperature(°F) - 58)

**Critical:** Do NOT schedule cattle handling, transport, or working when THI > 79.

## Cold Stress Thresholds

| Wind Chill | Impact | Action |
|-----------|--------|--------|
| > 30°F | None | Normal |
| 30-18°F | Mild cold | Increase feed 10-20% |
| 18-0°F | Cold stress | Increase feed 20-30%, windbreaks critical |
| < 0°F | Severe cold | Emergency: increase feed 30%+, full windbreaks, watch for frostbite |
| < -20°F | Extreme | Emergency shelter, continuous monitoring |

**Special cases:**
- Wet cattle lose insulation — reduce thresholds by 15°F
- Newborn calves: hypothermia risk below 40°F, critical below 32°F
- During calving: check every 2 hours in cold conditions

## Pasture Impact Assessment

### Rain
- > 0.5" rain → postpone pasture rotation for 24-48 hours (hoof damage)
- Saturated ground → flag for Range, may need supplemental feeding location
- Extended dry (>14 days no rain) → drought monitoring protocol

### Wind
- Sustained > 25 mph → difficult for cattle handling, postpone working
- Sustained > 40 mph → infrastructure risk (fences, water tanks), inspection needed

### Severe Weather
- Tornado warning → EMERGENCY: livestock in open pastures are at extreme risk
- Flash flood watch → check low-water crossings on all routes
- Winter storm warning → 48-hour feed/water reserves needed, calving watch intensified

## Daily Weather Brief Format

```
🌤️ WEATHER ASSESSMENT — [DATE]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CURRENT CONDITIONS:
  Temp: [°F] | Humidity: [%] | THI: [XX] — [stress level]
  Wind: [mph] from [direction] | Precip: [inches]
  Conditions: [description]

48-HOUR FORECAST:
  Today: [high]/[low]°F, [conditions]
  Tomorrow: [high]/[low]°F, [conditions]
  Day 3: [high]/[low]°F, [conditions]

IMPACT ASSESSMENT:
  Cattle handling: ✅/⚠️/❌ [reason]
  Pasture rotation: ✅/⚠️/❌ [reason]
  Transport: ✅/⚠️/❌ [reason]
  Feed adjustment: [none/+10%/+20%/+30%]

ALERTS: [any threshold triggers]
RECOMMENDED ACTIONS: [specific recommendations]
```

## Integration
- Writes to OHM: `observation-weather-[date]`
- Tags: `ranch-field`, `ranch-operations`
- Feeds into Waylon's daily operations brief
- Coordinates with Clint for heat/cold stress feed adjustments
- Coordinates with Trail Boss for transport scheduling