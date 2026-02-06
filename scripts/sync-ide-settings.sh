#!/bin/bash

# Sync VS Code Project Settings with IDE
# This script copies project-specific VS Code settings to your IDE (Cursor/VS Code)
#
# 🎯 PERFORMANCE IMPACT:
# - Optimizes IDE for faster performance
# - Reduces memory usage through optimized settings
# - Improves file watching and TypeScript server performance
# - Disables unused extensions to save resources
# - BEFORE: IDE lag, high memory usage, slow file operations
# - AFTER: Optimized IDE performance, reduced memory usage, faster operations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Detect IDE or use Default
if [ -d "$HOME/Library/Application Support/Cursor/User" ]; then
    IDE_NAME="Cursor"
    IDE_SETTINGS_DIR="$HOME/Library/Application Support/Cursor/User"
elif [ -d "$HOME/Library/Application Support/Code/User" ]; then
    IDE_NAME="VS Code"
    IDE_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
else
    echo "❌ No supported IDE found (Cursor or VS Code)"
    exit 1
fi

IDE_SETTINGS="$IDE_SETTINGS_DIR/settings.json"
VSCODE_SETTINGS="$PROJECT_ROOT/.vscode/settings.json"

echo "=== IDE Settings Sync ==="
echo "Project: $PROJECT_ROOT"
echo "Target IDE: $IDE_NAME"
echo "IDE Settings: $IDE_SETTINGS"
echo "VS Code Settings: $VSCODE_SETTINGS"
echo

# Check if VS Code settings exist
if [[ ! -f "$VSCODE_SETTINGS" ]]; then
    echo "❌ VS Code settings not found: $VSCODE_SETTINGS"
    exit 1
fi

# Check if IDE settings exist
if [[ ! -f "$IDE_SETTINGS" ]]; then
    echo "❌ Connect IDE settings not found: $IDE_SETTINGS"
    exit 1
fi

echo "📋 Current $IDE_NAME Settings:"
echo "------------------------"
cat "$IDE_SETTINGS" | jq '.' 2>/dev/null || cat "$IDE_SETTINGS"
echo

echo "📋 Project VS Code Settings:"
echo "---------------------------"
cat "$VSCODE_SETTINGS" | jq '.' 2>/dev/null || cat "$VSCODE_SETTINGS"
echo

# Create backup of current settings
BACKUP_FILE="$IDE_SETTINGS_DIR/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
cp "$IDE_SETTINGS" "$BACKUP_FILE"
echo "✅ Backup created: $BACKUP_FILE"

# Function to merge JSON settings
merge_settings() {
    local ide_settings="$1"
    local vscode_settings="$2"
    local backup_file="$3"

    # Use jq to merge settings (project settings take precedence)
    if command -v jq &> /dev/null; then
        echo "🔄 Merging settings with jq..."
        # First, clean the settings by removing comments
        sed '/^[[:space:]]*\/\//d' "$ide_settings" | jq '.' > "$ide_settings.clean"
        jq -s '.[0] * .[1]' "$ide_settings.clean" "$vscode_settings" > "$ide_settings.tmp"
        mv "$ide_settings.tmp" "$ide_settings"
        rm -f "$ide_settings.clean"
    else
        echo "⚠️  jq not found, using manual merge..."
        # Manual merge approach
        python3 -c "
import json
import sys

try:
    with open('$ide_settings', 'r') as f:
        ide = json.load(f)
    with open('$vscode_settings', 'r') as f:
        vscode = json.load(f)

    # Merge settings (vscode settings override ide settings)
    ide.update(vscode)

    with open('$ide_settings', 'w') as f:
        json.dump(ide, f, indent=4)
    print('✅ Settings merged successfully')
except Exception as e:
    print(f'❌ Error merging settings: {e}')
    sys.exit(1)
"
    fi
}

# Ask user for confirmation
echo "🤔 Do you want to merge project VS Code settings with $IDE_NAME settings?"
echo "   This will apply project-specific optimizations to your IDE"
echo "   Backup will be created automatically"
echo
read -p "Continue? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Merging settings..."
    merge_settings "$IDE_SETTINGS" "$VSCODE_SETTINGS" "$BACKUP_FILE"

    echo "✅ Settings merged successfully!"
    echo
    echo "📋 Updated $IDE_NAME Settings:"
    echo "-------------------------"
    cat "$IDE_SETTINGS" | jq '.' 2>/dev/null || cat "$IDE_SETTINGS"
    echo
    echo "🔄 Please restart $IDE_NAME to apply changes"
    echo "💡 You can restore from backup if needed: $BACKUP_FILE"
else
    echo "❌ Operation cancelled"
    rm -f "$BACKUP_FILE"
fi

echo
echo "=== Sync Complete ==="
