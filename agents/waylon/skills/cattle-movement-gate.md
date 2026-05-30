# Cattle Movement AND-Gate Checker

## Purpose
Evaluate a proposed cattle movement against ALL required conditions before execution. Every cattle move is a multi-agent AND-gate: ALL conditions must resolve before the move can proceed.

## When to Use
- Any proposed cattle movement (pasture rotation, transport to sale, feedlot receiving, veterinary transfer)
- When Waylon or Trail Boss asks "can we ship the X group?"
- When scheduling weekly movement plans

## AND-Gate Checklist

For any movement, check ALL of the following gates:

### 1. Health Gate (Scrub Oak domain)
- [ ] Current vaccination status for origin and destination
- [ ] Brand inspection requirements met
- [ ] Health certificates valid (CVI within 30 days for interstate)
- [ ] Drug withdrawal periods cleared (minimum: withdrawal time + 1 day buffer)
- [ ] No active disease quarantines on origin or destination
- [ ] Pregnancy status verified (if applicable for the move type)

### 2. Transport Gate (Trail Boss domain)
- [ ] Truck/trailer availability confirmed for date
- [ ] Driver certified (CDL if over 26,000 lbs GVW)
- [ ] Route planned (avoid extreme heat >95°F, check road conditions)
- [ ] Loading facilities available and in safe condition
- [ ] Estimated transit time within welfare guidelines (<8 hours without rest for adult cattle)
- [ ] Emergency contacts and vet on route

### 3. Destination Gate (Range domain)
- [ ] Receiving pasture/pen available and prepared
- [ ] Water access verified at destination
- [ ] Feed available at destination (ration matched to animal class)
- [ ] Fence/facilities in good repair
- [ ] No conflicting occupancy at destination

### 4. Market Gate (Gavel domain)
- [ ] Market timing favorable (or acceptable if mandatory move)
- [ ] Basis level checked (local vs futures)
- [ ] Sale barn schedule confirmed (if going to auction)
- [ ] Buyer confirmed (if direct sale)
- [ ] Price lock or hedge in place (if applicable)

### 5. Compliance Gate (Purse domain)
- [ ] All required documentation prepared
- [ ] Interstate movement permits (if crossing state lines)
- [ ] Brand inspection scheduled
- [ ] Insurance coverage confirmed for transit
- [ ] Record-keeping requirements met (API, age verification, source verification)

### 6. Weather Gate (Slim domain)
- [ ] 48-hour forecast acceptable for move date
- [ ] Heat stress index below danger threshold (THI < 79 for loading)
- [ ] No severe weather warnings for route or destination
- [ ] Ground conditions suitable (not excessive mud at either end)

## Output Format

```
🔍 MOVEMENT AND-GATE CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━
Proposed: [description] | [head count] head | [date]
Origin: [pasture/facility] → Destination: [pasture/facility]

✅ Health Gate: CLEAR
  - CVI valid through [date]
  - Withdrawal cleared: [details]
  
⚠️ Transport Gate: YELLOW
  - Truck confirmed for [date]
  - ❌ Driver CDL verification pending
  
✅ Destination Gate: CLEAR
✅ Market Gate: CLEAR
❌ Compliance Gate: BLOCKED
  - Interstate permit #TX-2026-XXXX not yet approved
✅ Weather Gate: CLEAR

OVERALL: ❌ BLOCKED
Blocking conditions: 1 compliance, 1 transport
Next action: [specific recommendation]
```

## Decision Authority
- **All gates CLEAR** → Waylon authorizes, Trail Boss executes
- **YELLOW gates only** → Waylon decides with Matt's input
- **Any RED/BLOCKED gate** → MUST escalate to Matt before proceeding

## Integration
- Writes gate status to OHM: `observation-movement-check-{id}`
- Tags: `ranch-operations`, `ranch-livestock`, `ranch-field`
- Coordinates with relevant agents based on which gates are relevant