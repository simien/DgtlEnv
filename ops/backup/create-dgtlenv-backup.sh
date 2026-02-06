#!/bin/bash

# DgtlEnv Backup Script
# Creates a timestamped zip archive of the entire DgtlEnv project

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKUP_DIR="$HOME/Downloads/DgtlEnv-Backups"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_NAME="DgtlEnv_Backup_${TIMESTAMP}.zip"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== DgtlEnv Backup Script ===${NC}"
echo -e "Project Root: ${GREEN}$PROJECT_ROOT${NC}"
echo -e "Backup Name: ${GREEN}$BACKUP_NAME${NC}"
echo -e "Backup Path: ${GREEN}$BACKUP_PATH${NC}"
echo ""

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${YELLOW}Creating backup directory: $BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
fi

# Check if we're in the right directory
if [ ! -f "$PROJECT_ROOT/README.md" ]; then
    echo -e "${RED}Error: README.md not found. Are you running this from the DgtlEnv project root?${NC}"
    exit 1
fi

echo -e "${BLUE}Creating backup...${NC}"

# Create the zip archive
# Exclude common files that shouldn't be backed up
cd "$PROJECT_ROOT"
zip -r "$BACKUP_PATH" . \
    -x "*.git/*" \
    -x "*.DS_Store" \
    -x "*.log" \
    -x "node_modules/*" \
    -x "*.tmp" \
    -x "*.temp" \
    -x "*.cache" \
    -x "*.swp" \
    -x "*.swo" \
    -x "*~" \
    -x ".vscode/settings.json" \
    -x ".cursor/settings.json" \
    -x "*.zip" \
    -x "*.tar.gz" \
    -x "*.backup"

# Check if backup was created successfully
if [ -f "$BACKUP_PATH" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
    echo -e "${GREEN}✅ Backup created successfully!${NC}"
    echo -e "File: ${GREEN}$BACKUP_PATH${NC}"
    echo -e "Size: ${GREEN}$BACKUP_SIZE${NC}"
    echo ""
    
    # List recent backups
    echo -e "${BLUE}Recent backups in $BACKUP_DIR:${NC}"
    ls -la "$BACKUP_DIR"/*.zip 2>/dev/null | tail -5 || echo "No previous backups found."
    
    # Optional: Open backup location
    echo ""
    read -p "Open backup location in Finder? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "$BACKUP_DIR"
    fi
    
else
    echo -e "${RED}❌ Backup creation failed!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Backup completed at $(date)${NC}" 