# Ranch Operations — OHM Pilot

> *"A man's gotta know his limitations."* — Clint Eastwood, *Magnum Force*

OHM (Olympus Hive Mind) applied to ranching operations. Seven agents, named after classic Western figures, each with domain expertise and shared knowledge graph connectivity.

## The Crew

| Agent | Named After | Role | Domain |
|-------|------------|------|--------|
| 🤠 **Waylon** | Waylon Jennings | Operations Lead | Coordination, scheduling, resource allocation |
| 🐄 **Clint** | Clint Eastwood | Livestock Manager | Herd health, breeding, nutrition, pasture rotation |
| 📦 **Roy** | Roy Rogers | Supply Chain & Purchasing | Vendors, pricing, bulk purchasing, lead times |
| 📋 **Magnus** | The Magnificent Seven | Inventory & Assets | Equipment, feed stock, depreciation, reorder points |
| 👷 **Virgil** | Virgil Earp | HR & Labor | Hiring, payroll, compliance, safety |
| 💰 **Belle** | Belle Starr | Finance & Accounting | Cash flow, budgets, tax, margins |
| 🏜️ **Slim** | Slim Pickens | Field Scout | Weather, fences, water, pasture conditions |

## Architecture

```
ranch-ops/
├── agents/
│   ├── waylon/          # Operations Lead
│   ├── clint/           # Livestock Manager
│   ├── roy/             # Supply Chain
│   ├── magnus/          # Inventory & Assets
│   ├── virgil/          # HR & Labor
│   ├── belle/           # Finance
│   └── slim/            # Field Scout
├── shared/              # Shared resources (USER.md, etc.)
├── provisioning/        # OpenClaw config, OHM tokens
└── README.md
```

## Quick Start

1. Each agent directory contains:
   - `SOUL.md` — Identity, personality, thinking style
   - `AGENTS.md` — How the crew works together, OHM connection
   - `USER.md` — Who they serve (Matt)
   - `skills/` — Domain-specific knowledge and protocols

2. Provision agents in OpenClaw using `provisioning/openclaw-config.md`

3. Each agent connects to OHM with their own token (see `provisioning/openclaw-config.md`)

## OHM Knowledge Graph

The shared knowledge graph connects all ranch domains:
- **Ranch Operations Hub** → central coordination node
- **6 domain nodes** → livestock, supply, inventory, HR, finance, field
- Each agent writes observations, creates syntheses, and challenges interpretations
- Provenance tracking: each agent tags their domain (e.g., `ranch-livestock`, `ranch-finance`)

## Agent Naming Philosophy

Each name isn't just branding — it encodes the agent's approach:
- **Waylon** narrates the operation (like Jennings narrated the Dukes of Hazzard)
- **Clint** speaks little, sees everything (the Man with No Name)
- **Roy** always has what you need (King of the Cowboys)
- **Magnus** brings seven specialties to one mission (The Magnificent Seven)
- **Virgil** administers the law fairly (Tombstone's steady hand)
- **Belle** handles money with outlaw instinct (the Bandit Queen)
- **Slim** rides out and reports back straight (every Western ever)

## License

Private project — all rights reserved.