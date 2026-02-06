#!/bin/bash

# Enforce Organization Standards Script
# Checks for violations of our directory organization standards

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VIOLATIONS=0
WARNINGS=0

echo -e "${BLUE}🔍 DgtlEnv Organization Standards Check${NC}"
echo "=========================================="

# Function to check for violations
check_violation() {
    local pattern="$1"
    local description="$2"
    local severity="$3"

    if find "$PROJECT_ROOT" -name "$pattern" -type f | grep -q .; then
        echo -e "${RED}❌ VIOLATION: $description${NC}"
        find "$PROJECT_ROOT" -name "$pattern" -type f
        if [[ "$severity" == "error" ]]; then
            ((VIOLATIONS++))
        else
            ((WARNINGS++))
        fi
        echo
    else
        echo -e "${GREEN}✅ PASS: $description${NC}"
    fi
}

# Function to check directory structure
check_directory_structure() {
    local dir="$1"
    local description="$2"

    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✅ PASS: $description${NC}"
    else
        echo -e "${YELLOW}⚠️  WARNING: $description${NC}"
        ((WARNINGS++))
    fi
}

# Function to check README files
check_readme_files() {
    local dir="$1"
    local description="$2"

    if [[ -f "$dir/README.md" ]]; then
        echo -e "${GREEN}✅ PASS: $description${NC}"
    else
        echo -e "${RED}❌ VIOLATION: $description${NC}"
        ((VIOLATIONS++))
    fi
}

# Function to check log directory organization
check_log_organization() {
    local logs_dir="$PROJECT_ROOT/logs"

    if [[ -d "$logs_dir" ]]; then
        echo -e "\n${BLUE}📋 Checking Log Directory Organization${NC}"
        echo "----------------------------------------"

        # Check if logs are organized by process type
        local has_subdirs=false
        for subdir in "$logs_dir"/*/; do
            if [[ -d "$subdir" ]]; then
                has_subdirs=true
                local subdir_name=$(basename "$subdir")
                echo -e "${GREEN}✅ PASS: Log subdirectory exists: $subdir_name${NC}"
            fi
        done

        if [[ "$has_subdirs" == false ]]; then
            echo -e "${YELLOW}⚠️  WARNING: Logs not organized by process type${NC}"
            echo -e "${BLUE}💡 Suggestion: Consider creating process-specific log directories${NC}"
            ((WARNINGS++))
        fi

        # Check for log rotation
        if [[ -d "$logs_dir/rotation" ]] || [[ -d "$logs_dir/archives" ]]; then
            echo -e "${GREEN}✅ PASS: Log rotation/archives directory exists${NC}"
        else
            echo -e "${YELLOW}⚠️  WARNING: No log rotation/archives directory${NC}"
            ((WARNINGS++))
        fi
    fi
}

# Function to check todo metrics and dashboard
check_todo_metrics() {
    local master_todo="$PROJECT_ROOT/todos/planning/master-todo.md"
    local todo_dashboard="$PROJECT_ROOT/docs/reports/todo-metrics-dashboard.md"

    echo -e "\n${BLUE}📊 Checking Todo Metrics and Dashboard${NC}"
    echo "----------------------------------------"

    # Check master todo exists and is current
    if [[ -f "$master_todo" ]]; then
        local last_updated=$(grep "Last Updated:" "$master_todo" | head -1 | awk '{print $3}')
        local current_date=$(date '+%Y-%m-%d')

        if [[ "$last_updated" == "$current_date" ]]; then
            echo -e "${GREEN}✅ PASS: Master todo is current (updated today)${NC}"
        else
            echo -e "${YELLOW}⚠️  WARNING: Master todo may be outdated (last updated: $last_updated)${NC}"
            ((WARNINGS++))
        fi

        # Check for progress bars
        if grep -q "████" "$master_todo"; then
            echo -e "${GREEN}✅ PASS: Master todo contains progress charts${NC}"
        else
            echo -e "${YELLOW}⚠️  WARNING: Master todo missing progress charts${NC}"
            ((WARNINGS++))
        fi
    else
        echo -e "${RED}❌ VIOLATION: Master todo file missing${NC}"
        ((VIOLATIONS++))
    fi

    # Check todo metrics dashboard exists
    if [[ -f "$todo_dashboard" ]]; then
        echo -e "${GREEN}✅ PASS: Todo metrics dashboard exists${NC}"

        # Check for ASCII charts in dashboard
        if grep -q "████" "$todo_dashboard"; then
            echo -e "${GREEN}✅ PASS: Todo dashboard contains progress charts${NC}"
        else
            echo -e "${YELLOW}⚠️  WARNING: Todo dashboard missing progress charts${NC}"
            ((WARNINGS++))
        fi

        # Check dashboard is current
        local dashboard_date=$(grep "Last Updated:" "$todo_dashboard" | head -1 | awk '{print $3}')
        if [[ "$dashboard_date" == "$current_date" ]]; then
            echo -e "${GREEN}✅ PASS: Todo dashboard is current (updated today)${NC}"
        else
            echo -e "${YELLOW}⚠️  WARNING: Todo dashboard may be outdated (last updated: $dashboard_date)${NC}"
            ((WARNINGS++))
        fi
    else
        echo -e "${RED}❌ VIOLATION: Todo metrics dashboard missing${NC}"
        ((VIOLATIONS++))
    fi

    # Check active todos directory structure
    local active_todos_dir="$PROJECT_ROOT/todos/active"
    if [[ -d "$active_todos_dir" ]]; then
        local active_todo_count=$(find "$active_todos_dir" -name "*.md" | wc -l | tr -d ' ')
        echo -e "${GREEN}✅ PASS: Active todos directory exists with $active_todo_count todo files${NC}"

        # Check for completed todos that should be moved
        for todo_file in "$active_todos_dir"/*.md; do
            if [[ -f "$todo_file" ]]; then
                local filename=$(basename "$todo_file")
                if grep -q "Status.*Completed" "$todo_file" || grep -q "Status.*\[x\]" "$todo_file"; then
                    echo -e "${YELLOW}⚠️  WARNING: $filename appears completed but still in active directory${NC}"
                    ((WARNINGS++))
                fi
            fi
        done
    else
        echo -e "${RED}❌ VIOLATION: Active todos directory missing${NC}"
        ((VIOLATIONS++))
    fi
}

# Function to check todo quality standards
check_todo_quality() {
    local completed_dir="$PROJECT_ROOT/todos/completed"

    if [[ -d "$completed_dir" ]]; then
        echo -e "\n${BLUE}📋 Checking Todo Quality Standards${NC}"
        echo "----------------------------------------"

        # Check each completed todo file
        for todo_file in "$completed_dir"/*.md; do
            if [[ -f "$todo_file" && "$(basename "$todo_file")" != "README.md" ]]; then
                local filename=$(basename "$todo_file")

                # Check for unchecked boxes (only [ ] is a violation, [-] is allowed for future tasks)
                if grep -q "\[ \]" "$todo_file"; then
                    echo -e "${RED}❌ VIOLATION: $filename has unchecked boxes in completed directory${NC}"
                    ((VIOLATIONS++))
                else
                    echo -e "${GREEN}✅ PASS: $filename has all boxes properly marked${NC}"
                fi

                # Check for proper outcome communication in non-completed tasks
                if grep -q "\[-\]" "$todo_file" && ! grep -q "\[-\].*:" "$todo_file"; then
                    echo -e "${YELLOW}⚠️  WARNING: $filename has [-] tasks without outcome communication${NC}"
                    ((WARNINGS++))
                fi

                if grep -q "\[~\]" "$todo_file" && ! grep -q "\[~\].*:" "$todo_file"; then
                    echo -e "${YELLOW}⚠️  WARNING: $filename has [~] tasks without outcome communication${NC}"
                    ((WARNINGS++))
                fi

                        if grep -q "\[>\]" "$todo_file" && ! grep -q "\[>\].*:" "$todo_file"; then
            echo -e "${YELLOW}⚠️  WARNING: $filename has [>] tasks without outcome communication${NC}"
            ((WARNINGS++))
        fi

        # Check for proper "Moved to" communication
        if grep -q "\[>\]" "$todo_file" && ! grep -q "\[>\].*Moved to:" "$todo_file" && ! grep -q "\[>\].*Deferred to:" "$todo_file"; then
            echo -e "${YELLOW}⚠️  WARNING: $filename has [>] tasks without proper 'Moved to' or 'Deferred to' communication${NC}"
            ((WARNINGS++))
        fi

        # Check for items that should be migrated (but exclude items that already have migration notes)
        if grep -q "\[[-~>!?]\]" "$todo_file" && ! grep -q "MIGRATED:" "$todo_file"; then
            echo -e "${YELLOW}⚠️  WARNING: $filename has dynamic symbol items that should be migrated to appropriate todo files${NC}"
            echo -e "${BLUE}💡 Suggestion: Run ./scripts/migrate-todo-items.sh to migrate these items${NC}"
            ((WARNINGS++))
        elif grep -q "\[[-~>!?]\]" "$todo_file" && grep -q "MIGRATED:" "$todo_file"; then
            echo -e "${GREEN}✅ PASS: $filename has dynamic symbol items that have already been migrated${NC}"
        fi

                if grep -q "\[!\]" "$todo_file" && ! grep -q "\[!\].*:" "$todo_file"; then
                    echo -e "${YELLOW}⚠️  WARNING: $filename has [!] tasks without outcome communication${NC}"
                    ((WARNINGS++))
                fi

                # Check for COMPLETED status (with or without bold formatting)
                if grep -q "✅ COMPLETED" "$todo_file" || grep -q "✅ \*\*COMPLETED\*\*" "$todo_file"; then
                    echo -e "${GREEN}✅ PASS: $filename shows COMPLETED status${NC}"
                else
                    echo -e "${RED}❌ VIOLATION: $filename missing COMPLETED status${NC}"
                    ((VIOLATIONS++))
                fi
            fi
        done
    fi
}

echo -e "\n${BLUE}📁 Checking for Prohibited Files${NC}"
echo "----------------------------------------"

# Check for backup files in docs
check_violation "*.bak" "Backup files in docs directory" "error"
check_violation "*.backup" "Backup files in docs directory" "error"

# Check for system files
check_violation ".DS_Store" "System files (.DS_Store)" "error"

# Check for temporary files
check_violation "*.tmp" "Temporary files" "warning"
check_violation "*.temp" "Temporary files" "warning"

echo -e "\n${BLUE}📋 Checking Directory Structure${NC}"
echo "----------------------------------------"

# Check required directories
check_directory_structure "$PROJECT_ROOT/docs/guides" "Guides directory exists"
check_directory_structure "$PROJECT_ROOT/docs/setup" "Setup directory exists"
check_directory_structure "$PROJECT_ROOT/docs/standards" "Style directory exists"
check_directory_structure "$PROJECT_ROOT/docs/reports" "Reports directory exists"
check_directory_structure "$PROJECT_ROOT/docs/workflows" "Workflows directory exists"
check_directory_structure "$PROJECT_ROOT/docs/development-history" "Development history directory exists"
check_directory_structure "$PROJECT_ROOT/docs/incoming" "Incoming directory exists"

echo -e "\n${BLUE}📖 Checking README Files${NC}"
echo "----------------------------------------"

# Check README files in key directories
check_readme_files "$PROJECT_ROOT/docs" "Main docs README exists"
check_readme_files "$PROJECT_ROOT/docs/guides" "Guides README exists"
check_readme_files "$PROJECT_ROOT/docs/setup" "Setup README exists"
check_readme_files "$PROJECT_ROOT/docs/standards" "Style README exists"
check_readme_files "$PROJECT_ROOT/docs/development-history" "Development history README exists"
check_readme_files "$PROJECT_ROOT/docs/incoming" "Incoming README exists"

# Check metrics subdirectories for README files
check_readme_files "$PROJECT_ROOT/metrics" "Metrics README exists"
check_readme_files "$PROJECT_ROOT/metrics/data" "Metrics data README exists"
check_readme_files "$PROJECT_ROOT/metrics/dashboards" "Metrics dashboards README exists"
check_readme_files "$PROJECT_ROOT/metrics/reports" "Metrics reports README exists"

# Check other key subdirectories
check_readme_files "$PROJECT_ROOT/ops" "Ops README exists"
check_readme_files "$PROJECT_ROOT/ops/backup" "Ops backup README exists"
check_readme_files "$PROJECT_ROOT/ops/cleanup" "Ops cleanup README exists"
check_readme_files "$PROJECT_ROOT/ops/docker" "Ops docker README exists"
check_readme_files "$PROJECT_ROOT/ops/monitoring" "Ops monitoring README exists"
check_readme_files "$PROJECT_ROOT/ops/templates" "Ops templates README exists"

check_readme_files "$PROJECT_ROOT/scripts" "Scripts README exists"
check_readme_files "$PROJECT_ROOT/todos" "Todos README exists"
check_readme_files "$PROJECT_ROOT/todos/active" "Todos active README exists"
check_readme_files "$PROJECT_ROOT/todos/completed" "Todos completed README exists"
check_readme_files "$PROJECT_ROOT/todos/planning" "Todos planning README exists"
check_readme_files "$PROJECT_ROOT/todos/templates" "Todos templates README exists"

check_readme_files "$PROJECT_ROOT/security" "Security README exists"
check_readme_files "$PROJECT_ROOT/security/audit-reports" "Security audit reports README exists"
check_readme_files "$PROJECT_ROOT/security/policies" "Security policies README exists"

check_readme_files "$PROJECT_ROOT/tests" "Tests README exists"
check_readme_files "$PROJECT_ROOT/examples" "Examples README exists"
# Note: logs/ directory is excluded from README requirements as it contains operational/system files
# Additional exclusions for operational directories:
# - logs/ (operational logs)
# - temp/ (temporary files)
# - cache/ (cache files)
# - .git/ (version control)

echo -e "\n${BLUE}🔗 Checking for Scattered Files${NC}"
echo "----------------------------------------"

# Check for files that should be in subdirectories
if find "$PROJECT_ROOT/docs" -maxdepth 1 -name "*.md" | grep -v "README.md" | grep -q .; then
    echo -e "${RED}❌ VIOLATION: Files in docs root that should be in subdirectories${NC}"
    find "$PROJECT_ROOT/docs" -maxdepth 1 -name "*.md" | grep -v "README.md"
    ((VIOLATIONS++))
else
    echo -e "${GREEN}✅ PASS: No scattered files in docs root${NC}"
fi

# Check log directory organization
check_log_organization

# Check todo metrics and dashboard
check_todo_metrics

# Check todo quality standards
check_todo_quality

echo -e "\n${BLUE}📊 Summary${NC}"
echo "----------------------------------------"

if [[ $VIOLATIONS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}🎉 EXCELLENT: All organization standards met!${NC}"
    exit 0
elif [[ $VIOLATIONS -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  GOOD: $WARNINGS warnings found, no violations${NC}"
    exit 0
else
    echo -e "${RED}❌ FAILED: $VIOLATIONS violations and $WARNINGS warnings found${NC}"
    echo -e "${YELLOW}💡 Run './scripts/enforce-organization-standards.sh --fix' to attempt automatic fixes${NC}"
    exit 1
fi

# Fix mode
if [[ "$1" == "--fix" ]]; then
    echo -e "\n${BLUE}🔧 Attempting Automatic Fixes${NC}"
    echo "----------------------------------------"

    # Remove backup files
    echo "Removing backup files..."
    find "$PROJECT_ROOT" -name "*.bak" -delete
    find "$PROJECT_ROOT" -name "*.backup" -delete

    # Remove system files
    echo "Removing system files..."
    find "$PROJECT_ROOT" -name ".DS_Store" -delete

    # Remove temporary files
    echo "Removing temporary files..."
    find "$PROJECT_ROOT" -name "*.tmp" -delete
    find "$PROJECT_ROOT" -name "*.temp" -delete

    echo -e "${GREEN}✅ Automatic fixes completed${NC}"
    echo -e "${YELLOW}💡 Please review and manually organize any remaining scattered files${NC}"
fi
