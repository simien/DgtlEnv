#!/bin/bash
set -euo pipefail

# Centralized configuration variables for DgtlEnv

# Handle zsh/bash source detection
if [ -n "${BASH_SOURCE[0]:-}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "${ZSH_VERSION}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
CONFIG_FILE="${SCRIPT_DIR}/project-config.json"

if [[ -f "$CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
    export CONTACT_NAME=$(jq -r '.project.author' "$CONFIG_FILE")
    export CONTACT_EMAIL=$(jq -r '.project.email' "$CONFIG_FILE")
    export CONTACT_WEBSITE=$(jq -r '.project.website' "$CONFIG_FILE")
    export CONTACT_GITHUB=$(jq -r '.project.githubUser' "$CONFIG_FILE")

    # Export Path Variables
    export PATH_ROOT=$(jq -r '.paths.root' "$CONFIG_FILE")
    export PATH_DOCS=$(jq -r '.paths.docs' "$CONFIG_FILE")
    export PATH_OPS=$(jq -r '.paths.ops' "$CONFIG_FILE")
    export PATH_SCRIPTS=$(jq -r '.paths.scripts' "$CONFIG_FILE")
    export PATH_METRICS=$(jq -r '.paths.metrics' "$CONFIG_FILE")
    export PATH_SECURITY=$(jq -r '.paths.security' "$CONFIG_FILE")
    export PATH_CONFIG=$(jq -r '.paths.config' "$CONFIG_FILE")
    export PATH_TESTS=$(jq -r '.paths.tests' "$CONFIG_FILE")
    export PATH_EXAMPLES=$(jq -r '.paths.examples' "$CONFIG_FILE")
    export PATH_TODOS=$(jq -r '.paths.todos' "$CONFIG_FILE")
    export PATH_LOGS=$(jq -r '.paths.logs' "$CONFIG_FILE")

    # Export System Variables
    export PROJECT_VERSION=$(jq -r '.project.version' "$CONFIG_FILE")
    export TARGET_OS=$(jq -r '.system.targetOS' "$CONFIG_FILE")
else
    # Fallback
    export CONTACT_NAME="DgtlEnv Maintainer"
    export CONTACT_EMAIL="maintainer@example.com"
    export CONTACT_WEBSITE="https://example.com/"
    export CONTACT_GITHUB="dgtlenv-maintainer"

    export PATH_ROOT="./"
    export PATH_DOCS="./docs/"
    export PATH_OPS="./ops/"
    export PATH_SCRIPTS="./scripts/"
    export PATH_METRICS="./metrics/"
    export PATH_SECURITY="./security/"
    export PATH_CONFIG="./config/"
    export PATH_TESTS="./tests/"
    export PATH_EXAMPLES="./examples/"
    export PATH_TODOS="./todos/"
    export PATH_LOGS="./logs/"

    export PROJECT_VERSION="1.0.0"
    export TARGET_OS="macOS 12.7.6 Monterey"
fi
