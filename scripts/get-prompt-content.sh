#!/bin/bash
set -euo pipefail

# Helper script to get prompt content by aliasfor AI Integration
# Returns the processed prompt content directly (not to clipboard)

PROMPT_ALIAS=$1

if [[ -z "$PROMPT_ALIAS" ]]; then
    echo "Usage: $0 <prompt-alias>"
    exit 1
fi

# Find the latest prompt file
PROMPTS_DIR="prompts/categories"
LATEST_PROMPT_FILE=$(find "$PROMPTS_DIR" -type f -name "${PROMPT_ALIAS}-*.md" | sort -V | tail -n 1)

if [[ -z "$LATEST_PROMPT_FILE" ]]; then
    echo "Error: No prompt files found for alias '$PROMPT_ALIAS'."
    exit 1
fi

# Process the prompt content
PROMPT_BODY=$(cat "$LATEST_PROMPT_FILE")

# Handle includes (same logic as the main router)
while IFS= read -r line; do
  if [[ "$line" == *"{{include:"* ]]; then
    FILE_TO_INCLUDE=$(echo "$line" | sed -n 's/.*{{include:\([^}]*\)}}.*/\1/p')
    if [[ -f "$FILE_TO_INCLUDE" ]]; then
      INCLUDED_CONTENT=$(cat "$FILE_TO_INCLUDE")
      PROMPT_BODY=$(echo "$PROMPT_BODY" | sed "s|{{include:${FILE_TO_INCLUDE}}}|${INCLUDED_CONTENT}|")
    fi
  fi
done <<< "$PROMPT_BODY"

# Output the processed content
echo "$PROMPT_BODY"
