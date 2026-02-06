#!/bin/bash
set -euo pipefail

# Scripts/Manage-Readmes.sh
# A unified tool for managing, validating, and updating Directory READMEs in DgtlEnv.

# --- Configuration ---
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Helper Functions ---
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    echo "Usage: $0 <command> [options]"
    echo
    echo "Commands:"
    echo "  create <dir>      Create a README for a specific directory"
    echo "  missing           Scan and create READMEs for all missing directories"
    echo "  update            Batch update all READMEs to meet standards"
    echo "  check             Validate compliance of all README files"
    echo "  help              Show this help message"
    echo
}

# --- Command: Create Single ---
cmd_create_single() {
    local directory="$1"

    if [ -z "$directory" ]; then
        log_error "Please provide a directory path."
        echo "Usage: $0 create <directory-path>"
        return 1
    fi

    if [ ! -d "$directory" ]; then
        log_error "Directory '$directory' does not exist."
        return 1
    fi

    if [ -f "$directory/README.md" ]; then
        log_warn "README.md already exists in '$directory'."
        echo "Overwrite? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Cancelled."
            return 0
        fi
    fi

    local dir_name=$(basename "$directory")

    # Discovery
    local files=$(find "$directory" -maxdepth 1 -type f -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.yml" | head -10)
    local subdirs=$(find "$directory" -maxdepth 1 -type d | tail -n +2 | head -10)

    # Template
    cat > "$directory/README.md" << EOF
# $dir_name Overview

**Purpose:** [Brief description of directory purpose]
**Contents:** Main files and subdirectories
**Usage:** How to use files in this directory
**Related:** Links to related documentation

## 📁 Contents

### **Files**
EOF

    if [ -n "$files" ]; then
        echo "$files" | while read -r file; do
            if [ -f "$file" ]; then
                echo "- \`$(basename "$file")\` - [Description]" >> "$directory/README.md"
            fi
        done
    else
        echo "- No files found" >> "$directory/README.md"
    fi

    cat >> "$directory/README.md" << EOF

### **Subdirectories**
EOF

    if [ -n "$subdirs" ]; then
        echo "$subdirs" | while read -r subdir; do
            if [ -d "$subdir" ]; then
                echo "- \`$(basename "$subdir")/\` - [Content description]" >> "$directory/README.md"
            fi
        done
    else
        echo "- No subdirectories found" >> "$directory/README.md"
    fi

    cat >> "$directory/README.md" << EOF

## 🚀 Quick Start

\`\`\`bash
# Example commands
\`\`\`

## 🔗 Related Documentation
- \`../README.md\` - Parent directory

---
**Last Updated:** $(date +%Y-%m-%d)
EOF

    log_success "Created README.md for '$directory'"
}

# --- Command: Missing ---
cmd_scan_missing() {
    log_info "Scanning for missing README files..."
    local created_count=0

    # Find directories missing READMEs, excluding hidden/system dirs
    while IFS= read -r dir; do
        if [ ! -f "$dir/README.md" ]; then
            log_info "Creating README for: $dir"
            # Call create single logic directly to avoid subshell prompts
             # NOTE: Reusing logic is hard without refactoring args, so we'll just shell out or duplicate logic.
             # Duplicating logic slightly for automation (no prompts) is cleaner for batch.

             local dir_name=$(basename "$dir")
             cat > "$dir/README.md" << EOF
# $dir_name Overview
**Purpose:** Auto-generated placeholder
## 📁 Contents
## 🚀 Quick Start
EOF
            log_success "Generated placeholder for $dir"
            ((created_count++))
        fi
    done < <(find . -type d -not -path "./.git*" -not -path "./.cursor*" -not -path "./.vscode*" -not -path "./node_modules*" -not -path ".")

    log_success "Created $created_count missing README files."
}

# --- Command: Batch Update ---
cmd_batch_update() {
    log_info "Scanning for READMEs needing updates..."
    local updated_count=0

    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
             if ! grep -q "## 📁 Contents" "$file" || ! grep -q "## 🚀 Quick Start" "$file"; then
                log_info "Updating: $file"
                cp "$file" "$file.backup"

                # Append missing sections safely
                if ! grep -q "## 📁 Contents" "$file"; then
                    echo -e "\n## 📁 Contents\n\n### **Files**\n[Auto-generated section]\n\n### **Subdirectories**\n" >> "$file"
                fi
                if ! grep -q "## 🚀 Quick Start" "$file"; then
                    echo -e "\n## 🚀 Quick Start\n\`\`\`bash\n# commands\n\`\`\`\n" >> "$file"
                fi
                ((updated_count++))
             fi
        fi
    done < <(find . -name "README.md" -not -path "./.git*" -not -path "./node_modules*" -print0)

    log_success "Updated $updated_count README files."
}

# --- Command: Check ---
cmd_check() {
    log_info "Validating README files..."
    local total=0
    local valid=0
    local invalid=0
    local missing=0

    while IFS= read -r -d '' dir; do
        ((total++))
        if [ -f "$dir/README.md" ]; then
             if grep -q "## 📁 Contents" "$dir/README.md" && grep -q "## 🚀 Quick Start" "$dir/README.md"; then
                ((valid++))
             else
                echo -e "${YELLOW}Invalid:${NC} $dir/README.md"
                ((invalid++))
             fi
        else
            echo -e "${RED}Missing:${NC} $dir"
            ((missing++))
        fi
    done < <(find . -type d -not -path "./.git*" -not -path "./.cursor*" -not -path "./.vscode*" -not -path "./node_modules*" -not -path "." -print0)

    echo "----------------------------------------"
    echo "Total: $total | Valid: $valid | Invalid: $invalid | Missing: $missing"
    if [ $valid -eq $total ]; then
        log_success "All compliant!"
    else
        log_warn "Compliance gaps found."
        exit 1
    fi
}

# --- Main Dispatcher ---
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi

    case "$1" in
        create)  cmd_create_single "$2" ;;
        missing) cmd_scan_missing ;;
        update)  cmd_batch_update ;;
        check)   cmd_check ;;
        help)    show_help ;;
        *)       log_error "Unknown command: $1"; show_help; exit 1 ;;
    esac
}

main "$@"
