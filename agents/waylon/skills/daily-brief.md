# Daily Operations Brief Generator

## Purpose
Aggregate all agent inputs into a structured morning brief for Matt. This is the ranch's daily operating picture — the single document that drives the day.

## When to Use
- Every morning (automated via heartbeat at 06:00)
- Before any major operation
- When conditions change significantly during the day

## Brief Format

```
🐂 BOS DAILY BRIEF — [DATE]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WEATHER (Slim)
  Today: [high]/[low]°F | [conditions] | THI: [XX] — [stress level]
  3-Day: [forecast summary]
  Alerts: [any severe weather, heat stress, cold stress]
  Impact: [handling ✅/⚠️/❌] | [transport ✅/⚠️/❌] | [pasture notes]

HERD STATUS (Clint)
  [Group A]: [head count] head | BCS avg [X.X] | ADG [X.X] lbs/day | Status
  [Group B]: [head count] head | BCS avg [X.X] | ADG [X.X] lbs/day | Status
  Health flags: [any BRD, injury, BCS < 4 flags]
  Withdrawal clearances: [any animals cleared for market this week]

MARKETS (Gavel)
  Live cattle: $[XX.XX]/cwt [▲/▼ $X.XX]
  Feeder cattle: $[XX.XX]/cwt [▲/▼ $X.XX]  
  Corn: $[X.XX]/bu [▲/▼ $X.XX]
  Basis: $[+/-X.XX]/cwt [widening/narrowing/stable]
  Cost of gain: $[X.XX]/lb | Margin: $[X.XX]/lb ([X]%)

FEED (Roy/Magnus)
  Current inventory: [tons] | Days on hand: [X]
  Pending orders: [any incoming deliveries]
  Price trends: [hay, grain, supplement movements]

OPERATIONS (Waylon)
  Scheduled today:
    - [Activity 1] — [time] — [personnel] — [status]
    - [Activity 2] — [time] — [personnel] — [status]
  Pending AND-gates:
    - [Movement/check description] — [blocking gate] — [responsible agent]
    
LABOR (Virgil)
  Available hands: [X]
  Scheduled work: [any specific assignments]
  Time-off/absences: [any]

FINANCE (Belle)
  Weekly cash position: $[XXX]
  Upcoming payments: [feed, veterinary, supplies]
  Margin trend: [improving/stable/compressing]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRIORITY ACTIONS:
  1. [Most important thing today]
  2. [Second most important]
  3. [Third]
  
DECISIONS NEEDED:
  - [Any AND-gate requiring Matt's input]
  - [Any financial threshold requiring Matt's approval]
```

## Data Sources by Agent

| Section | Primary Agent | Data Source |
|---------|-------------|-------------|
| Weather | Slim | Weather API + THI calculation |
| Herd Status | Clint | BCS assessments, health records, OHM observations |
| Markets | Gavel | CME futures, local cash, basis calculation |
| Feed | Roy/Magnus | Inventory tracking, pricing, orders |
| Operations | Waylon | OHM tasks, scheduled movements, AND-gate status |
| Labor | Virgil | Work schedule, availability |
| Finance | Belle | Cash flow, margin analysis |

## AND-Gate Escalation Rules

During the brief, any movement that has:
- ✅ All gates clear → Listed as "ready to execute"
- ⚠️ Yellow gates → Listed with recommendation, Waylon decides
- ❌ Any blocked gate → Escalated to Matt as a decision item

## Integration
- Written to OHM: `observation-daily-brief-[date]`
- Tags: `ranch-operations` (primary), plus relevant domain tags
- Distributed to all agents for context
- Archived daily for trend analysis