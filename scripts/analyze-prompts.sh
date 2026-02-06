#!/bin/bash
set -euo pipefail

# ##############################################################################
# DgtlEnv Prompt Analytics v1.0.0
#
# Analyzes prompt usage patterns and provides insights for system optimization
#
# Usage:
#   ./scripts/analyze-prompts.sh
#   ./scripts/analyze-prompts.sh --usage
#   ./scripts/analyze-prompts.sh --popularity
# ##############################################################################

# --- Configuration ---
PROMPTS_DIR="prompts/categories"
ANALYTICS_DIR="metrics/prompt-analytics"
USAGE_LOG="logs/prompt-router.log"

# --- Analytics Functions ---
analyze_prompt_structure() {
    echo "📊 Prompt Structure Analysis"
    echo "=========================="

    local total_prompts=0
    local total_categories=0
    local category_counts=()

    # Count prompts by category
    for category in "$PROMPTS_DIR"/*/; do
        if [[ -d "$category" ]]; then
            local category_name=$(basename "$category")
            local prompt_count=$(find "$category" -name "*.md" | grep -v README | wc -l)
            category_counts+=("$category_name:$prompt_count")
            ((total_categories++))
            ((total_prompts += prompt_count))
        fi
    done

    echo "Total prompts: $total_prompts"
    echo "Total categories: $total_categories"
    echo ""
    echo "Prompts by category:"
    for count in "${category_counts[@]}"; do
        local category=$(echo "$count" | cut -d: -f1)
        local count_val=$(echo "$count" | cut -d: -f2)
        local percentage=$((count_val * 100 / total_prompts))
        printf "  %-25s %3d (%2d%%)\n" "$category" "$count_val" "$percentage"
    done
    echo ""
}

analyze_prompt_versions() {
    echo "📈 Version Analysis"
    echo "=================="

    local version_counts=()
    local latest_versions=0
    local outdated_versions=0

    while IFS= read -r -d '' file; do
        if [[ "$(basename "$file")" != "README.md" ]]; then
            local version=$(grep "^version:" "$file" | cut -d: -f2 | tr -d ' ')
            version_counts+=("$version")

            # Check if this is the latest version
            local basename=$(basename "$file" .md)
            local base_name=$(echo "$basename" | sed 's/-v[0-9]\+\.[0-9]\+\.[0-9]\+$//')
            local latest_file=$(find "$PROMPTS_DIR" -name "${base_name}-*.md" | sort -V | tail -n 1)

            if [[ "$file" == "$latest_file" ]]; then
                ((latest_versions++))
            else
                ((outdated_versions++))
            fi
        fi
    done < <(find "$PROMPTS_DIR" -name "*.md" -print0)

    echo "Latest versions: $latest_versions"
    echo "Outdated versions: $outdated_versions"
    echo ""

    # Version distribution
    echo "Version distribution:"
    printf "%s\n" "${version_counts[@]}" | sort | uniq -c | sort -nr | while read -r count version; do
        printf "  v%-8s %3d prompts\n" "$version" "$count"
    done
    echo ""
}

analyze_prompt_complexity() {
    echo "🔍 Complexity Analysis"
    echo "===================="

    local total_lines=0
    local total_files=0
    local complexity_data=()

    while IFS= read -r -d '' file; do
        if [[ "$(basename "$file")" != "README.md" ]]; then
            local lines=$(wc -l < "$file")
            local filename=$(basename "$file")
            complexity_data+=("$filename:$lines")
            ((total_lines += lines))
            ((total_files++))
        fi
    done < <(find "$PROMPTS_DIR" -name "*.md" -print0)

    local avg_lines=$((total_lines / total_files))

    echo "Average lines per prompt: $avg_lines"
    echo "Total lines: $total_lines"
    echo "Total files: $total_files"
    echo ""

    echo "Most complex prompts (by line count):"
    printf "%s\n" "${complexity_data[@]}" | sort -t: -k2 -nr | head -5 | while IFS=: read -r filename lines; do
        printf "  %-35s %3d lines\n" "$filename" "$lines"
    done
    echo ""

    echo "Simplest prompts (by line count):"
    printf "%s\n" "${complexity_data[@]}" | sort -t: -k2 -n | head -5 | while IFS=: read -r filename lines; do
        printf "  %-35s %3d lines\n" "$filename" "$lines"
    done
    echo ""
}

analyze_usage_patterns() {
    if [[ ! -f "$USAGE_LOG" ]]; then
        echo "⚠️  No usage log found at $USAGE_LOG"
        echo "   Usage analytics require the enhanced router with logging enabled"
        return
    fi

    echo "📊 Usage Pattern Analysis"
    echo "========================"

    local total_usage=0
    local usage_by_prompt=()

    # Extract prompt usage from log
    while IFS= read -r line; do
        if [[ "$line" =~ Processing\ prompt:\ ([^[:space:]]+) ]]; then
            local prompt="${BASH_REMATCH[1]}"
            usage_by_prompt+=("$prompt")
            ((total_usage++))
        fi
    done < "$USAGE_LOG"

    echo "Total prompt executions: $total_usage"
    echo ""

    if [[ $total_usage -gt 0 ]]; then
        echo "Most used prompts:"
        printf "%s\n" "${usage_by_prompt[@]}" | sort | uniq -c | sort -nr | head -10 | while read -r count prompt; do
            local percentage=$((count * 100 / total_usage))
            printf "  %-25s %3d times (%2d%%)\n" "$prompt" "$count" "$percentage"
        done
        echo ""
    fi
}

generate_analytics_report() {
    local report_file="$ANALYTICS_DIR/prompt-analytics-$(date +%Y%m%d).md"

    mkdir -p "$ANALYTICS_DIR"

    {
        echo "# DgtlEnv Prompt Analytics Report"
        echo "Generated: $(date)"
        echo ""
        echo "## Executive Summary"
        echo ""
        echo "This report provides insights into the DgtlEnv prompt management system."
        echo ""
        echo "## Detailed Analysis"
        echo ""

        # Capture structure analysis
        echo "### Prompt Structure"
        echo '```'
        analyze_prompt_structure
        echo '```'
        echo ""

        # Capture version analysis
        echo "### Version Analysis"
        echo '```'
        analyze_prompt_versions
        echo '```'
        echo ""

        # Capture complexity analysis
        echo "### Complexity Analysis"
        echo '```'
        analyze_prompt_complexity
        echo '```'
        echo ""

        # Capture usage analysis
        echo "### Usage Patterns"
        echo '```'
        analyze_usage_patterns
        echo '```'
        echo ""

        echo "## Recommendations"
        echo ""
        echo "Based on this analysis:"
        echo ""
        echo "1. **Version Management**: Consider cleaning up outdated prompt versions"
        echo "2. **Category Balance**: Ensure even distribution across categories"
        echo "3. **Complexity**: Review overly complex prompts for simplification"
        echo "4. **Usage Patterns**: Focus development on most-used prompt categories"
        echo ""

    } > "$report_file"

    echo "📄 Analytics report generated: $report_file"
}

# --- Main Function ---
main() {
    case "${1:-}" in
        "--usage")
            analyze_usage_patterns
            ;;
        "--popularity")
            analyze_prompt_structure
            analyze_usage_patterns
            ;;
        "--report")
            generate_analytics_report
            ;;
        "--help"|"-h")
            echo "DgtlEnv Prompt Analytics v1.0.0"
            echo ""
            echo "Usage:"
            echo "  $0              # Full analytics report"
            echo "  $0 --usage      # Usage pattern analysis only"
            echo "  $0 --popularity # Popularity and usage analysis"
            echo "  $0 --report     # Generate markdown report"
            echo "  $0 --help       # Show this help"
            exit 0
            ;;
        *)
            echo "🔍 DgtlEnv Prompt Analytics"
            echo "=========================="
            echo ""

            analyze_prompt_structure
            analyze_prompt_versions
            analyze_prompt_complexity
            analyze_usage_patterns

            echo "💡 Use '$0 --report' to generate a detailed markdown report"
            ;;
    esac
}

# --- Script Execution ---
main "$@"
