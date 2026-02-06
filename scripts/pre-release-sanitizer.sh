#!/bin/bash
# Pre-Release Sanitizer for DgtlEnv
# Automatically checks for and fixes personal information before public releases
# Usage: ./scripts/pre-release-sanitizer.sh [--fix] [--dry-run]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source centralized variables
if [[ -f "${PROJECT_ROOT}/config/variables.sh" ]]; then
    source "${PROJECT_ROOT}/config/variables.sh"
fi

DRY_RUN=false
AUTO_FIX=false

# Sensitive patterns to search for
# Note: These values are used for search patterns
PERSONAL_NAME="DgtlEnv Maintainer"
# Allow overriding the exact path via env var, else assume standard mac path
PERSONAL_PATH="/Users/sap"

# Personal information patterns to check
PERSONAL_PATTERNS=(
    "$PERSONAL_PATH/"        # Absolute paths with username
    "$PERSONAL_NAME"         # Personal name
    "/Users/[^/]+/"          # Any absolute user paths
    "@gmail.com"             # Email addresses
    "@yahoo.com"
    "@hotmail.com"
    "@outlook.com"
    "[0-9]{3}-[0-9]{3}-[0-9]{4}"  # Phone numbers
    "[0-9]{10,11}"          # Phone numbers without dashes
)

# Credential patterns to check
CREDENTIAL_PATTERNS=(
    "api_key"
    "api-key"
    "apikey"
    "password"
    "passwd"
    "pwd"
    "token"
    "secret"
    "private_key"
    "private-key"
    "ssh_key"
    "ssh-key"
)

# File types to exclude from scanning
EXCLUDE_PATTERNS=(
    ".git"
    "node_modules"
    ".personal"
    "*.log"
    "*.tmp"
    "*.bak"
    "*.backup"
    "*.pdf"
    "*pre-release-sanitizer.sh"
    "security/audit-reports"
    "todos/pre-release-workflow-todo.md"
    "security/README.md"
)

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  DgtlEnv Pre-Release Sanitizer${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

# Function to check todo metrics and dashboard
check_todo_metrics() {
    local master_todo="$PROJECT_ROOT/todos/planning/master-todo.md"
    local todo_dashboard="$PROJECT_ROOT/.personal/docs/reports/todo-metrics-dashboard.md"

    print_section "Checking Todo Metrics and Dashboard"

    # Check master todo exists and is current
    if [[ -f "$master_todo" ]]; then
        local last_updated=$(grep "Last Updated:" "$master_todo" | head -1 | awk '{print $3}')
        local current_date=$(date '+%Y-%m-%d')

        if [[ "$last_updated" == "$current_date" ]]; then
            print_success "Master todo is current (updated today)"
        else
            print_warning "Master todo may be outdated (last updated: $last_updated)"
        fi

        # Check for progress bars
        if grep -q "████" "$master_todo"; then
            print_success "Master todo contains progress charts"
        else
            print_warning "Master todo missing progress charts"
        fi
    else
        print_error "Master todo file missing"
        return 1
    fi

    # Check todo metrics dashboard exists
    if [[ -f "$todo_dashboard" ]]; then
        print_success "Todo metrics dashboard exists"

        # Check for ASCII charts in dashboard
        if grep -q "████" "$todo_dashboard"; then
            print_success "Todo dashboard contains progress charts"
        else
            print_warning "Todo dashboard missing progress charts"
        fi

        # Check dashboard is current
        local dashboard_date=$(grep "Last Updated:" "$todo_dashboard" | head -1 | awk '{print $3}')
        if [[ "$dashboard_date" == "$current_date" ]]; then
            print_success "Todo dashboard is current (updated today)"
        else
            print_warning "Todo dashboard may be outdated (last updated: $dashboard_date)"
        fi
    else
        print_error "Todo metrics dashboard missing"
        return 1
    fi

    # Check active todos directory structure
    local active_todos_dir="$PROJECT_ROOT/todos/active"
    if [[ -d "$active_todos_dir" ]]; then
        local active_todo_count=$(find "$active_todos_dir" -name "*.md" | wc -l | tr -d ' ')
        print_success "Active todos directory exists with $active_todo_count todo files"

        # Check for completed todos that should be moved
        for todo_file in "$active_todos_dir"/*.md; do
            if [[ -f "$todo_file" ]]; then
                local filename=$(basename "$todo_file")
                if grep -q "Status.*Completed" "$todo_file" || grep -q "Status.*\[x\]" "$todo_file"; then
                    print_warning "$filename appears completed but still in active directory"
                fi
            fi
        done
    else
        print_error "Active todos directory missing"
        return 1
    fi
}

print_section() {
    echo -e "${YELLOW}$1${NC}"
    echo "----------------------------------------"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    --fix          Automatically fix issues found
    --dry-run      Show what would be changed without making changes
    --help         Show this help message

Examples:
    $0 --dry-run                    # Check for issues without fixing
    $0 --fix                        # Check and automatically fix issues
    $0 --fix --dry-run              # Show what would be fixed

EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --fix)
                AUTO_FIX=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

create_exclude_args() {
    local exclude_args=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        if [[ "$pattern" == *"*"* ]]; then
            # Handle wildcard patterns
            exclude_args="$exclude_args --exclude=$pattern"
        else
            # Handle directory patterns
            exclude_args="$exclude_args --exclude-dir=$pattern"
        fi
    done
    echo "$exclude_args"
}

check_personal_information() {
    print_section "Checking for Personal Information"

    local issues_found=false
    local exclude_args=$(create_exclude_args)

    # Check for absolute paths with usernames (these should be fixed)
    for pattern in "${PERSONAL_PATTERNS[@]}"; do
        local matches=$(grep -r "$pattern" "$PROJECT_ROOT" $exclude_args 2>/dev/null || true)

        # Filter out authorized contact email if configured
        if [[ -n "$matches" && -n "${CONTACT_EMAIL:-}" ]]; then
            matches=$(echo "$matches" | grep -vF "$CONTACT_EMAIL" || true)
        fi

        if [[ -n "$matches" ]]; then
            print_warning "Found personal information pattern: $pattern"
            echo "$matches" | while IFS= read -r line; do
                if [[ -n "$line" ]]; then
                    echo "  $line"
                fi
            done
            issues_found=true
        fi
    done

    # Check for username "sap" in file paths (these should be reported but not auto-fixed)
    local username_matches=$(grep -r "sap" "$PROJECT_ROOT" $exclude_args 2>/dev/null || true)

    if [[ -n "$username_matches" ]]; then
        print_info "Found username references (manual review recommended):"
        echo "$username_matches" | while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                echo "  $line"
            fi
        done
    fi

    if [[ "$issues_found" == false ]]; then
        print_success "No personal information found"
    fi

    return $([[ "$issues_found" == true ]] && echo 1 || echo 0)
}

check_credentials() {
    print_section "Checking for Credentials"

    local issues_found=false
    local exclude_args=$(create_exclude_args)

    for pattern in "${CREDENTIAL_PATTERNS[@]}"; do
        local matches=$(grep -r -i "$pattern" "$PROJECT_ROOT" $exclude_args 2>/dev/null || true)

        if [[ -n "$matches" ]]; then
            print_warning "Found potential credential pattern: $pattern"
            echo "$matches" | while IFS= read -r line; do
                if [[ -n "$line" ]]; then
                    echo "  $line"
                fi
            done
            issues_found=true
        fi
    done

    if [[ "$issues_found" == false ]]; then
        print_success "No credentials found"
    fi

    return $([[ "$issues_found" == true ]] && echo 1 || echo 0)
}

check_file_permissions() {
    print_section "Checking File Permissions"

    local issues_found=false

    # Check for files with overly permissive permissions
    local permissive_files=$(find "$PROJECT_ROOT" -type f -perm 777 2>/dev/null || true)

    if [[ -n "$permissive_files" ]]; then
        print_warning "Found files with overly permissive permissions (777):"
        echo "$permissive_files" | while IFS= read -r file; do
            if [[ -n "$file" ]]; then
                echo "  $file"
            fi
        done
        issues_found=true
    fi

    # Check for executable files that shouldn't be
    local unexpected_executables=$(find "$PROJECT_ROOT" -type f -executable -name "*.md" -o -name "*.txt" -o -name "*.json" 2>/dev/null || true)

    if [[ -n "$unexpected_executables" ]]; then
        print_warning "Found non-script files with executable permissions:"
        echo "$unexpected_executables" | while IFS= read -r file; do
            if [[ -n "$file" ]]; then
                echo "  $file"
            fi
        done
        issues_found=true
    fi

    if [[ "$issues_found" == false ]]; then
        print_success "File permissions look good"
    fi

    return $([[ "$issues_found" == true ]] && echo 1 || echo 0)
}

fix_personal_information() {
    print_section "Fixing Personal Information"

    if [[ "$DRY_RUN" == true ]]; then
        print_info "DRY RUN: Would fix the following issues:"
    else
        print_info "Fixing personal information issues..."
    fi

    # Fix absolute paths with usernames
    local files_to_fix=(
        "docs/mbp-hardware.md"
        "docs/mbp-systemsoftware.md"
        "docs/MacBookPro-Retina-15-inch-Mid2015-Technical Specifications-AppleSupport.md"
        "metrics/pdf-processing-dashboard.md"
    )

    for file in "${files_to_fix[@]}"; do
        if [[ -f "$PROJECT_ROOT/$file" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                print_info "Would fix: $file"
            else
                # Replace absolute paths with relative paths
                sed -i '' 's|/Users/[^/]*/Dropbox/Admin/DgtlEnv/|./|g' "$PROJECT_ROOT/$file"
                sed -i '' 's|/Users/[^/]*/|$HOME/|g' "$PROJECT_ROOT/$file"
                print_success "Fixed: $file"
            fi
        fi
    done

    # Fix any remaining absolute paths in documentation
    if [[ "$DRY_RUN" == false ]]; then
        find "$PROJECT_ROOT/docs" -name "*.md" -exec sed -i '' 's|/Users/[^/]*/|$HOME/|g' {} \;
        find "$PROJECT_ROOT/metrics" -name "*.md" -exec sed -i '' 's|/Users/[^/]*/|$HOME/|g' {} \;
    fi
}

fix_file_permissions() {
    print_section "Fixing File Permissions"

    if [[ "$DRY_RUN" == true ]]; then
        print_info "DRY RUN: Would fix file permissions"
    else
        # Make scripts executable
        find "$PROJECT_ROOT" -name "*.sh" -exec chmod +x {} \;

        # Remove executable permissions from non-script files
        find "$PROJECT_ROOT" -type f -executable \( -name "*.md" -o -name "*.txt" -o -name "*.json" \) -exec chmod 644 {} \;

        print_success "File permissions fixed"
    fi
}

generate_report() {
    print_section "Sanitization Report"

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local report_file="$PROJECT_ROOT/logs/sanitization-report-$(date '+%Y%m%d-%H%M%S').md"

    # Create logs directory if it doesn't exist
    mkdir -p "$PROJECT_ROOT/logs"

    cat > "$report_file" << EOF
# Sanitization Report

**Date:** $timestamp
**Mode:** $([[ "$DRY_RUN" == true ]] && echo "Dry Run" || echo "Live Fix")
**Auto-Fix:** $([[ "$AUTO_FIX" == true ]] && echo "Enabled" || echo "Disabled")

## Summary
- Personal information check: $([[ $1 -eq 0 ]] && echo "✅ PASS" || echo "❌ FAIL")
- Credentials check: $([[ $2 -eq 0 ]] && echo "✅ PASS" || echo "❌ FAIL")
- File permissions check: $([[ $3 -eq 0 ]] && echo "✅ PASS" || echo "❌ FAIL")
- Todo metrics check: $([[ $4 -eq 0 ]] && echo "✅ PASS" || echo "❌ FAIL")

## Recommendations
$(if [[ $1 -eq 1 || $2 -eq 1 || $3 -eq 1 || $4 -eq 1 ]]; then
    echo "- Review and fix issues before release"
    echo "- Run sanitizer with --fix flag to auto-fix issues"
    echo "- Verify all changes before pushing to repository"
    echo "- Update todo metrics and dashboard if needed"
else
    echo "- Repository is ready for public release"
    echo "- All security checks passed"
    echo "- Todo metrics are current and complete"
fi)

## Next Steps
1. Review any remaining issues manually
2. Test the repository after sanitization
3. Push to public repository with confidence

---
*Generated by DgtlEnv Pre-Release Sanitizer*
EOF

    print_success "Report generated: $report_file"
}

main() {
    print_header

    # Parse command line arguments
    parse_args "$@"

    print_info "Mode: $([[ "$DRY_RUN" == true ]] && echo "Dry Run" || echo "Live")"
    print_info "Auto-Fix: $([[ "$AUTO_FIX" == true ]] && echo "Enabled" || echo "Disabled")"
    echo

    # Run checks
    check_personal_information
    local personal_issues=$?

    check_credentials
    local credential_issues=$?

    check_file_permissions
    local permission_issues=$?

    check_todo_metrics
    local todo_issues=$?

    echo

    # Apply fixes if requested
    if [[ "$AUTO_FIX" == true ]]; then
        if [[ $personal_issues -eq 1 ]]; then
            fix_personal_information
        fi

        if [[ $permission_issues -eq 1 ]]; then
            fix_file_permissions
        fi

        echo
        print_section "Re-running checks after fixes"

        check_personal_information
        personal_issues=$?

        check_credentials
        credential_issues=$?

        check_file_permissions
        permission_issues=$?
    fi

    echo

    # Generate report
    generate_report $personal_issues $credential_issues $permission_issues $todo_issues

    # Final status
    if [[ $personal_issues -eq 0 && $credential_issues -eq 0 && $permission_issues -eq 0 && $todo_issues -eq 0 ]]; then
        print_success "All checks passed! Repository is ready for public release."
        exit 0
    else
        print_warning "Some issues found. Review the report and fix before release."
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
