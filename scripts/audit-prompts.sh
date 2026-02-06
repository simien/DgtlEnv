#!/bin/bash

# ##############################################################################
# DgtlEnv Outdated Prompt Checker v1.0.0
#
# Checks for outdated prompt versions and suggests archiving them.
# This helps maintain a clean prompt directory structure.
#
# Usage:
#   ./scripts/audit-prompts.sh [--archive] [--dry-run]
#
# Options:
#   --archive    Automatically archive outdated versions
#   --dry-run    Show what would be archived without doing it
# ##############################################################################

set -euo pipefail

# --- Configuration ---
PROMPTS_DIR="prompts/categories"
ARCHIVE_DIR="prompts/archived"
DRY_RUN=false
AUTO_ARCHIVE=false

# --- Parse Arguments ---
while [[ $# -gt 0 ]]; do
    case $1 in
        --archive)
            AUTO_ARCHIVE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--archive] [--dry-run]"
            exit 1
            ;;
    esac
done

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Functions ---
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to extract base name and version from filename
extract_base_and_version() {
    local filename="$1"
    local basename=$(basename "$filename" .md)

    # Extract base name (everything before the last version pattern)
    local base_name=$(echo "$basename" | sed 's/-v[0-9]\+\.[0-9]\+\.[0-9]\+$//')

    # Extract version
    local version=$(echo "$basename" | sed -n 's/.*-v\([0-9]\+\.[0-9]\+\.[0-9]\+\)$/\1/p')

    echo "$base_name|$version"
}

# Function to compare versions
compare_versions() {
    local version1="$1"
    local version2="$2"

    # Split versions into arrays
    IFS='.' read -ra v1_parts <<< "$version1"
    IFS='.' read -ra v2_parts <<< "$version2"

    # Compare major, minor, patch
    for i in {0..2}; do
        local v1_part=${v1_parts[$i]:-0}
        local v2_part=${v2_parts[$i]:-0}

        if [[ $v1_part -gt $v2_part ]]; then
            echo "greater"
            return
        elif [[ $v1_part -lt $v2_part ]]; then
            echo "less"
            return
        fi
    done

    echo "equal"
}

# Function to archive outdated prompt
archive_prompt() {
    local file_path="$1"
    local archive_path="$2"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: Would archive $file_path to $archive_path"
        return
    fi

    # Create archive directory if it doesn't exist
    mkdir -p "$(dirname "$archive_path")"

    # Move the file
    mv "$file_path" "$archive_path"
    log_success "Archived: $file_path → $archive_path"
}

# --- Main Script ---
main() {
    log_info "🔍 Checking for outdated prompt versions..."

    # Create archive directory if it doesn't exist
    mkdir -p "$ARCHIVE_DIR"

    # Find all prompt files
    local all_prompts=($(find "$PROMPTS_DIR" -name "*-v*.md" -type f))
    local outdated_count=0
    local archived_count=0

    # Group prompts by base name (using temporary files for compatibility)
    local temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" EXIT

        # First pass: group prompts and find latest versions
    for prompt_file in "${all_prompts[@]}"; do
        local filename=$(basename "$prompt_file")
        local base_version=$(extract_base_and_version "$filename")
        local base_name=$(echo "$base_version" | cut -d'|' -f1)
        local version=$(echo "$base_version" | cut -d'|' -f2)

        if [[ -n "$version" ]]; then
            # Store file in temporary directory by base name
            echo "$prompt_file" >> "$temp_dir/files_$base_name"

            # Track latest version
            local latest_file="$temp_dir/latest_$base_name"
            if [[ ! -f "$latest_file" ]] || [[ "$(compare_versions "$version" "$(cat "$latest_file")")" == "greater" ]]; then
                echo "$version" > "$latest_file"
            fi
        fi
    done

        # Second pass: identify outdated versions
    for base_file in "$temp_dir"/files_*; do
        if [[ -f "$base_file" ]]; then
            local base_name=$(basename "$base_file" | sed 's/^files_//')
            local latest_version=$(cat "$temp_dir/latest_$base_name" 2>/dev/null || echo "")
            local files=($(cat "$base_file"))

            if [[ ${#files[@]} -gt 1 ]]; then
                log_info "📁 Found multiple versions for '$base_name':"

                for file in "${files[@]}"; do
                    local filename=$(basename "$file")
                    local version=$(extract_base_and_version "$filename" | cut -d'|' -f2)

                    if [[ "$version" == "$latest_version" ]]; then
                        log_success "  ✅ $filename (latest: v$version)"
                    else
                        log_warning "  ⚠️  $filename (outdated: v$version, latest: v$latest_version)"
                        outdated_count=$((outdated_count + 1))

                        # Archive outdated version
                        local archive_path="$ARCHIVE_DIR/$(basename "$file")"
                        archive_prompt "$file" "$archive_path"
                        archived_count=$((archived_count + 1))
                    fi
                done
                echo
            fi
        fi
    done

    # Summary
    if [[ $outdated_count -eq 0 ]]; then
        log_success "🎉 No outdated prompt versions found!"
    else
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "📊 Found $outdated_count outdated prompt(s) to archive"
            log_info "💡 Run with --archive to automatically archive them"
        else
            log_success "📊 Successfully archived $archived_count outdated prompt(s)"
        fi
    fi

    # Show archive directory contents
    if [[ -d "$ARCHIVE_DIR" ]] && [[ $(ls -A "$ARCHIVE_DIR" 2>/dev/null) ]]; then
        log_info "📦 Archived prompts:"
        find "$ARCHIVE_DIR" -name "*.md" -type f | while read -r file; do
            echo "  📄 $(basename "$file")"
        done
    fi
}

# --- Script Execution ---
main "$@"
