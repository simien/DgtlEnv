#!/bin/bash
set -euo pipefail

# ##############################################################################
# DgtlEnv Prompt Validator v1.0.0
#
# Validates all prompts in the system to ensure they follow the template format
# and meet quality standards.
#
# Usage:
#   ./scripts/validate-prompts.sh
#   ./scripts/validate-prompts.sh --fix
# ##############################################################################

# --- Configuration ---
PROMPTS_DIR="prompts/categories"
TEMPLATE_FILE="prompts/prompt-format-template-v1.0.0.md"
VALIDATION_LOG="logs/prompt-validation.log"

# --- Validation Functions ---
validate_metadata() {
    local file="$1"
    local errors=()

    # Check for required metadata fields
    local required_fields=("id" "name" "version" "purpose" "category" "model_compatibility")

    for field in "${required_fields[@]}"; do
        if ! grep -q "^${field}:" "$file"; then
            errors+=("Missing required field: $field")
        fi
    done

    # Check for valid version format
    if grep -q "^version:" "$file"; then
        local version=$(grep "^version:" "$file" | cut -d: -f2 | tr -d ' ')
        if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            errors+=("Invalid version format: $version (should be x.y.z)")
        fi
    fi

    echo "${errors[@]}"
}

validate_structure() {
    local file="$1"
    local errors=()

    # Check for required sections
    local required_sections=("System Message / Role" "Context Engineering" "Instructions" "Expected Outputs")

    for section in "${required_sections[@]}"; do
        if ! grep -q "^## $section" "$file"; then
            errors+=("Missing required section: $section")
        fi
    done

    # Check for proper markdown formatting
    if grep -q "^## [^#]" "$file"; then
        # Check for proper heading hierarchy
        local heading_count=$(grep -c "^## " "$file")
        if [[ $heading_count -lt 4 ]]; then
            errors+=("Insufficient section structure (found $heading_count sections)")
        fi
    else
        errors+=("Missing proper markdown section headers")
    fi

    echo "${errors[@]}"
}

validate_content() {
    local file="$1"
    local errors=()

    # Check for placeholder text
    if grep -q "SPECIFIC_TASK_DESCRIPTION\|DETAILED_INSTRUCTIONS\|FIELD_1\|FIELD_2" "$file"; then
        errors+=("Contains template placeholder text")
    fi

    # Check for reasonable content length
    local line_count=$(wc -l < "$file")
    if [[ $line_count -lt 20 ]]; then
        errors+=("Content too short ($line_count lines)")
    fi

    # Check for ASCII style compliance
    if grep -q "\`\`\`.*\`\`\`" "$file"; then
        # Check for proper code block formatting
        local code_blocks=$(grep -c "^\`\`\`" "$file")
        if [[ $((code_blocks % 2)) -ne 0 ]]; then
            errors+=("Unmatched code blocks")
        fi
    fi

    echo "${errors[@]}"
}

validate_filename() {
    local file="$1"
    local filename=$(basename "$file")
    local errors=()

    # Check kebab-case naming
    if [[ ! "$filename" =~ ^[a-z0-9-]+-v[0-9]+\.[0-9]+\.[0-9]+\.md$ ]]; then
        errors+=("Invalid filename format (should be kebab-case-vx.y.z.md)")
    fi

    # Check for version consistency
    local filename_version=$(echo "$filename" | sed -n 's/.*-v\([0-9]\+\.[0-9]\+\.[0-9]\+\)\.md/\1/p')
    local content_version=$(grep "^version:" "$file" | cut -d: -f2 | tr -d ' ')

    if [[ -n "$filename_version" && -n "$content_version" && "$filename_version" != "$content_version" ]]; then
        errors+=("Version mismatch: filename=$filename_version, content=$content_version")
    fi

    echo "${errors[@]}"
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

# Function to check for outdated versions
check_outdated_versions() {
    local file="$1"
    local filename=$(basename "$file")
    local warnings=()

    # Extract base name and version
    local base_name=$(echo "$filename" | sed 's/-v[0-9]\+\.[0-9]\+\.[0-9]\+\.md$//')
    local current_version=$(echo "$filename" | sed -n 's/.*-v\([0-9]\+\.[0-9]\+\.[0-9]\+\)\.md/\1/p')

    # Find all versions of this prompt
    local all_versions=($(find "$PROMPTS_DIR" -name "${base_name}-v*.md" -type f))

    if [[ ${#all_versions[@]} -gt 1 ]]; then
        local latest_version="$current_version"

        # Find the latest version
        for version_file in "${all_versions[@]}"; do
            local version_filename=$(basename "$version_file")
            local version=$(echo "$version_filename" | sed -n 's/.*-v\([0-9]\+\.[0-9]\+\.[0-9]\+\)\.md/\1/p')

            if [[ "$(compare_versions "$version" "$latest_version")" == "greater" ]]; then
                latest_version="$version"
            fi
        done

        # Check if current file is outdated
        if [[ "$current_version" != "$latest_version" ]]; then
            warnings+=("Outdated version: current=v$current_version, latest=v$latest_version")
        fi
    fi

    echo "${warnings[@]}"
}

# --- Main Validation Function ---
validate_prompt() {
    local file="$1"
    local filename=$(basename "$file")
    local errors=()
    local warnings=()

    echo "🔍 Validating: $filename"

    # Run all validation checks
    local metadata_errors=($(validate_metadata "$file"))
    local structure_errors=($(validate_structure "$file"))
    local content_errors=($(validate_content "$file"))
    local filename_errors=($(validate_filename "$file"))
    local outdated_warnings=($(check_outdated_versions "$file"))

    # Collect all errors
    errors+=("${metadata_errors[@]}")
    errors+=("${structure_errors[@]}")
    errors+=("${content_errors[@]}")
    errors+=("${filename_errors[@]}")

    # Collect warnings
    warnings+=("${outdated_warnings[@]}")

    # Report results
    if [[ ${#errors[@]} -eq 0 ]]; then
        echo "✅ $filename: PASSED"
        # Show warnings if any
        if [[ ${#warnings[@]} -gt 0 ]]; then
            for warning in "${warnings[@]}"; do
                echo "   ⚠️  $warning"
            done
        fi
        return 0
    else
        echo "❌ $filename: FAILED"
        for error in "${errors[@]}"; do
            echo "   - $error"
        done
        # Show warnings even for failed files
        if [[ ${#warnings[@]} -gt 0 ]]; then
            for warning in "${warnings[@]}"; do
                echo "   ⚠️  $warning"
            done
        fi
        return 1
    fi
}

# --- Auto-fix Function ---
auto_fix_prompt() {
    local file="$1"
    local filename=$(basename "$file")

    echo "🔧 Attempting to fix: $filename"

    # Create backup
    cp "$file" "${file}.backup"

    # Fix common issues
    # 1. Add missing metadata if file is completely empty
    if [[ ! -s "$file" ]]; then
        echo "Creating new prompt from template..."
        cp "$TEMPLATE_FILE" "$file"
        # Update the id field
        local new_id=$(echo "$filename" | sed 's/\.md$//')
        sed -i '' "s/id: prompt-format-template-v1.0.0/id: $new_id/" "$file"
        sed -i '' "s/name: DgtlEnv Prompt Format Template/name: $(echo $new_id | sed 's/-/ /g' | sed 's/\b\w/\U&/g')/" "$file"
    fi

    # 2. Fix version inconsistencies
    local filename_version=$(echo "$filename" | sed -n 's/.*-v\([0-9]\+\.[0-9]\+\.[0-9]\+\)\.md/\1/p')
    if [[ -n "$filename_version" ]]; then
        sed -i '' "s/^version:.*/version: $filename_version/" "$file"
    fi

    echo "✅ Auto-fix completed for $filename"
}

# --- Main Function ---
main() {
    local fix_mode=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --fix)
                fix_mode=true
                shift
                ;;
            --help|-h)
                echo "DgtlEnv Prompt Validator v1.0.0"
                echo ""
                echo "Usage:"
                echo "  $0              # Validate all prompts"
                echo "  $0 --fix        # Validate and auto-fix issues"
                echo "  $0 --help       # Show this help"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Create log directory
    mkdir -p "$(dirname "$VALIDATION_LOG")"

    echo "🔍 Starting prompt validation..."
    echo "📁 Scanning directory: $PROMPTS_DIR"
    echo ""

    local total_prompts=0
    local passed_prompts=0
    local failed_prompts=0

    # Find all prompt files
    while IFS= read -r -d '' file; do
        if [[ "$(basename "$file")" != "README.md" ]]; then
            ((total_prompts++))

            if validate_prompt "$file"; then
                ((passed_prompts++))
            else
                ((failed_prompts++))

                if [[ "$fix_mode" == "true" ]]; then
                    auto_fix_prompt "$file"
                fi
            fi
            echo ""
        fi
    done < <(find "$PROMPTS_DIR" -name "*.md" -print0)

    # Summary
    echo "📊 Validation Summary:"
    echo "   Total prompts: $total_prompts"
    echo "   Passed: $passed_prompts"
    echo "   Failed: $failed_prompts"
    echo "   Success rate: $((passed_prompts * 100 / total_prompts))%"

    if [[ $failed_prompts -gt 0 ]]; then
        echo ""
        echo "💡 Use '$0 --fix' to automatically fix common issues"
        exit 1
    else
        echo ""
        echo "🎉 All prompts passed validation!"
        exit 0
    fi
}

# --- Script Execution ---
main "$@"
