#!/bin/bash
set -euo pipefail

# Generates a directory tree structure for documentationes accurate visual directory structures for README files

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "  DgtlEnv Directory Tree Generator"
echo "=========================================="
echo

# Check if directory path is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Please provide a directory path${NC}"
    echo "Usage: $0 <directory-path>"
    echo "Example: $0 ./docs"
    exit 1
fi

DIRECTORY="$1"

# Check if directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo -e "${RED}Error: Directory '$DIRECTORY' does not exist${NC}"
    exit 1
fi

# Get directory name for title
DIR_NAME=$(basename "$DIRECTORY")

echo -e "${BLUE}Generating tree for: $DIRECTORY${NC}"
echo

echo "$DIR_NAME/"
find "$DIRECTORY" -type d -not -path "./.git*" -not -path "./.cursor*" -not -path "./.vscode*" | sort | while read -r dir; do
    if [[ "$dir" != "$DIRECTORY" ]]; then
        # Calculate depth
        relative_path="${dir#$DIRECTORY/}"
        depth=$(echo "$relative_path" | tr -cd '/' | wc -c)
        # Add 1 to depth
        depth=$((depth + 1))
        indent=$(printf '%*s' "$depth" | tr ' ' '│   ')
        basename_dir=$(basename "$dir")
        echo "${indent}├── $basename_dir/                              # Directory"
    fi
done

done

# Add files
find "$DIRECTORY" -maxdepth 1 -type f -name "*.md" | sort | while read -r file; do
    basename_file=$(basename "$file")
    echo "└── $basename_file                               # Documentation file"
done
echo "```"
echo

echo -e "${GREEN}✅ Generated accurate directory tree for '$DIRECTORY'${NC}"
echo -e "${BLUE}📝 Copy this structure to update your README file${NC}"
echo -e "${YELLOW}💡 Remember to add descriptions for important files and directories${NC}"
