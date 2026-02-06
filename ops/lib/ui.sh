#!/bin/bash
set -euo pipefail

# ##############################################################################
# DgtlEnv UI Library
#
# Provides user interface functions like help, list, search, and output.
# ##############################################################################

output_result() {
    local content="$1"
    local prompt_name="$2"

    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        echo "--- 📋 Dry Run: Final Prompt Output ---"
        echo "$content"
        echo "------------------------------------"
        echo "✨ Dry run complete. Nothing copied to clipboard."
        log "info" "Dry run completed for: $prompt_name"
    else
        echo "$content" | pbcopy
        echo "🚀 Prompt Router: Successfully prepared '$prompt_name'."
        echo "📋 The final prompt has been copied to your clipboard."
        log "info" "Prompt copied to clipboard: $prompt_name"
    fi
}

list_available_prompts() {
    echo "📋 Available Prompts:"
    find "$PROMPTS_DIR" -name "*.md" | grep -v README | sort | while read -r file; do
        basename=$(basename "$file" .md)
        echo "  • $basename"
    done
}

search_prompts() {
    local search_term="$1"
    echo "🔍 Searching for prompts containing: '$search_term'"
    find "$PROMPTS_DIR" -name "*.md" | grep -v README | grep -i "$search_term" | while read -r file; do
        basename=$(basename "$file" .md)
        echo "  • $basename"
    done
}

suggest_alternatives() {
    local alias="$1"
    local search_dir="$2"

    log "info" "Suggesting alternatives for: $alias"
    echo "💡 Try these alternatives:"

    find "$search_dir" -name "*.md" | grep -v README | while read -r file; do
        basename=$(basename "$file" .md)
        # Show files that contain any of the words in the alias
        for word in $alias; do
            word_lower=$(echo "$word" | tr '[:upper:]' '[:lower:]')
            if [[ "$basename" =~ $word_lower ]]; then
                echo "  • $basename"
                break
            fi
        done
    done
}

show_help() {
    local version="${1:-v2.0.0}" # Use passed version or a default
    echo "DgtlEnv Prompt Router $version"
    echo ""
    echo "Usage:"
    echo "  $0 [-d|--dry-run] <prompt-alias>"
    echo "  $0 --list"
    echo "  $0 --search <term>"
    echo "  $0 --chain <prompt1> <prompt2> [prompt3...]"
    echo "  $0 --help"
    echo ""
    echo "Options:"
    echo "  -d, --dry-run   Print the final prompt to terminal instead of copying"
    echo "  -v, --verbose   Enable verbose logging"
    echo "  --list          List all available prompts"
    echo "  --search <term> Search prompts by term"
    echo "  --chain <prompts> Execute multiple prompts in sequence"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 diagnose-ci"
    echo "  $0 --dry-run readme-shortening"
    echo "  $0 --search docker"
    echo "  $0 --chain diagnose-ci git-commit-push"
}
