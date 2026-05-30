# Web Search & Browsing

## Purpose

Every ranch agent needs to look things up — current market conditions, regulatory changes, weather alerts, equipment specs, supplier details. This skill covers **two distinct capabilities**:

1. **Web Search** — Find information across the internet (quick lookups, "what's the current X?")
2. **Web Browsing** — Navigate specific websites, fill forms, read structured pages (USDA reports, auction listings, regulatory filings)

These complement RSS/data subscriptions: RSS is push (data comes to you), search and browsing are pull (you go get it).

## Web Search

### When to Search

| Agent | Typical Searches |
|-------|-----------------|
| **Roy** | Current cattle prices, feed costs, equipment availability, supplier comparisons |
| **Slim** | Local weather radar, pest/disease identification, grazing condition reports |
| **Virgil** | H-2A regulation changes, OSHA compliance questions, labor law updates |
| **Belle** | Interest rate forecasts, ag credit conditions, commodity market analysis |
| **Waylon** | Ranch management practices, industry trends, equipment reviews, regional news |

### Search via SearXNG (Primary)

SearXNG is the ranch's self-hosted search aggregator. It's private, cached, and doesn't leak queries.

```bash
# Basic search
curl -s -X POST -d "q=cattle+prices+feeder+steer+2026&format=json" \
  http://{SEARXNG_HOST}:8083/search

# Search with categories
curl -s -X POST -d "q=H-2A+regulation+2026&format=json&categories=general" \
  http://{SEARXNG_HOST}:8083/search

# Search specific engines
curl -s -X POST -d "q=alfalfa+hay+price+Nebraska&format=json&engines=google,bing" \
  http://{SEARXNG_HOST}:8083/search

# News-specific search
curl -s -X POST -d "q=drought+monitor+Texas+2026&format=json&categories=news" \
  http://{SEARXNG_HOST}:8083/search

# Time-limited search (last week)
curl -s -X POST -d "q=cattle+market+report&format=json&time_range=week" \
  http://{SEARXNG_HOST}:8083/search
```

### Search via OpenClaw web_search (Built-in)

When running inside OpenClaw, use the native `web_search` tool directly. This is preferred for interactive queries:

```
web_search(query="feeder cattle prices Nebraska 2026", count=5)
web_search(query="H-2A regulation update 2026", freshness="month")
web_search(query="drought conditions Texas Oklahoma", count=3)
```

### Search Quality Discipline

1. **Verify sources** — Cross-check critical data (prices, regulations) against at least 2 sources
2. **Check recency** — Market data ages fast. Always verify the date on price information.
3. **Note trust level** — USDA/government sources are high trust. Industry blogs are medium. Random forums are low.
4. **Record what you searched** — Write the query and results to OHM so other agents know what's been checked:

```python
g.observe(
    node_id="price-feeder-steer-spot",
    obs_type="measurement",
    value=extracted_price,
    sigma=5.0,
    source="roy_searxng_search",
    source_url=result_url,
    notes=f"Feeder steer price from {source_name}. Searched: '{query}'"
)
```

5. **Don't over-search** — If RSS or an API already provides this data, use that first. Search is for gaps and ad-hoc needs.

## Web Browsing

### When to Browse

- **Reading a specific report page** (USDA MPR, FRED dashboard, NWS forecast)
- **Filling out forms** (H-2A job order, compliance filing, auction registration)
- **Navigating multi-page data** (paginated market reports, county-level data)
- **Reading behind paywalls or JavaScript-heavy pages** (some industry reports)
- **Comparing information across tabs** (supplier pricing, equipment specs)

### Browsing via OpenClaw Browser Tool

When running inside OpenClaw, use the native `browser` tool:

```
# Open a page
browser(action="open", url="https://mpr.datamart.ams.usda.gov/")

# Take a snapshot of current page
browser(action="snapshot")

# Click an element
browser(action="act", kind="click", ref="e12")

# Type into a field
browser(action="act", kind="fill", ref="e15", text="feeder cattle")

# Navigate
browser(action="navigate", url="https://forecast.weather.gov/")

# Screenshot for visual verification
browser(action="screenshot")
```

### Browsing via Headless Fetch (Quick Page Reads)

For simple page reads where you don't need interaction:

```
web_fetch(url="https://mpr.datamart.ams.usda.gov/service?reportId=LM_CT180&format=json")
web_fetch(url="https://api.weather.gov/points/35.2269,-101.8332")
```

### Common Browsing Workflows

#### Roy: Check USDA Market Report

```
1. browser(action="open", url="https://mpr.datamart.ams.usda.gov/")
2. browser(action="snapshot")  # Find the report selector
3. browser(action="act", kind="select", ref="report_selector", values=["LM_CT180"])
4. browser(action="act", kind="click", ref="submit_btn")
5. browser(action="snapshot")  # Read the results
6. Extract prices → write to OHM
```

#### Slim: Check NWS Forecast

```
1. web_fetch(url="https://api.weather.gov/points/{LAT},{LON}")
2. Parse response for forecast URLs
3. web_fetch(url=forecast_url)
4. Extract conditions, alerts → write to OHM
```

#### Virgil: Check H-2A Job Order

```
1. browser(action="open", url="https://seasonal.dol.gov/")
2. browser(action="snapshot")
3. browser(action="act", kind="fill", ref="search_field", text="H-2A cattle ranch")
4. browser(action="act", kind="click", ref="search_btn")
5. browser(action="snapshot")  # Read results
6. Extract relevant orders → assess compliance impact → write to OHM
```

### Browsing Etiquette

1. **Don't spam** — Rate-limit yourself. Don't refresh a page every minute.
2. **Cache aggressively** — If you fetched it once, don't fetch it again in the same session.
3. **Use APIs first** — If there's an API endpoint (USDA, NWS, FRED), use that instead of browsing.
4. **Close tabs when done** — `browser(action="close", targetId=tab_id)`
5. **Respect robots.txt** — Don't scrape sites that prohibit it.
6. **Log what you browse** — Write observations to OHM with source_url so others don't duplicate the work.

## Decision Framework: Which Tool?

```
Need data? → Is there an RSS feed? → Use RSS (push, already configured)
                                 ↓ No
              Is there an API? → Use API (structured, reliable)
                                 ↓ No
              Do I need to interact with the page? → Browse (forms, navigation)
                                 ↓ No
              Just need to find something? → Search (quick lookup)
```

| Need | Tool | Speed | Reliability | Structure |
|------|------|-------|-------------|-----------|
| Recurring data | RSS/API | Scheduled | High | Structured |
| Quick fact check | SearXNG/web_search | Seconds | Medium | Unstructured |
| Read a specific page | web_fetch | Seconds | High | Semi-structured |
| Fill forms, navigate | Browser tool | Minutes | High | Interactive |
| Multi-page comparison | Browser tool | Minutes | Medium | Interactive |

## Configuration

### SearXNG

The ranch SearXNG instance should be configured in `shared/ranch-config.yaml`:

```yaml
searxng:
  host: "{SEARXNG_HOST}"  # e.g., 192.168.1.100
  port: 8083
  categories:
    - general
    - news
    - science
  engines:
    - google
    - bing
    - duckduckgo
    - wikipedia
```

### Browser

The OpenClaw browser uses the host system's Chromium. No special ranch configuration needed — it inherits from the OpenClaw instance.

### API Keys

Store in `shared/ranch-config.yaml` or environment variables:

```yaml
api_keys:
  fred: "${FRED_API_KEY}"       # https://fred.stlouisfed.org/docs/api/api_key.html
  usda: "${USDA_API_KEY}"       # https://www.usda.gov/developers
  nws: "none_required"          # NWS API is free, no key needed
```

## From Search/Browse to OHM

Every meaningful search or browse result should produce an observation:

```python
# After a search yields a useful result
g.observe(
    node_id="price-alfalfa-spot",      # or create new node if first observation
    obs_type="measurement",            # measurement, assessment, event
    value=245.0,                        # numeric value or probability
    sigma=5.0,                          # uncertainty
    source="roy_searxng_search",       # agent_source format
    source_url="https://example.com/report",  # ALWAYS include URL
    notes="Alfalfa spot price from USDA AMS report. Quality: Supreme. Region: Southern Plains."
)

# After browsing confirms a regulatory change
g.observe(
    node_id="concept-ranch-hr",
    obs_type="event",
    value=1,
    sigma=0,
    source="virgil_dol_browse",
    source_url="https://www.dol.gov/agencies/eta/foreign-labor/programs/h-2a",
    notes="H-2A AEWR update confirmed effective July 1. Ranch-impacted counties listed."
)
```

## Anti-Patterns

❌ **Searching before checking RSS** — If the data comes via subscription, use the subscription first.

❌ **Browsing for structured data** — If there's an API, use the API. Don't scrape HTML when JSON is available.

❌ **Not recording the query** — Other agents may need the same data. Write what you searched and where.

❌ **Treating search results as gospel** — Cross-reference important findings. Single-source data gets low confidence.

❌ **Over-fetching** — Don't browse 50 pages when one API call gives you the same data.