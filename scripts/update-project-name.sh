#!/bin/bash

# Update Project Name Script for DgtlEnv
# Updates all references from "DgtlEnv" to "DgtlEnv" and establishes README as source of truth

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config/project-config.json"
README_FILE="$PROJECT_ROOT/README.md"

# Function to get project name from config
get_project_name() {
    if [ -f "$CONFIG_FILE" ]; then
        jq -r '.project.name' "$CONFIG_FILE" 2>/dev/null || echo "DgtlEnv"
    else
        echo "DgtlEnv"
    fi
}

# Function to get project full name from config
get_project_full_name() {
    if [ -f "$CONFIG_FILE" ]; then
        jq -r '.project.fullName' "$CONFIG_FILE" 2>/dev/null || echo "DgtlEnv - Digital Environment Management"
    else
        echo "DgtlEnv - Digital Environment Management"
    fi
}

# Function to update README header with source of truth information
update_readme_header() {
    local temp_file=$(mktemp)
    local project_name=$(get_project_name)
    local project_full_name=$(get_project_full_name)

    cat > "$temp_file" << EOF
# $project_full_name

> **📋 Project Name Source of Truth:** This README.md file serves as the authoritative source for the project name "$project_name". All documentation and scripts should reference this file for consistent naming.

> **⚙️ Configuration:** Project configuration is centralized in \`config/project-config.json\` for programmatic access.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-12.7.6%20Monterey-blue.svg)](https://www.apple.com/macos/)
[![System Status](https://img.shields.io/badge/System%20Status-Optimized-brightgreen.svg)](https://github.com/dgtlenv-maintainer/$project_name)
[![PDF Conversion](https://img.shields.io/badge/PDF%20Conversion-100%25-success.svg)](https://github.com/dgtlenv-maintainer/$project_name)
[![Memory Usage](https://img.shields.io/badge/Memory%20Usage-34%25-green.svg)](https://github.com/dgtlenv-maintainer/$project_name)
[![CPU Usage](https://img.shields.io/badge/CPU%20Usage-14%25-green.svg)](https://github.com/dgtlenv-maintainer/$project_name)

**Device:** MacBook Pro (Retina, 15-inch, Mid 2015)
**OS:** macOS 12.7.6 Monterey
**Status:** ✅ **OPTIMIZED & MONITORED**
**Repository Created:** July 25, 2025
**Last Updated:** July 26, 2025

---

## 🎯 Project Overview

🚀 **$project_name** is a personal experimental project focused on improving my environment to run modern products. Contains explorations for internal management and personal interests in design, development, context systems, and processes. Features automated system monitoring, PDF document management, performance metrics tracking, and semantic resource optimization.
EOF

    # Backup original README
    cp "$README_FILE" "${README_FILE}.backup"

    # Get the rest of the README content (skip the first few lines)
    tail -n +20 "$README_FILE" >> "$temp_file"

    # Replace with new version
    mv "$temp_file" "$README_FILE"

    echo -e "${GREEN}✅ README updated with source of truth information${NC}"
}

# Function to replace DgtlEnv with DgtlEnv in files
replace_project_name() {
    local file="$1"
    local backup_suffix=".bak"

    if [ -f "$file" ]; then
        # Create backup
        cp "$file" "${file}${backup_suffix}"

        # Replace DgtlEnv with DgtlEnv
        sed -i '' 's/DgtlEnv/DgtlEnv/g' "$file"

        echo -e "${GREEN}✅ Updated: $(basename "$file")${NC}"
    fi
}

# Function to update specific script names
update_script_names() {
    local project_name=$(get_project_name)
    local lowercase_name=$(echo "$project_name" | tr '[:upper:]' '[:lower:]')

    # Update backup script name
    if [ -f "$PROJECT_ROOT/ops/backup/create-digitalenv-backup.sh" ]; then
        mv "$PROJECT_ROOT/ops/backup/create-digitalenv-backup.sh" "$PROJECT_ROOT/ops/backup/create-${lowercase_name}-backup.sh"
        echo -e "${GREEN}✅ Renamed: create-digitalenv-backup.sh → create-${lowercase_name}-backup.sh${NC}"
    fi
}

# Function to update all files in the project
update_all_files() {
    echo -e "${BLUE}🔄 Updating project name references...${NC}"

    # Find all files that might contain the old name
    local files_to_update=(
        "$PROJECT_ROOT/README.md"
        "$PROJECT_ROOT/CONTRIBUTING.md"
        "$PROJECT_ROOT/CHANGELOG.md"
        "$PROJECT_ROOT/docs/"*.md
        "$PROJECT_ROOT/ops/"*.md
        "$PROJECT_ROOT/ops/backup/"*.md
        "$PROJECT_ROOT/ops/cleanup/"*.md
        "$PROJECT_ROOT/ops/docker/"*.md
        "$PROJECT_ROOT/ops/monitoring/"*.md
        "$PROJECT_ROOT/ops/templates/"*.md
        "$PROJECT_ROOT/scripts/"*.sh
        "$PROJECT_ROOT/metrics/"*.sh
        "$PROJECT_ROOT/security/"*.md
        "$PROJECT_ROOT/security/policies/"*.md
        "$PROJECT_ROOT/security/audit-reports/"*.md
        "$PROJECT_ROOT/todos/"*.md
        "$PROJECT_ROOT/examples/"*.md
        "$PROJECT_ROOT/tests/"*.md
        "$PROJECT_ROOT/config/"*.md
        "$PROJECT_ROOT/.github/"*.md
        "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/"*.md
    )

    for file in "${files_to_update[@]}"; do
        if [ -f "$file" ]; then
            replace_project_name "$file"
        fi
    done

    # Update script names
    update_script_names

    echo -e "${GREEN}✅ Project name update completed${NC}"
}

# Function to show current project configuration
show_config() {
    local project_name=$(get_project_name)
    local project_full_name=$(get_project_full_name)

    echo -e "${BLUE}=== Current Project Configuration ===${NC}"
    echo ""
    echo -e "${YELLOW}Project Name:${NC} $project_name"
    echo -e "${YELLOW}Full Name:${NC} $project_full_name"
    echo ""

    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}Configuration File:${NC} $CONFIG_FILE"
        echo -e "${YELLOW}Configuration Status:${NC} ✅ Available"
    else
        echo -e "${YELLOW}Configuration File:${NC} $CONFIG_FILE"
        echo -e "${YELLOW}Configuration Status:${NC} ❌ Not found"
    fi

    echo ""
    echo -e "${YELLOW}README Status:${NC} ✅ Source of truth established"
    echo ""
}

# Function to validate naming consistency
validate_naming() {
    echo -e "${BLUE}🔍 Validating naming consistency...${NC}"

    local project_name=$(get_project_name)
    local inconsistencies=0

    # Check for remaining "DgtlEnv" references
    local digitalenv_count=$(grep -r "DgtlEnv" "$PROJECT_ROOT" --exclude-dir=.git --exclude="*.bak" --exclude="*.backup" | wc -l)

    if [ "$digitalenv_count" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Found $digitalenv_count remaining 'DgtlEnv' references:${NC}"
        grep -r "DgtlEnv" "$PROJECT_ROOT" --exclude-dir=.git --exclude="*.bak" --exclude="*.backup" | head -10
        inconsistencies=$((inconsistencies + 1))
    else
        echo -e "${GREEN}✅ No remaining 'DgtlEnv' references found${NC}"
    fi

    # Check for correct "DgtlEnv" usage
    local dgtlenv_count=$(grep -r "DgtlEnv" "$PROJECT_ROOT" --exclude-dir=.git --exclude="*.bak" --exclude="*.backup" | wc -l)
    echo -e "${GREEN}✅ Found $dgtlenv_count 'DgtlEnv' references${NC}"

    if [ "$inconsistencies" -eq 0 ]; then
        echo -e "${GREEN}✅ Naming validation passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Naming validation completed with $inconsistencies issues${NC}"
    fi
}

# Function to create naming guidelines
create_naming_guidelines() {
    local guidelines_file="$PROJECT_ROOT/docs/naming-guidelines.md"

    cat > "$guidelines_file" << EOF
# DgtlEnv Naming Guidelines

## 📋 Project Name Standards

### Primary Name: DgtlEnv
- **Official Name:** DgtlEnv
- **Full Name:** DgtlEnv - Digital Environment Management
- **Source of Truth:** \`README.md\` (line 1)
- **Configuration:** \`config/project-config.json\`

### Usage Guidelines

#### ✅ Correct Usage
- "DgtlEnv" (primary name)
- "DgtlEnv - Digital Environment Management" (full name)
- "DgtlEnv project"
- "DgtlEnv system"

#### ❌ Incorrect Usage
- "DgtlEnv" (old name)
- "Digital Environment" (without DgtlEnv)
- "DgtlEnv" (inconsistent casing)

### File Naming Conventions

#### Scripts
- Use lowercase with hyphens: \`create-dgtlenv-backup.sh\`
- Avoid camelCase or snake_case for script names

#### Directories
- Use lowercase with hyphens: \`dgtlenv-config\`
- Keep existing directory structure

#### Configuration
- Use kebab-case: \`dgtlenv-settings.json\`
- Maintain consistency with existing patterns

### Implementation

#### Shell Scripts
\`\`\`bash
# Get project name from config
PROJECT_NAME=\$(jq -r '.project.name' config/project-config.json)
\`\`\`

#### Documentation
\`\`\`markdown
# **DgtlEnv** - Digital Environment Management
\`\`\`

### Validation

Run the naming validation script:
\`\`\`bash
./scripts/update-project-name.sh validate
\`\`\`

This will check for:
- Remaining "DgtlEnv" references
- Consistent "DgtlEnv" usage
- Proper casing and formatting

### Migration Notes

- All "DgtlEnv" references should be updated to "DgtlEnv"
- Script names should use lowercase with hyphens
- Configuration files should reference the centralized config
- README.md serves as the authoritative source of truth
EOF

    echo -e "${GREEN}✅ Created naming guidelines: $guidelines_file${NC}"
}

# Main execution
case "${1:-help}" in
    "update")
        update_all_files
        update_readme_header
        ;;
    "header")
        update_readme_header
        ;;
    "config")
        show_config
        ;;
    "validate")
        validate_naming
        ;;
    "guidelines")
        create_naming_guidelines
        ;;
    "full")
        update_all_files
        update_readme_header
        create_naming_guidelines
        validate_naming
        ;;
    "help"|*)
        echo "DgtlEnv Project Name Update Script"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  update     - Update all files to use DgtlEnv"
        echo "  header     - Update README header with source of truth"
        echo "  config     - Show current project configuration"
        echo "  validate   - Validate naming consistency"
        echo "  guidelines - Create naming guidelines document"
        echo "  full       - Run complete update process"
        echo "  help       - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 update"
        echo "  $0 validate"
        echo "  $0 full"
        ;;
esac
