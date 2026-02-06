#!/bin/bash

# Move Converted Files Script
# Moves existing converted markdown files from docs/converted/ to docs/

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"
CONVERTED_DIR="$DOCS_DIR/converted"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Move Converted Files ===${NC}"

# Check if converted directory exists
if [ ! -d "$CONVERTED_DIR" ]; then
    echo -e "${YELLOW}No converted directory found. Nothing to move.${NC}"
    exit 0
fi

# Move all .md files from converted to docs root
moved_count=0
for md_file in "$CONVERTED_DIR"/*.md; do
    if [ -f "$md_file" ]; then
        local filename=$(basename "$md_file")
        local target_file="$DOCS_DIR/$filename"
        
        # Check if file already exists in docs root
        if [ -f "$target_file" ]; then
            echo -e "${YELLOW}⏭️  Skipping $filename (already exists in docs root)${NC}"
        else
            mv "$md_file" "$target_file"
            echo -e "${GREEN}✅ Moved: $filename${NC}"
            moved_count=$((moved_count + 1))
        fi
    fi
done

echo ""
echo -e "${GREEN}📊 Move Summary:${NC}"
echo -e "Files moved: ${moved_count}"

# Check if converted directory is now empty
if [ -z "$(ls -A "$CONVERTED_DIR" 2>/dev/null)" ]; then
    echo -e "${YELLOW}Converted directory is now empty.${NC}"
    read -p "Remove empty converted directory? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rmdir "$CONVERTED_DIR"
        echo -e "${GREEN}✅ Removed empty converted directory${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✅ Move operation completed!${NC}" 