# Health Protocol Scheduler

## Purpose
Manage vaccination schedules, treatment protocols, withdrawal time calculations, and disease surveillance. The veterinary coordination engine for the ranch.

## When to Use
- When scheduling vaccination rounds
- When calculating withdrawal clearance dates for treated animals
- When disease surveillance flags appear
- Before any cattle movement (AND-gate health check)
- When new animals arrive (receiving protocols)

## Vaccination Calendar

### Spring Processing (March-April)
- [ ] IBR/BVD (infectious bovine rhinotracheitis/bovine viral diarrhea)
- [ ] Clostridial 7-way (blackleg, malignant edema, etc.)
- [ ] Respiratory complex (BRD vaccine — viral + bacterial)
- [ ] Deworming (pour-on or injectable)
- [ ] Pregnancy check (if breeding season ended)
- [ ] Brand inspection / renewal (if applicable)

### Fall Processing (September-October)
- [ ] IBR/BVD booster
- [ ] Clostridial booster
- [ ] Pre-weaning vaccinations (2-3 weeks before weaning)
- [ ] Deworming
- [ ] Lice treatment (if needed)

### Calving Season (varies by region)
- [ ] Calf vaccination protocol (first round at 2-4 months)
- [ ] Calf booster (3-4 weeks after first round)
- [ ] Scours prevention in cows (pre-calving vaccination)
- [ ] Selenium/vitamin E supplementation (deficient areas)

## Withdrawal Time Calculator

When ANY medication is administered, calculate the exact clearance date:

```
Clearance Date = Treatment Date + Withdrawal Period + Buffer Day(s)

Buffer rules:
- Standard withdrawal: +1 day buffer (minimum)
- Organophosphate/external parasite: +2 days buffer
- Extra-label use (veterinary prescription): USE MAXIMUM withdrawal of drug class
- Unknown history: DEFAULT to maximum withdrawal for that drug class

Common withdrawal times:
  Penicillin (Procaine): 10 days (cattle)
  Oxytetracycline (LA-200): 28 days (injectable)
  Florfenicol (Nuflor): 28 days (injectable)
  Tulathromycin (Draxxin): 18 days (injectable)
  Ceftiofur (Excede): 13 days (injectable)
  Enrofloxacin (Baytril): 0 days (label) / 28 days (extra-label)
  Chlortetracycline (CTC): 0-2 days (varies by formulation)
  Ionophores (Rumensin/Bovatec): 0 days
  Melengestrol acetate (MGA): 0 days
  Dexamethasone: 2 days (injectable)
  Banamine (Flunixin): 3 days (injectable) / 4 days (oral)
```

**CRITICAL RULE:** When in doubt, use the LONGEST withdrawal time. Never ship an animal before withdrawal clearance. Violation = FDA enforcement + market trust damage.

## BRD (Bovine Respiratory Disease) Protocol

### Surveillance
- Daily pen checking: look for drooped ears, nasal discharge, lethargy, off-feed
- Temperature > 103.5°F → FLAG for treatment
- BRD rate > 10% in a pen → POPULATION ALERT, escalate to Scrub Oak

### Treatment Ladder
1. **First treatment:** Draxxin (tulathromycin) — 18-day withdrawal
2. **Second treatment (if relapse):** Excede (ceftiofur) — 13-day withdrawal  
3. **Third treatment (chronic):** Evaluate for chronic status → cull candidate

### BRD Rate Thresholds
| Rate | Status | Action |
|------|--------|--------|
| < 5% | Normal | Continue monitoring |
| 5-10% | Elevated | Increase pen checks, review ventilation |
| > 10% | Population alert | Mass treatment protocol, vet consultation |
| > 20% | Emergency | Full pen treatment, isolate, necropsy deads |

## Receiving Protocol (New Arrivals)

When cattle arrive:
1. **Unload** — assess immediately for obvious illness/injury
2. **Rest** — minimum 4 hours access to water and good hay before processing
3. **Process within 24 hours:**
   - [ ] Visual health assessment (BCS, lameness, respiratory signs)
   - [ ] Temperature check (sample 10%, flag > 103.5°F)
   - [ ] Vaccinate: IBR/BVD + Clostridial + BRD (if not pre-vaccinated)
   - [ ] Deworm
   - [ ] Ear tag / ID verification
   - [ ] Record: weight, BCS, health observations, source, arrival date
4. **Receiving ration** — long-stem hay for 3-5 days, then step up to receiving ration
5. **Monitor daily** for 14 days — BRD watch, coccidiosis check, feed intake tracking

## Output Format

```
🏥 HEALTH PROTOCOL CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━
Group: [description] | [head count] | [location]
Date: [date]

VACCINATION STATUS:
  IBR/BVD: ✅ Current (expires [date]) / ❌ Overdue (was due [date])
  Clostridial: ✅/❌
  BRD: ✅/❌
  Deworming: ✅/❌

WITHDRAWAL STATUS:
  [Drug] administered [date] → Clearance: [date]
  [Drug] administered [date] → Clearance: [date]
  Earliest market date: [date]

BRD WATCH:
  Current rate: [X]% ([threshold level])
  Last pen check: [date/time]

RECOMMENDED ACTIONS:
  - [Specific actions with dates]
```

## Integration
- Writes to OHM: `observation-health-[group]-[date]`
- Tags: `ranch-livestock`
- Coordinates with Clint for BCS/nutrition impact of treatments
- Coordinates with Waylon for movement clearance
- Coordinates with Belle for veterinary cost tracking