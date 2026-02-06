#!/bin/bash
set -euo pipefail

# Interactive IDE Settings Sync Script
# Asks user if they want to sync VS Code settings to their IDE (Cursor/VS Code)

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  IDE Settings Sync"
echo "=========================================="
echo

# Check if an IDE is available (Cursor or VS Code)
if command -v cursor >/dev/null 2>&1 || [ -d "/Applications/Cursor.app" ] || [ -d "$HOME/Library/Application Support/Code" ]; then
    echo -e "${BLUE}[INFO]${NC} Compatible IDE detected"
    echo
    echo -e "${BLUE}[QUESTION]${NC} Do you want to sync project settings to your IDE?"
    echo "  This will apply project-specific optimizations"
    echo "  A backup of your current settings will be created"
    echo
    echo -e "${BLUE}[QUESTION]${NC} Continue? (y/N): "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo
        echo -e "${BLUE}[INFO]${NC} Running IDE optimization..."
        if ./scripts/sync-ide-settings.sh; then
            echo -e "${GREEN}[SUCCESS]${NC} IDE settings synchronized successfully!"
        else
            echo -e "${RED}[ERROR]${NC} IDE sync failed"
            exit 1
        fi
    else
        echo -e "${YELLOW}[SKIP]${NC} IDE sync cancelled by user"
    fi
else
    echo -e "${YELLOW}[SKIP]${NC} No compatible IDE (Cursor/VS Code) detected"
fi

echo
echo "=========================================="
