#!/usr/bin/env python3
"""Fetch RSS/Atom feeds and convert relevant entries to OHM observations.

Usage:
    python3 fetch_feeds.py [--agent roy|slim|virgil|belle|waylon] [--config ../shared/rss-feeds.yaml]

Each agent fetches their assigned feeds and writes observations to OHM.
Designed to be called from heartbeat/cron schedules.
"""

import argparse
import json
import yaml
import feedparser
import requests
from datetime import datetime, timezone
from pathlib import Path

OHM_HOST = "http://127.0.0.1:8711"

def load_config(config_path):
    """Load RSS feed configuration."""
    with open(config_path) as f:
        return yaml.safe_load(f)

def load_tokens(tokens_path):
    """Load OHM auth tokens."""
    with open(tokens_path) as f:
        return json.load(f).get("agents", {})

def fetch_feed(feed_url, last_seen=None):
    """Fetch and parse an RSS/Atom feed, return new entries."""
    feed = feedparser.parse(feed_url)
    new_entries = []
    for entry in feed.entries:
        pub_time = entry.get("published_parsed")
        if last_seen and pub_time and pub_time <= last_seen:
            continue
        new_entries.append({
            "title": entry.get("title", ""),
            "summary": entry.get("summary", ""),
            "link": entry.get("link", ""),
            "published": entry.get("published", ""),
            "published_parsed": pub_time,
        })
    return new_entries

def entry_matches(entry, keywords):
    """Check if an entry contains any of the specified keywords."""
    text = f"{entry['title']} {entry['summary']}".lower()
    return any(kw.lower() in text for kw in keywords) if keywords else True

def write_observation(token, node_id, obs_type, value, sigma, source, notes, source_url=None):
    """Write an observation to OHM."""
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    payload = {
        "node_id": node_id,
        "obs_type": obs_type,
        "value": value,
        "sigma": sigma,
        "source": source,
        "notes": notes,
    }
    if source_url:
        payload["source_url"] = source_url

    try:
        r = requests.post(f"{OHM_HOST}/observations", headers=headers, json=payload, timeout=10)
        return r.status_code < 300
    except Exception as e:
        print(f"  ERROR writing observation: {e}")
        return False

def process_feed(feed_config, token, last_seen=None):
    """Fetch and process a single feed."""
    name = feed_config["name"]
    url = feed_config["url"]
    keywords = feed_config.get("keywords", [])
    agent = feed_config.get("agent", "unknown")

    print(f"Fetching {name}...")
    entries = fetch_feed(url, last_seen)
    matching = [e for e in entries if entry_matches(e, keywords)]
    print(f"  {len(entries)} total, {len(matching)} matching keywords")

    return matching

def main():
    parser = argparse.ArgumentParser(description="Fetch RSS feeds and write OHM observations")
    parser.add_argument("--agent", choices=["roy", "slim", "virgil", "belle", "waylon"],
                        help="Only fetch feeds assigned to this agent")
    parser.add_argument("--config", default=Path(__file__).parent / ".." / "shared" / "rss-feeds.yaml",
                        help="Path to RSS feeds config")
    parser.add_argument("--tokens", default=Path(__file__).parent / ".." / "shared" / "ohm-config.json",
                        help="Path to OHM tokens config")
    parser.add_argument("--dry-run", action="store_true", help="Print entries without writing to OHM")
    args = parser.parse_args()

    config = load_config(args.config)
    tokens = load_tokens(args.tokens)

    feeds = config.get("feeds", [])
    if args.agent:
        feeds = [f for f in feeds if f.get("agent") == args.agent]

    print(f"Processing {len(feeds)} feeds for {args.agent or 'all agents'}")

    for feed_config in feeds:
        agent = feed_config.get("agent", "waylon")
        token = tokens.get(agent)
        if not token:
            print(f"  No token for {agent}, skipping")
            continue

        matching = process_feed(feed_config, token)

        for entry in matching:
            print(f"  [{feed_config['category']}] {entry['title'][:80]}")
            if not args.dry_run:
                # Observation writing is left to the agent's skill
                # This script just identifies relevant entries
                pass

    print(f"\nDone. {len(feeds)} feeds processed.")

if __name__ == "__main__":
    main()