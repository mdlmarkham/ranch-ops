# Ranch Agent Provisioning — OpenClaw Config

> **This is for a NEW, SEPARATE OpenClaw instance** — not the Olympus instance.
> Atlas will be building this on a fresh machine.
> The OHM instance is also separate (port 8711, not 8710).
> See `ohm-setup.md` for the OHM provisioning steps.

Add these agents to the **new OpenClaw instance's** `~/.openclaw/openclaw.json` under `agents.list`.

## Agent Definitions

```json5
// Add to agents.list array:
{
  id: "waylon",
  name: "Waylon",
  workspace: "/root/olympus/ranch/agents/waylon",
  model: {
    primary: "ollama/glm-5.1:cloud",
    fallbacks: ["ollama/kimi-k2.5:cloud", "synthetic/hf:zai-org/GLM-5.1"]
  },
  subagents: { allowAgents: ["clint", "roy", "magnus", "virgil", "belle", "slim", "main", "metis"] },
  tools: {
    allow: ["group:fs", "group:runtime", "group:sessions", "group:memory", "group:web", "group:messaging", "browser", "searxng_search"],
    exec: { security: "full", ask: "off" }
  },
  heartbeat: {
    every: "30m",
    target: "none",
    isolatedSession: true,
    lightContext: true,
    skipWhenBusy: true,
    activeHours: { start: "06:00", end: "23:00", timezone: "America/New_York" }
  }
},
{
  id: "clint",
  name: "Clint",
  workspace: "/root/olympus/ranch/agents/clint",
  model: {
    primary: "ollama/glm-5.1:cloud",
    fallbacks: ["ollama/kimi-k2.5:cloud", "synthetic/hf:zai-org/GLM-5.1"]
  },
  subagents: { allowAgents: ["waylon", "slim", "main", "metis"] },
  tools: {
    allow: ["read", "write", "edit", "exec", "web_search", "web_fetch", "browser", "sessions_list", "sessions_history", "sessions_send", "searxng_search", "memory_search", "memory_get"],
    exec: { security: "full", ask: "off" }
  },
  heartbeat: {
    every: "30m",
    target: "none",
    isolatedSession: true,
    lightContext: true,
    skipWhenBusy: true,
    activeHours: { start: "06:00", end: "23:00", timezone: "America/New_York" }
  }
},
{
  id: "roy",
  name: "Roy",
  workspace: "/root/olympus/ranch/agents/roy",
  model: {
    primary: "ollama/glm-5.1:cloud",
    fallbacks: ["ollama/kimi-k2.5:cloud", "synthetic/hf:zai-org/GLM-5.1"]
  },
  subagents: { allowAgents: ["waylon", "belle", "magnus", "main", "metis"] },
  tools: {
    allow: ["read", "write", "edit", "exec", "web_search", "web_fetch", "browser", "sessions_list", "sessions_history", "sessions_send", "searxng_search", "memory_search", "memory_get"],
    exec: { security: "full", ask: "off" }
  },
  heartbeat: {
    every: "30m",
    target: "none",
    isolatedSession: true,
    lightContext: true,
    skipWhenBusy: true,
    activeHours: { start: "06:00", end: "23:00", timezone: "America/New_York" }
  }
},
{
  id: "magnus",
  name: "Magnus",
  workspace: "/root/olympus/ranch/agents/magnus",
  model: {
    primary: "ollama/glm-5.1:cloud",
    fallbacks: ["ollama/kimi-k2.5:cloud", "synthetic/hf:zai-org/GLM-5.1"]
  },
  subagents: { allowAgents: ["waylon", "clint", "roy", "belle", "main", "metis"] },
  tools: {
    allow: ["read", "write", "edit", "exec", "web_search", "web_fetch", "sessions_list", "sessions_history", "sessions_send", "searxng_search", "memory_search", "memory_get"],
    exec: { security: "full", ask: "off" }
  },
  heartbeat: {
    every: "1h",
    target: "none",
    isolatedSession: true,
    lightContext: true,
    skipWhenBusy: true,
    activeHours: { start: "06:00", end: "23:00", timezone: "America/New_York" }
  }
},
{
  id: "virgil",
  name: "Virgil",
  workspace: "/root/olympus/ranch/agents/virgil",
  model: {
    primary: "ollama/glm-5.1:cloud",
    fallbacks: ["ollama/kimi-k2.5:cloud", "synthetic/hf:zai-org/GLM-5.1"]
  },
  subagents: { allowAgents: ["waylon", "belle", "main", "metis"] },
  tools: {
    allow: ["read", "write", "edit", "exec", "web_search", "web_fetch", "sessions_list", "sessions_history", "sessions_send", "searxng_search", "memory_search", "memory_get"],
    exec: { security: "full", ask: "off" }
  },
  heartbeat: {
    every: "1h",
    target: "none",
    isolatedSession: true,
    lightContext: true,
    skipWhenBusy: true,
    activeHours: { start: "06:00", end: "23:00", timezone: "America/New_York" }
  }
},
{
  id: "belle",
  name: "Belle",
  workspace: "/root/olympus/ranch/agents/belle",
  model: {
    primary: "ollama/glm-5.1:cloud",
    fallbacks: ["ollama/kimi-k2.5:cloud", "synthetic/hf:zai-org/GLM-5.1"]
  },
  subagents: { allowAgents: ["waylon", "roy", "magnus", "main", "metis"] },
  tools: {
    allow: ["read", "write", "edit", "exec", "web_search", "web_fetch", "browser", "sessions_list", "sessions_history", "sessions_send", "searxng_search", "memory_search", "memory_get"],
    exec: { security: "full", ask: "off" }
  },
  heartbeat: {
    every: "30m",
    target: "none",
    isolatedSession: true,
    lightContext: true,
    skipWhenBusy: true,
    activeHours: { start: "06:00", end: "23:00", timezone: "America/New_York" }
  }
},
{
  id: "slim",
  name: "Slim",
  workspace: "/root/olympus/ranch/agents/slim",
  model: {
    primary: "ollama/glm-5.1:cloud",
    fallbacks: ["ollama/kimi-k2.5:cloud", "synthetic/hf:zai-org/GLM-5.1"]
  },
  subagents: { allowAgents: ["waylon", "clint", "main", "metis"] },
  tools: {
    allow: ["read", "write", "exec", "web_search", "web_fetch", "searxng_search", "sessions_list", "sessions_history", "sessions_send", "memory_search", "memory_get"],
    exec: { security: "full", ask: "off" }
  },
  heartbeat: {
    every: "15m",
    target: "none",
    isolatedSession: true,
    lightContext: true,
    skipWhenBusy: true,
    activeHours: { start: "06:00", end: "23:00", timezone: "America/New_York" }
  }
}
```

## Post-Install Steps

1. Clone this repo on the new machine
2. Install OHM (see `provisioning/ohm-setup.md`)
3. Generate tokens: `./provisioning/generate-tokens.sh`
4. Add tokens to `/etc/ohm/ranch-ohmd.json` and the shared config
5. Start the Ranch OHM daemon: `systemctl start ohmd-ranch`
6. Seed the knowledge graph: `python3 provisioning/seed-ranch-ohm.py --token TOKEN`
7. Add the agent configs above to `openclaw.json`
8. Run `openclaw gateway restart` to pick up new agents
9. Verify each agent with `openclaw status`
10. Test OHM connectivity from each agent

## Important: Separate Environment

This pilot runs on its own OpenClaw instance with its own OHM:
- **OHM port:** 8711 (not 8710, which is Olympus)
- **DB:** `/var/lib/ohm-ranch/ohm.duckdb` (not `/var/lib/ohm/`)
- **DuckLake:** `/var/lib/ohm-ranch/ohm_lake.ducklake`
- **Tokens:** `ranch-{agent}-u0-...` prefix (not `ohm-`)

This keeps ranch operational data completely separate from Olympus analytics.