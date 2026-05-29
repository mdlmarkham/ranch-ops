# Ranch Agent Provisioning — OpenClaw Config

Add these agents to `~/.openclaw/openclaw.json` under `agents.list`.

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

1. Add the above to `openclaw.json` agents.list
2. Run `openclaw gateway restart` to pick up new agents
3. Verify each agent with `openclaw status`
4. Test OHM connectivity from each agent

## OHM Tokens (in /root/olympus/shared/ohm-config.json and /etc/ohm/ohmd.json)

| Agent | Token |
|-------|-------|
| waylon | `ohm-waylon-u0-S6sRP4iGZMq_9NUfkjf4` |
| clint | `ohm-clint-u0-zn5vcUYQpscvhYtJzL-C` |
| roy | `ohm-roy-u0-5wrVOeD4P0Zc4B2gkwnJ` |
| magnus | `ohm-magnus-u0-zaa1SyXvqQGqGVL19HH5` |
| virgil | `ohm-virgil-u0-DQReSFofUTeiUcyvk7GB` |
| belle | `ohm-belle-u0-C4vzg0ABJXx3ANCwc7jr` |
| slim | `ohm-slim-u0-JxiWG5rFr77zecakXi3U` |

All verified working ✓