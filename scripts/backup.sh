#!/bin/bash
# Rolling git backup for BOS (ranch-ops)
# Commits any changes and pushes to GitHub.
# Designed to run via cron (daily or more frequent).

set -e

REPO_DIR="/root/olympus/ranch"
LOG_FILE="/root/olympus/logs/ranch-backup.log"
MAX_LOG_LINES=500

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date -Iseconds)] $1" >> "$LOG_FILE"
}

# Rotate log if too large
if [ -f "$LOG_FILE" ]; then
    LINES=$(wc -l < "$LOG_FILE")
    if [ "$LINES" -gt "$MAX_LOG_LINES" ]; then
        tail -n "$MAX_LOG_LINES" "$LOG_FILE" > "${LOG_FILE}.tmp"
        mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi
fi

cd "$REPO_DIR"

# Check for changes (tracked + untracked)
CHANGES=$(git status --porcelain)

if [ -z "$CHANGES" ]; then
    log "No changes to commit"
    # Pull any remote changes
    git fetch origin >> "$LOG_FILE" 2>&1 || true
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/master 2>/dev/null || echo "$LOCAL")
    if [ "$LOCAL" != "$REMOTE" ]; then
        git pull --rebase origin master >> "$LOG_FILE" 2>&1 || true
        log "Pulled remote changes"
    else
        log "Already up to date with remote"
    fi
    exit 0
fi

log "Changes detected, committing..."

# Stage all changes (including new files)
git add -A

# Commit with timestamp
TIMESTAMP=$(date -Iseconds)
git commit -m "Auto-backup: ${TIMESTAMP}" >> "$LOG_FILE" 2>&1

log "Committed changes"

# Push to GitHub
git push origin master >> "$LOG_FILE" 2>&1

log "Pushed to origin/master"
log "Backup complete"