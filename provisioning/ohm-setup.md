# OHM Setup — Ranch Operations

This pilot uses a **separate OHM instance** with its own DuckDB/DuckLake, independent from the Olympus OHM instance.

## Architecture

```
Olympus OHM (existing)          Ranch OHM (new, separate)
─────────────────────           ─────────────────────────
Port: 8710                      Port: 8711 (or available)
DB: /var/lib/ohm/ohm.duckdb     DB: /var/lib/ohm-ranch/ohm.duckdb
DuckLake: /var/lib/ohm/...      DuckLake: /var/lib/ohm-ranch/...
Tokens: ohm-{agent}-u0-...      Tokens: ranch-{agent}-u0-...
```

## Setup Steps

### 1. Install OHM

```bash
# Clone OHM if not already available
cd /opt
git clone https://github.com/mdlmarkham/OHM.git
cd OHM
pip install -e .
```

### 2. Create the Ranch OHM Database Directory

```bash
sudo mkdir -p /var/lib/ohm-ranch
sudo chown $(whoami):$(whoami) /var/lib/ohm-ranch
```

### 3. Configure the Ranch OHM Daemon

Create `/etc/ohm/ranch-ohmd.json`:

```json
{
  "host": "0.0.0.0",
  "port": 8711,
  "db_path": "/var/lib/ohm-ranch/ohm.duckdb",
  "ducklake": {
    "enabled": true,
    "path": "/var/lib/ohm-ranch/ohm_lake.ducklake"
  },
  "log_level": "info",
  "tokens": {
    "waylon": "ranch-waylon-u0-REPLACE_WITH_SECURE_TOKEN",
    "clint": "ranch-clint-u0-REPLACE_WITH_SECURE_TOKEN",
    "roy": "ranch-roy-u0-REPLACE_WITH_SECURE_TOKEN",
    "magnus": "ranch-magnus-u0-REPLACE_WITH_SECURE_TOKEN",
    "virgil": "ranch-virgil-u0-REPLACE_WITH_SECURE_TOKEN",
    "belle": "ranch-belle-u0-REPLACE_WITH_SECURE_TOKEN",
    "slim": "ranch-slim-u0-REPLACE_WITH_SECURE_TOKEN"
  }
}
```

**Generate secure tokens:**
```bash
python3 -c "
import secrets, string
agents = ['waylon', 'clint', 'roy', 'magnus', 'virgil', 'belle', 'slim']
for a in agents:
    token = 'ranch-' + a + '-u0-' + ''.join(secrets.choice(string.ascii_letters + string.digits + '_-') for _ in range(20))
    print(f'{a}: {token}')
"
```

### 4. Create the systemd Service

Create `/etc/systemd/system/ohmd-ranch.service`:

```ini
[Unit]
Description=OHM Daemon (Ranch) — Multi-agent knowledge graph server
After=network.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/ohmd --config /etc/ohm/ranch-ohmd.json
Restart=on-failure
RestartSec=5
Environment=OHM_CONFIG=/etc/ohm/ranch-ohmd.json
Environment=OHM_DB_PATH=/var/lib/ohm-ranch/ohm.duckdb
Environment=OHM_DUCKLAKE_PATH=/var/lib/ohm-ranch/ohm_lake.ducklake

[Install]
WantedBy=multi-user.target
```

### 5. Start the Ranch OHM Daemon

```bash
sudo systemctl daemon-reload
sudo systemctl enable ohmd-ranch
sudo systemctl start ohmd-ranch
# Verify
curl -s -m 5 -H "Authorization: Bearer ranch-waylon-u0-REPLACE" http://127.0.0.1:8711/stats
```

### 6. Seed the Knowledge Graph

```bash
# Run the seed script
python3 scripts/seed-ranch-ohm.py --port 8711
```

Or manually via the API:

```bash
TOKEN="ranch-waylon-u0-REPLACE_WITH_SECURE_TOKEN"
HOST="http://127.0.0.1:8711"

# Create hub node
curl -s -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -X POST "$HOST/node" \
  -d '{"id":"concept-ranch-operations-hub","label":"Ranch Operations Hub","type":"concept","tags":["ranch-operations","pilot","ranch"]}'

# Create domain nodes
for pair in \
  "concept-ranch-livestock:Livestock Management:ranch-livestock,ranch" \
  "concept-ranch-supply:Supply Chain & Purchasing:ranch-supply,ranch" \
  "concept-ranch-inventory:Inventory & Asset Tracking:ranch-inventory,ranch" \
  "concept-ranch-hr:HR & Labor Management:ranch-hr,ranch" \
  "concept-ranch-finance:Finance & Accounting:ranch-finance,ranch" \
  "concept-ranch-field:Field Operations & Scouting:ranch-field,ranch"; do
  id=$(echo $pair | cut -d: -f1)
  label=$(echo $pair | cut -d: -f2)
  tags=$(echo $pair | cut -d: -f3 | sed 's/,/","/g')
  curl -s -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
    -X POST "$HOST/node" \
    -d "{\"id\":\"$id\",\"label\":\"$label\",\"type\":\"concept\",\"tags\":[\"$tags\"]}"
done

# Wire edges
for domain in concept-ranch-livestock concept-ranch-supply concept-ranch-inventory concept-ranch-hr concept-ranch-finance concept-ranch-field; do
  curl -s -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
    -X POST "$HOST/edge" \
    -d "{\"from\":\"$domain\",\"to\":\"concept-ranch-operations-hub\",\"type\":\"PART_OF\",\"layer\":\"L1\",\"confidence\":1.0}"
done
```

### 7. Update Agent Configs

Each agent's AGENTS.md references the Ranch OHM instance. Update the connection:

```python
from ohm.sdk import connect_http
g = connect_http("http://127.0.0.1:8711", actor="waylon",
                 token="ranch-waylon-u0-REPLACE_WITH_SECURE_TOKEN")
```

Also create `/root/olympus/ranch/shared/ohm-config.json`:

```json
{
  "ohmd_url": "http://127.0.0.1:8711",
  "db_path": "/var/lib/ohm-ranch/ohm.duckdb",
  "agents": {
    "waylon": "ranch-waylon-u0-REPLACE_WITH_SECURE_TOKEN",
    "clint": "ranch-clint-u0-REPLACE_WITH_SECURE_TOKEN",
    "roy": "ranch-roy-u0-REPLACE_WITH_SECURE_TOKEN",
    "magnus": "ranch-magnus-u0-REPLACE_WITH_SECURE_TOKEN",
    "virgil": "ranch-virgil-u0-REPLACE_WITH_SECURE_TOKEN",
    "belle": "ranch-belle-u0-REPLACE_WITH_SECURE_TOKEN",
    "slim": "ranch-slim-u0-REPLACE_WITH_SECURE_TOKEN"
  },
  "daemon_status": "pending",
  "daemon_port": 8711
}
```

## Verification Checklist

- [ ] OHM daemon running on port 8711
- [ ] All 7 agent tokens authenticate: `curl -H "Authorization: Bearer ranch-{agent}-u0-..." http://127.0.0.1:8711/stats`
- [ ] Hub + 6 domain nodes created
- [ ] PART_OF edges connecting domains to hub
- [ ] DuckLake path configured: `/var/lib/ohm-ranch/ohm_lake.ducklake`
- [ ] OpenClaw agents provisioned (see `provisioning/openclaw-config.md`)
- [ ] Agent workspaces point to `agents/{name}/` directories
- [ ] Each agent's AGENTS.md references `port 8711` and Ranch tokens