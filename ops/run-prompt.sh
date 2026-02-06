#!/bin/bash

# ##############################################################################
# DgtlEnv Prompt Router v2.1.0 (Modular)
#
# Orchestrates prompt routing by sourcing modular libraries for core logic,
# UI, and logging. Follows DgtlEnv standards for maintainability.
#
# Usage:
#   ./ops/run-prompt.sh [-d|--dry-run] <prompt-alias>
#   ./ops/run-prompt.sh --list
#   ./ops/run-prompt.sh --search <term>
#
# Options:
#   -d, --dry-run   Print the final prompt to terminal instead of copying
#   --list          List all available prompts
#   --search <term> Search prompts by term
#
# Example:
#   ./ops/run-prompt.sh diagnose-ci
#   ./ops/run-prompt.sh --dry-run readme-shortening
# ##############################################################################

set -eo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROMPTS_DIR="${PROJECT_ROOT}/prompts/categories"
LIB_DIR="${SCRIPT_DIR}/lib" # New directory for libraries
UTILS_DIR="${PROJECT_ROOT}/ops/utils"
LOG_FILE="${PROJECT_ROOT}/logs/prompt-router.log"
CONFIG_FILE="${PROJECT_ROOT}/config/prompt-router-config.json"

# --- Global Variables ---
DRY_RUN=0
VERBOSE=0
SCRIPT_VERSION="v2.1.0 (Modular)"
PROMPT_ALIAS=""

# --- Source Libraries ---
# shellcheck source=ops/lib/logging.sh
source "${LIB_DIR}/logging.sh"

# shellcheck source=ops/lib/core.sh
source "${LIB_DIR}/core.sh"

# shellcheck source=ops/lib/ui.sh
source "${LIB_DIR}/ui.sh"

# --- Utility Functions ---
check_dependencies() {
    local missing_deps=0
    # pbcopy is essential for the primary output method on macOS
    local required_commands=("pbcopy")

    # jq is only required if a configuration file is being used
    if [[ -f "$CONFIG_FILE" ]]; then
        required_commands+=("jq")
    fi

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log "error" "Required command not found: '$cmd'. Please install it and ensure it's in your PATH."
            missing_deps=1
        fi
    done

    if [[ $missing_deps -eq 1 ]]; then
        exit 1
    fi
}

# --- Argument Parsing Functions ---
parse_arguments() {
    local args=("$@")

    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dry-run)
                DRY_RUN=1
                log "info" "Dry-run mode enabled"
                shift
                ;;
            -v|--verbose)
                VERBOSE=1
                log "info" "Verbose mode enabled"
                shift
                ;;
            --list)
                list_available_prompts
                exit 0
                ;;
            --search)
                if [[ -z "$2" ]]; then
                    log "error" "No search term provided for --search"
                    exit 1
                fi
                search_prompts "$2"
                exit 0
                ;;
            --chain)
                shift
                if [[ $# -lt 2 ]]; then
                    log "error" "Chain mode requires at least 2 prompts"
                    exit 1
                fi
                local chain_result
                chain_result=$(process_chain "$@")
                if [[ $? -eq 0 ]]; then
                    output_result "$chain_result" "chain-result"
                    log "info" "Chain processing completed successfully"
                else
                    log "error" "Chain processing failed"
                    exit 1
                fi
                exit 0
                ;;
            --help|-h)
                show_help "$SCRIPT_VERSION"
                exit 0
                ;;
            -*)
                log "error" "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                PROMPT_ALIAS="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$PROMPT_ALIAS" ]]; then
        log "error" "No prompt alias provided"
        show_help "$SCRIPT_VERSION"
        exit 1
    fi
}

# --- Main Processing Function ---
process_prompt() {
    local alias="$1"
    local mode="${2:-single}"

    log "info" "Processing prompt: $alias (mode: $mode)"

    # Validate input
    if ! validate_input "$alias"; then
        return 1
    fi

    # Find the latest prompt file
    local latest_prompt_file
    latest_prompt_file=$(find_latest_prompt "$alias" "$PROMPTS_DIR")
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    # Read the prompt content
    local prompt_body
    prompt_body=$(cat "$latest_prompt_file")

    # Inject context
    local final_prompt
    final_prompt=$(inject_context "$prompt_body")

    # Output the result based on mode
    if [[ "$mode" == "single" ]]; then
        local prompt_name
        prompt_name=$(basename "$latest_prompt_file" .md)
        output_result "$final_prompt" "$prompt_name"
    else
        echo "$final_prompt"
    fi

    # Log usage
    log_prompt_usage "$alias" "$latest_prompt_file" "0"

    return 0
}

# --- Chain Processing Function ---
process_chain() {
    local prompts=("$@")
    local chain_result=""

    log "info" "Processing prompt chain: ${prompts[*]}"

    for prompt in "${prompts[@]}"; do
        log "info" "Processing chain prompt: $prompt"
        local result
        result=$(process_prompt "$prompt" "chain")
        if [[ $? -eq 0 ]]; then
            chain_result="${chain_result}${result}\n\n---\n\n"
        else
            log "error" "Failed to process prompt in chain: $prompt"
            return 1
        fi
    done

    echo "$chain_result"
}

# --- Main Function ---
main() {
    # Fail early if required tools are missing
    check_dependencies

    # Parse arguments
    parse_arguments "$@"

    # Process the prompt
    if process_prompt "$PROMPT_ALIAS"; then
        log "info" "Prompt processing completed successfully"
    else
        log "error" "Prompt processing failed"
        exit 1
    fi
}

# --- Script Execution ---
main "$@"
