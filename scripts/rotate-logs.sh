#!/bin/bash

# Log Rotation Script
# Rotates and cleans up logs in appropriate directories

set -euo pipefail

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGS_DIR="$PROJECT_ROOT/logs"
RETENTION_DAYS_ACTIVE=7
RETENTION_DAYS_ARCHIVE=30

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Ensure logs directory exists
if [[ ! -d "$LOGS_DIR" ]]; then
    echo "Logs directory not found: $LOGS_DIR"
    exit 0
fi

log "Starting log rotation in: $LOGS_DIR"

# process each subdirectory
find "$LOGS_DIR" -mindepth 1 -maxdepth 1 -type d | while read dir; do
    dirname=$(basename "$dir")
    log "Processing directory: $dirname"

    # 1. Compress logs older than 7 days
    find "$dir" -name "*.log" -type f -mtime +$RETENTION_DAYS_ACTIVE -print0 | while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            log "Compressing: $(basename "$file")"
            gzip "$file"
        fi
    done

    # 2. Delete archives older than 30 days
    find "$dir" -name "*.gz" -type f -mtime +$RETENTION_DAYS_ARCHIVE -print0 | while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            log "Deleting old archive: $(basename "$file")"
            rm "$file"
        fi
    done
done

success "Log rotation complete."
