# RSS & Data Subscriptions

## Purpose

Ranch operations depend on external data: market prices, weather forecasts, regulatory updates, and industry news. This skill defines what to subscribe to, how to fetch it, and how to turn raw data into OHM observations that drive decisions.

## Data Sources by Agent

### Roy (Supply Chain) — Market Prices

| Source | URL | Frequency | What It Provides |
|--------|-----|-----------|-----------------|
| USDA AMS Livestock | `https://www.ams.usda.gov/market-news/livestock-poultry-grain` | Weekly | 5-area weighted average cattle prices, feeder cattle reports |
| USDA AMS Hay | `https://www.ams.usda.gov/market-news/hay-reports` | Weekly | Regional hay prices by grade (alfalfa, grass, mixed) |
| USDA MyMarketNews | `https://mymarketnews.ams.usda.gov/` | Daily | Real-time livestock market data, searchable reports |
| USDA MPR Datamart | `https://mpr.datamart.ams.usda.gov/` | Weekly | Mandatory price reporting for cattle |
| CME Group | `https://www.cmegroup.com/markets/agriculture.html` | Daily | Live cattle & feeder cattle futures |
| CBOT via CME | `https://www.cmegroup.com/markets/agriculture/corn.html` | Daily | Corn futures (feed cost proxy) |
| Drought Monitor | `https://droughtmonitor.unl.edu/` | Weekly | US Drought Monitor maps and data |

### Slim (Field) — Weather & Conditions

| Source | URL | Frequency | What It Provides |
|--------|-----|-----------|-----------------|
| NWS Forecast | `https://forecast.weather.gov/` | Daily | Local forecast, alerts, radar |
| NWS Alerts | `https://alerts.weather.gov/` | Real-time | Watches, warnings, advisories |
| USDA Drought Monitor | `https://droughtmonitor.unl.edu/` | Weekly | Regional drought status (D0-D4) |
| NOAA Climate | `https://www.climate.gov/` | Monthly | Seasonal outlooks, ENSO status |

### Virgil (HR) — Regulatory

| Source | URL | Frequency | What It Provides |
|--------|-----|-----------|-----------------|
| DOL H-2A | `https://www.dol.gov/agencies/eta/foreign-labor/programs/h-2a` | As published | H-2A program changes, AEWR updates |
| OSHA Ag | `https://www.osha.gov/agriculture` | As published | Agricultural safety regulations |
| IRS Ag | `https://www.irs.gov/businesses/small-businesses-self-employed/agriculture` | As published | Tax code changes affecting ag |

### Belle (Finance) — Market & Economic

| Source | URL | Frequency | What It Provides |
|--------|-----|-----------|-----------------|
| FRED | `https://fred.stlouisfed.org/` | Daily | Interest rates, inflation, ag credit data |
| CME FedWatch | `https://www.cmegroup.com/markets/interest-rates/cme-fedwatch-tool.html` | Daily | Fed rate probability |
| USDA ERS | `https://www.ers.usda.gov/` | Monthly | Farm income forecasts, ag sector indicators |

## Fetching Strategy

### Via SearXNG (Primary)

SearXNG is the primary search tool for ad-hoc data lookups. Configure it at `http://{SEARXNG_HOST}:8083/search`.

```bash
# Example: Fetch current hay prices
curl -s -X POST -d "q=alfalfa+hay+price+spot+2026&format=json" http://{SEARXNG_HOST}:8083/search

# Example: Fetch drought monitor status
curl -s -X POST -d "q=US+drought+monitor+current&format=json" http://{SEARXNG_HOST}:8083/search
```

### Via USDA API (Structured Data)

USDA Market News provides structured data via the MPR Datamart and MyMarketNews:

```bash
# Cattle price reports (5-area weighted average)
curl -s "https://mpr.datamart.ams.usda.gov/service?reportId=LM_CT180&format=json"

# Hay price reports
curl -s "https://mpr.datamart.ams.usda.gov/service?commodity=hay&format=json"
```

### Via FRED API (Economic Data)

```bash
# Get API key from https://fred.stlouisfed.org/docs/api/api_key.html
FRED_API_KEY="your_key_here"

# Example: Farm credit data
curl -s "https://api.stlouisfed.org/fred/series/observations?series_id=AGRSFC&api_key=$FRED_API_KEY&file_type=json&observation_start=2026-01-01"
```

### Via NWS API (Weather)

```bash
# Get grid point for your location
# First: https://api.weather.gov/points/{lat},{lon}
# Then use the forecast URL from the response

# Example (replace with your coordinates)
curl -s "https://api.weather.gov/points/XX.XXXX,-YY.YYYY" | python3 -c "
import json, sys
d = json.load(sys.stdin)
forecast_url = d['properties']['forecast']
print(f'Forecast URL: {forecast_url}')
"
```

### Via RSS Feeds (Push Subscriptions)

```python
import feedparser

# USDA Market News RSS
feeds = {
    "usda_livestock": "https://www.ams.usda.gov/rss/mn-livestock.xml",
    "usda_hay": "https://www.ams.usda.gov/rss/mn-hay.xml",
    "nws_alerts": "https://alerts.weather.gov/cap/wwaatmget.php?x=XXX&y=1",  # Replace XXX with your county code
    "drought_monitor": "https://droughtmonitor.unl.edu/Maps/Maps.aspx?rss=1",
}

def fetch_feed(name, url, last_seen=None):
    """Fetch RSS feed and return new entries since last_seen timestamp."""
    feed = feedparser.parse(url)
    new_entries = []
    for entry in feed.entries:
        if last_seen and entry.get('published_parsed') <= last_seen:
            continue
        new_entries.append({
            "title": entry.get("title", ""),
            "summary": entry.get("summary", ""),
            "link": entry.get("link", ""),
            "published": entry.get("published", ""),
        })
    return new_entries
```

## RSS Configuration File

Create `shared/rss-feeds.yaml` on the ranch instance:

```yaml
# Ranch Operations RSS Subscriptions
# Each agent subscribes to feeds relevant to their domain

feeds:
  # === Roy: Market Prices ===
  - name: usda-livestock
    url: https://www.ams.usda.gov/rss/mn-livestock.xml
    agent: roy
    category: market
    frequency: daily
    trust: high
    keywords: ["cattle", "feeder", "slaughter", "steer", "heifer"]
    
  - name: usda-hay
    url: https://www.ams.usda.gov/rss/mn-hay.xml
    agent: roy
    category: feed
    frequency: weekly
    trust: high
    keywords: ["alfalfa", "hay", "grass", "bale"]
    
  - name: cme-agriculture
    url: https://www.cmegroup.com/rss/agriculture.html
    agent: roy
    category: futures
    frequency: daily
    trust: high
    keywords: ["cattle", "feeder", "corn", "soybean"]

  # === Slim: Weather ===
  - name: nws-alerts
    url: https://alerts.weather.gov/cap/wwaatmget.php?x={COUNTY_CODE}&y=1
    agent: slim
    category: weather
    frequency: real-time
    trust: high
    keywords: ["warning", "watch", "advisory", "flood", "heat", "freeze", "storm"]
    
  - name: drought-monitor
    url: https://droughtmonitor.unl.edu/Maps/Maps.aspx?rss=1
    agent: slim
    category: drought
    frequency: weekly
    trust: high
    keywords: ["drought", "abnormally dry", "moderate", "severe"]

  # === Virgil: Regulatory ===
  - name: dol-h2a
    url: https://www.dol.gov/rss/eta-h2a.xml
    agent: virgil
    category: regulatory
    frequency: as-published
    trust: high
    keywords: ["H-2A", "AEWR", "foreign labor", "seasonal worker"]

  # === Belle: Economic ===
  - name: fred-ag-credit
    url: https://fred.stlouisfed.org/rss/series/AGRSFC
    agent: belle
    category: economic
    frequency: monthly
    trust: high
    keywords: ["farm credit", "agricultural loans", "interest rate"]

  # === Waylon: General Ranch News ===
  - name: beef-magazine
    url: https://www.beefmagazine.com/rss.xml
    agent: waylon
    category: industry
    frequency: daily
    trust: medium
    keywords: ["cattle", "ranch", "beef", "market", "regulation"]

  - name: progressive-farmer
    url: https://www.dtnpf.com/rss
    agent: waylon
    category: industry
    frequency: daily
    trust: medium
    keywords: ["cattle", "feed", "drought", "market", "regulation"]
```

## From RSS to OHM Observation

When an RSS entry is relevant, convert it to an observation:

```python
# Roy reads USDA hay price report
g.observe(
    node_id="price-alfalfa-spot",
    obs_type="measurement",
    value=float(extracted_price),  # e.g., 245.0
    sigma=5.0,
    source="roy_usda_hay_report",
    source_url=entry_link,
    notes=f"USDA AMS: Alfalfa hay {quality} {region} at ${price}/ton. {entry_summary}"
)
```

```python
# Slim reads NWS heat advisory
g.observe(
    node_id="concept-ranch-field",
    obs_type="assessment",
    value=0.8,  # High probability of impact
    sigma=0.1,
    source="slim_nws_alert",
    source_url=alert_url,
    notes=f"NWS {alert_type}: {alert_description}. Action: {recommended_action}"
)
```

```python
# Virgil reads H-2A regulatory update
g.observe(
    node_id="concept-ranch-hr",
    obs_type="event",
    value=1,
    sigma=0,
    source="virgil_dol_h2a_update",
    source_url=regulation_url,
    notes=f"DOL H-2A update: {summary}. Effective {effective_date}. Impact: {impact_assessment}"
)
```

## Fetch Schedule

| Agent | Schedule | What |
|-------|----------|------|
| **Roy** | Daily at 06:00 | CME futures, USDA market reports |
| **Roy** | Weekly on Monday | USDA hay reports |
| **Slim** | Daily at 05:30 | NWS forecast, alerts |
| **Slim** | Weekly on Thursday | Drought monitor update |
| **Virgil** | As published | DOL/OSHA/IRS regulatory updates |
| **Belle** | Daily at 07:00 | FRED data, CME FedWatch |
| **Belle** | Monthly | USDA ERS farm income forecast |
| **Waylon** | Daily at 06:30 | Industry news (Beef Magazine, DTN/PF) |

## Implementation Notes

1. **RSS feed URLs may change** — verify periodically and update `shared/rss-feeds.yaml`
2. **USDA moved to API-first** — the MyMarketNews API (`https://mymarketnews.ams.usda.gov/`) provides more structured data than RSS for price reports. Use API when available, RSS as fallback.
3. **NWS alerts are CAP format** — use feedparser or a CAP parser to extract severity, urgency, and certainty from the alert XML.
4. **Rate limiting** — don't hit any API more than once per minute. Cache responses.
5. **Error handling** — if a feed is down, log it and continue. Don't block the briefing on a single failed fetch.
6. **Configurable location** — weather feeds need lat/lon or county code. Set these in `shared/rss-feeds.yaml` or `shared/ranch-config.yaml` for the specific ranch location.