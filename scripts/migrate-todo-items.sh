#!/bin/bash

# DgtlEnv Todo Migration Script
# Migrates non-completed todo items from completed files to appropriate active/planning todo files

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPLETED_DIR="$PROJECT_ROOT/todos/completed"
ACTIVE_DIR="$PROJECT_ROOT/todos/active"
PLANNING_DIR="$PROJECT_ROOT/todos/planning"
TEMPLATES_DIR="$PROJECT_ROOT/todos/templates"

# Logging
LOG_FILE="$PROJECT_ROOT/logs/migration/todo-migration-$(date +%Y%m%d_%H%M%S).log"

# Create logs directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}ERROR:${NC} $1" | tee -a "$LOG_FILE" >&2
}

success() {
    echo -e "${GREEN}SUCCESS:${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${YELLOW}[DEBUG]${NC} $1" | tee -a "$LOG_FILE"
    fi
}

# Cleanup function
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        error "Script exited with error code: $exit_code"
    fi
    debug "Cleaning up temporary files..."
    if [[ ${#TMP_FILES[@]} -gt 0 ]]; then
        rm -f "${TMP_FILES[@]}" 2>/dev/null || true
    fi
}
trap cleanup EXIT
TMP_FILES=()

# Function to extract todo items with dynamic symbols
extract_todo_items() {
    local file="$1"
    local items=()

    # Extract lines with dynamic symbols
    while IFS= read -r line; do
        if echo "$line" | grep -q "\[[-~>!?]\]"; then
            items+=("$line")
        fi
    done < "$file"

    if [[ ${#items[@]} -gt 0 ]]; then
        printf '%s\n' "${items[@]}"
    fi
}

# Function to determine target todo file based on content
determine_target_file() {
    local item="$1"
    local category=""

    # Determine category based on keywords
    case "$item" in
        *"documentation"*|*"README"*|*"guide"*)
            category="documentation"
            ;;
        *"security"*|*"audit"*|*"vulnerability"*)
            category="security"
            ;;

        *"release"*|*"version"*|*"deploy"*)
            category="release"
            ;;
        *"optimization"*|*"performance"*|*"monitoring"*)
            category="optimization"
            ;;
        *"github"*|*"repository"*|*"setup"*)
            category="github"
            ;;
        *"feature"*|*"enhancement"*|*"improvement"*)
            category="feature"
            ;;
        *"testing"*|*"test"*|*"validation"*)
            category="testing"
            ;;
        *"community"*|*"contributor"*|*"social"*)
            category="community"
            ;;
        *)
            category="general"
            ;;
    esac

    echo "$category"
}

# Function to create or update target todo file
create_or_update_todo_file() {
    local category="$1"
    local target_dir="$2"
    local target_file="$target_dir/${category}-todo.md"
    local source_file="$3"
    local timestamp="$(date +'%Y-%m-%d %H:%M:%S')"

    # Create target directory if it doesn't exist
    mkdir -p "$target_dir"

    # If target file doesn't exist, create it with template
    if [[ ! -f "$target_file" ]]; then
        log "Creating new todo file: $target_file"
        debug "Target directory: $target_dir"

        cat > "$target_file" << EOF
# $(echo "$category" | sed 's/^./\U&/') Todo - **DgtlEnv**

**Created:** $timestamp
**Source:** Migrated from $(basename "$source_file")
**Status:** 🔄 IN PROGRESS

---

## 📋 $(echo "$category" | sed 's/^./\U&/') Tasks

### Migrated Items
*Items migrated from completed todos with dynamic symbols*

EOF
    fi

    echo "$target_file"
}

# Function to migrate a single todo item
migrate_todo_item() {
    local item="$1"
    local source_file="$2"
    local target_dir="$3"
    local timestamp="$(date +'%Y-%m-%d %H:%M:%S')"

    # Extract the original task description
    local original_task=""
    if echo "$item" | grep -q "\[[-~>!?]\]"; then
        original_task=$(echo "$item" | sed 's/.*\[[-~>!?]\][[:space:]]*//')
    fi

    # Determine target file based on content
    local category=$(determine_target_file "$item")
    local target_file=$(create_or_update_todo_file "$category" "$target_dir" "$source_file")

    # Determine symbol and status
    local symbol=""
    local status=""
    local reason=""

    if echo "$item" | grep -q "\[-\]"; then
        symbol="[-]"
        status="Future/Optional"
        reason="Migrated from $(basename "$source_file") - $timestamp"
    elif echo "$item" | grep -q "\[~\]"; then
        symbol="[~]"
        status="In Progress"
        reason="Migrated from $(basename "$source_file") - $timestamp"
    elif echo "$item" | grep -q "\[>\]"; then
        symbol="[>]"
        status="Deferred"
        reason="Migrated from $(basename "$source_file") - $timestamp"
    elif echo "$item" | grep -q "\[!\]"; then
        symbol="[!]"
        status="Blocked"
        reason="Migrated from $(basename "$source_file") - $timestamp"
    elif echo "$item" | grep -q "\[\?\]"; then
        symbol="[?]"
        status="Cancelled"
        reason="Migrated from $(basename "$source_file") - $timestamp"
    fi

    # Add item to target file (only if not dry run)
    if [[ "$DRY_RUN" != "true" ]]; then
        echo "" >> "$target_file"
        echo "- $symbol $original_task - $status: $reason" >> "$target_file"
    fi

    # Enhanced logging with detailed information
    log "MIGRATED ITEM DETAILS:"
    log "  Original Task: $original_task"
    log "  Symbol: $symbol"
    log "  Status: $status"
    log "  Source File: $(basename "$source_file")"
    log "  Target File: $(basename "$target_file")"
    log "  Timestamp: $timestamp"
    log "  Migration Note: $reason"
    log "  Target Directory: $(dirname "$target_file")"
    log "  Category: $category"
    log "---"

    echo "$target_file"
}

# Function to process a completed todo file
process_completed_file() {
    local file="$1"
    local items=$(extract_todo_items "$file")

    if [[ -z "$items" ]]; then
        echo "No dynamic symbol items found in $(basename "$file")" >&2
        echo "0"
        return
    fi

    echo "Processing $(basename "$file") for migration..." >&2
    echo "  Total items to migrate: $(echo "$items" | wc -l | tr -d ' ')" >&2
    echo "  File size: $(wc -l < "$file") lines" >&2
    echo "  File path: $file" >&2

    local migrated_count=0
    local target_files=()

    # Process each item
    while IFS= read -r item; do
        if [[ -n "$item" ]]; then
            # Determine target directory based on symbol
            local target_dir=""
            if echo "$item" | grep -q "\[-\]"; then
                target_dir="$PLANNING_DIR"
            elif echo "$item" | grep -q "\[[~!>]\]"; then
                target_dir="$ACTIVE_DIR"
            else
                target_dir="$PLANNING_DIR"  # Default to planning for unknown symbols
            fi

            local target_file=$(migrate_todo_item "$item" "$file" "$target_dir")
            target_files+=("$target_file")
            ((migrated_count++))
        fi
    done <<< "$items"

            if [[ $migrated_count -gt 0 ]]; then
        echo "SUCCESS: Migrated $migrated_count items from $(basename "$file")" >&2

        # Update source file to mark items as migrated (only if not dry run)
        if [[ "$DRY_RUN" != "true" ]]; then
            local temp_file=$(mktemp)
            TMP_FILES+=("$temp_file")
            local migration_timestamp=$(date +'%Y-%m-%d %H:%M:%S')
            local updated_items=0

            while IFS= read -r line; do
                if echo "$line" | grep -q "\[[-~>!?]\]"; then
                    # Replace dynamic symbol with migration note
                    echo "$line (MIGRATED: $migration_timestamp)" >> "$temp_file"
                    ((updated_items++))
                    echo "  Updated item in source: $(echo "$line" | sed 's/^[[:space:]]*//' | cut -d' ' -f2- | cut -d' ' -f1-3)" >&2
                else
                    echo "$line" >> "$temp_file"
                fi
            done < "$file"

            mv "$temp_file" "$file"
            echo "Updated $(basename "$file") with migration notes ($updated_items items marked)" >&2
        else
            echo "DRY RUN: Would update $(basename "$file") with migration notes ($migrated_count items)" >&2
        fi
    fi

    echo "$migrated_count"
}

# Function to create comprehensive migration report
create_migration_report() {
    local report_file="$PROJECT_ROOT/logs/migration-report-$(date +%Y%m%d_%H%M%S).md"

    cat > "$report_file" << EOF
# Todo Migration Report - **DgtlEnv**

**Generated:** $(date +'%Y-%m-%d %H:%M:%S')
**Migration Log:** $(basename "$LOG_FILE")
**Script Version:** $(basename "$0")

---

## 📊 Migration Statistics

- **Total Processed Files:** $PROCESSED_FILES
- **Total Migrated Items:** $TOTAL_MIGRATIONS
- **Active Todo Files:** $(find "$ACTIVE_DIR" -name "*-todo.md" -type f | wc -l)
- **Planning Todo Files:** $(find "$PLANNING_DIR" -name "*-todo.md" -type f | wc -l)
- **Completed Todo Files:** $(find "$COMPLETED_DIR" -name "*-todo.md" -type f | wc -l)

---

## 🔄 Migration Details

### Source Files Processed
$(find "$COMPLETED_DIR" -name "*-todo.md" -type f -exec basename {} \; | sort)

### Target Files Created/Updated
$(find "$ACTIVE_DIR" "$PLANNING_DIR" -name "*-todo.md" -type f -exec basename {} \; | sort | uniq)

---

## 📋 Migration Rules Applied

| Dynamic Symbol | Status | Target Directory | Items Migrated |
|----------------|--------|------------------|----------------|
| \`[-]\` | Future/Optional | \`todos/planning/\` | $(grep -c "\[-\]" "$LOG_FILE" 2>/dev/null || echo "0") |
| \`[~]\` | In Progress | \`todos/active/\` | $(grep -c "\[~\]" "$LOG_FILE" 2>/dev/null || echo "0") |
| \`[>]\` | Deferred | \`todos/active/\` | $(grep -c "\[>\]" "$LOG_FILE" 2>/dev/null || echo "0") |
| \`[!]\` | Blocked | \`todos/active/\` | $(grep -c "\[!\]" "$LOG_FILE" 2>/dev/null || echo "0") |
| \`[?]\` | Cancelled | \`todos/completed/\` | $(grep -c "\[\?\]" "$LOG_FILE" 2>/dev/null || echo "0") |

---

## 📁 File Structure Changes

### Before Migration
\`\`\`
todos/
├── completed/     # Original completed files
└── active/        # Existing active files
\`\`\`

### After Migration
\`\`\`
todos/
├── completed/     # Files with migration notes
├── active/        # Enhanced with migrated items
└── planning/      # New files with future/optional items
\`\`\`

---

## 🔗 Related Documentation

- **Enforcement Script:** \`scripts/enforce-organization-standards.sh\`

---

**Status:** ✅ **MIGRATION COMPLETED**
**Next Action:** Review migrated items and update project documentation
EOF

    echo "Created comprehensive migration report: $report_file" >&2
    echo "$report_file"
}

# Function to update README files
update_readme_files() {
    log "Updating README files..."

    # Update active README
    if [[ -f "$ACTIVE_DIR/README.md" ]]; then
        local active_files=$(find "$ACTIVE_DIR" -name "*-todo.md" -type f | wc -l)
        sed -i.bak "s/Currently Active Tasks (4)/Currently Active Tasks ($active_files)/" "$ACTIVE_DIR/README.md"
        rm "$ACTIVE_DIR/README.md.bak" 2>/dev/null || true
    fi

    # Update planning README
    if [[ -f "$PLANNING_DIR/README.md" ]]; then
        local planning_files=$(find "$PLANNING_DIR" -name "*-todo.md" -type f | wc -l)
        sed -i.bak "s/Planning and Strategy Tasks (2)/Planning and Strategy Tasks ($planning_files)/" "$PLANNING_DIR/README.md"
        rm "$PLANNING_DIR/README.md.bak" 2>/dev/null || true
    fi

    # Update main todos README
    if [[ -f "$PROJECT_ROOT/todos/README.md" ]]; then
        local total_active=$(find "$ACTIVE_DIR" -name "*-todo.md" -type f | wc -l)
        local total_completed=$(find "$COMPLETED_DIR" -name "*-todo.md" -type f | wc -l)
        local total_planning=$(find "$PLANNING_DIR" -name "*-todo.md" -type f | wc -l)

        sed -i.bak "s/Active Tasks (4)/Active Tasks ($total_active)/" "$PROJECT_ROOT/todos/README.md"
        sed -i.bak "s/Completed Tasks (7)/Completed Tasks ($total_completed)/" "$PROJECT_ROOT/todos/README.md"
        sed -i.bak "s/Planning Tasks (2)/Planning Tasks ($total_planning)/" "$PROJECT_ROOT/todos/README.md"
        rm "$PROJECT_ROOT/todos/README.md.bak" 2>/dev/null || true
    fi

    success "Updated README files with new counts"
}

# Global variables for tracking migration progress
PROCESSED_FILES=0
TOTAL_MIGRATIONS=0

# Main execution
main() {
    log "Starting todo migration process..."

    # Check if completed directory exists
    if [[ ! -d "$COMPLETED_DIR" ]]; then
        error "Completed directory not found: $COMPLETED_DIR"
        exit 1
    fi

    # Initialize variables
    PROCESSED_FILES=0
    # Initialize variables
    PROCESSED_FILES=0
    TOTAL_MIGRATIONS=0

    # check for required commands
    for cmd in grep sed awk mktemp; do
        if ! command -v $cmd &> /dev/null; then
            error "Required command not found: $cmd"
            exit 1
        fi
    done
    debug "All required dependencies found."

    log "Starting to process files in $COMPLETED_DIR..."
    local total_files_to_process=$(find "$COMPLETED_DIR" -name "*-todo.md" -type f | wc -l)
    log "Found $total_files_to_process files to process"

    while IFS= read -r -d '' file; do
        if [[ -f "$file" && "$file" =~ -todo\.md$ ]]; then
            log "Processing file: $file"
            local file_migrations=$(process_completed_file "$file")
            TOTAL_MIGRATIONS=$((TOTAL_MIGRATIONS + file_migrations))
            ((PROCESSED_FILES++))
            log "Completed processing file: $file (migrations: $file_migrations)"
            log "Progress: $PROCESSED_FILES/$total_files_to_process files processed"
        fi
    done < <(find "$COMPLETED_DIR" -name "*-todo.md" -type f -print0)

    log "Finished processing all files. Total processed: $PROCESSED_FILES, Total migrations: $TOTAL_MIGRATIONS"

    # Update README files
    update_readme_files

    # Create comprehensive migration report
    log "Creating migration report..."
    local report_file=$(create_migration_report)
    if [[ -f "$report_file" ]]; then
        success "Migration report created: $report_file"
    else
        error "Failed to create migration report"
        exit 1
    fi

    # Summary
    log "Migration complete!"
    log "Processed $PROCESSED_FILES completed todo files"
    log "Migration log: $LOG_FILE"

    # Enhanced summary with file statistics
    local total_active_files=$(find "$ACTIVE_DIR" -name "*-todo.md" -type f | wc -l)
    local total_planning_files=$(find "$PLANNING_DIR" -name "*-todo.md" -type f | wc -l)
    local total_completed_files=$(find "$COMPLETED_DIR" -name "*-todo.md" -type f | wc -l)

    log "MIGRATION SUMMARY:"
    log "  Active todo files: $total_active_files"
    log "  Planning todo files: $total_planning_files"
    log "  Completed todo files: $total_completed_files"
    log "  Total processed files: $PROCESSED_FILES"
    log "  Log file location: $LOG_FILE"
    log "  Log file size: $(wc -c < "$LOG_FILE" 2>/dev/null || echo "0") bytes"

    success "Todo migration completed successfully"
}

# Help function
show_help() {
    cat << EOF
DgtlEnv Todo Migration Script

Usage: $0 [OPTIONS]

Options:
    -h, --help      Show this help message
    -d, --dry-run   Show what would be migrated without making changes
    -v, --verbose   Enable verbose output

Description:
    Migrates non-completed todo items from completed files to appropriate
    active/planning todo files based on dynamic symbols and content.

    Dynamic Symbols:
    [-] Future/Optional → Moved to planning/
    [~] In Progress → Moved to active/
    [>] Deferred → Moved to active/ or specified target
    [!] Blocked → Moved to active/
    [?] Cancelled → Remains in completed with reason

Examples:
    $0                    # Run migration
    $0 --dry-run         # Show what would be migrated
    $0 --verbose         # Run with detailed output

EOF
}

# Parse command line arguments
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main "$@"
