#!/bin/bash
set -euo pipefail

# ##############################################################################
# DgtlEnv Logging Library
#
# Provides standardized logging functions for DgtlEnv scripts.
# Depends on LOG_FILE and VERBOSE variables being set in the calling script.
# ##############################################################################

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")"

    # Write to log file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"

    # Output to stderr for errors and warnings, or if verbose is enabled
    if [[ "$level" == "error" ]] || [[ "$level" == "warn" ]] || [[ "${VERBOSE:-0}" -eq 1 ]]; then
        echo "$message" >&2
    fi
}
