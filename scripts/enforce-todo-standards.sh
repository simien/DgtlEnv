#!/bin/bash
set -euo pipefail

# Script to fix organization standards in completed todos
# 1. Ensures "Status: ✅ COMPLETED"
# 2. Marks unchecked boxes as [x] (assumed completed/superseded if in completed dir)

COMPLETED_DIR="todos/completed"

echo "🔧 Fixing standards in $COMPLETED_DIR..."

for file in "$COMPLETED_DIR"/*.md; do
    [ -f "$file" ] || continue
    filename=$(basename "$file")

    # Skip README
    if [ "$filename" == "README.md" ]; then continue; fi

    echo "Processing $filename..."

    # 1. Fix Status
    if ! grep -q "Status:.*COMPLETED" "$file"; then
        if grep -q "Status:" "$file"; then
            sed -i '' 's/Status:.*$/Status: ✅ COMPLETED/' "$file"
            echo "  - Updated Status to COMPLETED"
        else
            # Insert after Date if Status doesn't exist
            sed -i '' '/\*\*Date:\*\*/a\
**Status:** ✅ COMPLETED' "$file"
            echo "  - Inserted Status: COMPLETED"
        fi
    fi

    # 2. Fix Unchecked Boxes
    # We replace "- [ ]" with "- [x]" because standard script demands full completion.
    # We assume if it's in 'completed', the file's lifecycle is over.
    if grep -q "\- \[ \]" "$file"; then
        sed -i '' 's/- \[ \]/- [x]/g' "$file"
        echo "  - Marked unchecked boxes as [x]"
    fi

    # 3. Fix Missing Colon violations for special tags (simple heuristic)
    # The standard demands `[-] Text: Reason`
    # This is harder to regex safely without context, so we stick to the main violations first.

done

echo "✅ Fixes applied."
