#!/bin/bash

# ##############################################################################
# PromptRouter Migration Starter Script
#
# Automated script to begin the PromptRouter migration from DgtlEnv
# This script creates the initial project structure and extracts core components.
#
# Usage:
#   ./scripts/start-promptrouter-migration.sh
#   ./scripts/start-promptrouter-migration.sh --dry-run
# ##############################################################################

set -eo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
NEW_PROJECT_NAME="PromptRouter"
NEW_PROJECT_PATH="../$NEW_PROJECT_NAME"

# --- Global Variables ---
DRY_RUN=0
VERBOSE=0

# --- Logging Functions ---
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if [[ "$level" == "error" ]]; then
        echo "[$timestamp] [ERROR] $message" >&2
    elif [[ "$level" == "warn" ]]; then
        echo "[$timestamp] [WARN] $message" >&2
    elif [[ "$VERBOSE" -eq 1 ]] || [[ "$level" == "info" ]]; then
        echo "[$timestamp] [$level] $message"
    fi
}

# --- Argument Parsing ---
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=1
                log "info" "Dry-run mode enabled"
                shift
                ;;
            --verbose|-v)
                VERBOSE=1
                log "info" "Verbose mode enabled"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log "error" "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# --- Help Function ---
show_help() {
    echo "PromptRouter Migration Starter Script"
    echo ""
    echo "Usage:"
    echo "  $0 [options]"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be done without executing"
    echo "  --verbose, -v Enable verbose logging"
    echo "  --help, -h   Show this help message"
    echo ""
    echo "This script will:"
    echo "  1. Create the new PromptRouter project structure"
    echo "  2. Extract core components from DgtlEnv"
    echo "  3. Set up initial configuration"
    echo "  4. Create basic documentation"
}

# --- Validation Functions ---
validate_environment() {
    log "info" "Validating environment..."

    # Check if we're in the right directory
    if [[ ! -f "$PROJECT_ROOT/README.md" ]]; then
        log "error" "Must be run from DgtlEnv project root"
        exit 1
    fi

    # Check if new project already exists
    if [[ -d "$NEW_PROJECT_PATH" ]]; then
        log "warn" "Project $NEW_PROJECT_NAME already exists at $NEW_PROJECT_PATH"
        read -p "Do you want to continue and overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "info" "Migration cancelled"
            exit 0
        fi
    fi

    # Check dependencies
    local deps=("git" "jq" "find" "grep" "sed")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            log "error" "Required dependency not found: $dep"
            exit 1
        fi
    done

    log "info" "Environment validation passed"
}

# --- Project Creation Functions ---
create_project_structure() {
    log "info" "Creating project structure..."

    if [[ $DRY_RUN -eq 1 ]]; then
        echo "Would create directory structure:"
        echo "  $NEW_PROJECT_PATH/"
        echo "  ├── core/"
        echo "  ├── prompts/categories/"
        echo "  ├── scripts/"
        echo "  ├── config/"
        echo "  ├── docs/"
        echo "  ├── tests/"
        echo "  ├── examples/"
        echo "  ├── plugins/"
        echo "  ├── docker/"
        echo "  └── ci/"
        return 0
    fi

    # Create main project directory
    mkdir -p "$NEW_PROJECT_PATH"
    cd "$NEW_PROJECT_PATH"

    # Create directory structure
    mkdir -p {core,prompts/{categories,templates},scripts,config/{templates,examples},docs,tests/{unit,integration,performance},examples/{basic-setup,advanced-configuration,custom-plugins},plugins/{output-handlers,context-providers,validators},docker,ci/{.github,scripts}}

    log "info" "Project structure created successfully"
}

# --- Component Extraction Functions ---
extract_core_components() {
    log "info" "Extracting core components..."

    if [[ $DRY_RUN -eq 1 ]]; then
        echo "Would extract components:"
        echo "  - ops/run-prompt.sh → core/router.sh"
        echo "  - config/prompt-router-config.json → config/router-config.json"
        echo "  - prompts/categories/ → prompts/categories/"
        echo "  - scripts/validate-prompts.sh → scripts/validate.sh"
        echo "  - scripts/analyze-prompts.sh → scripts/analytics.sh"
        return 0
    fi

    # Extract core router
    cp "$PROJECT_ROOT/ops/run-prompt.sh" core/router.sh
    chmod +x core/router.sh

    # Extract configuration
    cp "$PROJECT_ROOT/config/prompt-router-config.json" config/router-config.json

    # Extract prompt categories
    cp -r "$PROJECT_ROOT/prompts/categories/"* prompts/categories/

    # Extract management scripts
    cp "$PROJECT_ROOT/scripts/validate-prompts.sh" scripts/validate.sh
    cp "$PROJECT_ROOT/scripts/analyze-prompts.sh" scripts/analytics.sh
    chmod +x scripts/validate.sh scripts/analytics.sh

    log "info" "Core components extracted successfully"
}

# --- Configuration Adaptation Functions ---
adapt_configuration() {
    log "info" "Adapting configuration for standalone project..."

    if [[ $DRY_RUN -eq 1 ]]; then
        echo "Would update configuration paths and settings"
        return 0
    fi

    # Update paths in router.sh
    sed -i 's|PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"|PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"|g' core/router.sh
    sed -i 's|PROMPTS_DIR="${PROJECT_ROOT}/prompts/categories"|PROMPTS_DIR="${PROJECT_ROOT}/prompts/categories"|g' core/router.sh
    sed -i 's|CONFIG_FILE="${PROJECT_ROOT}/config/prompt-router-config.json"|CONFIG_FILE="${PROJECT_ROOT}/config/router-config.json"|g' core/router.sh

    # Update configuration file
    sed -i 's|"prompts/categories"|"prompts/categories"|g' config/router-config.json
    sed -i 's|"logs/prompt-router.log"|"logs/router.log"|g' config/router-config.json

    log "info" "Configuration adapted successfully"
}

# --- Documentation Creation Functions ---
create_documentation() {
    log "info" "Creating initial documentation..."

    if [[ $DRY_RUN -eq 1 ]]; then
        echo "Would create documentation files"
        return 0
    fi

    # Create README
    cat > README.md << 'EOF'
# PromptRouter

> **Universal Prompt Management System for AI Development**

A sophisticated, language-agnostic prompt management system that works with any AI model or system, providing developers with enterprise-grade prompt routing, versioning, and analytics capabilities.

## 🚀 Quick Start

```bash
# Install PromptRouter
curl -sSL https://raw.githubusercontent.com/user/PromptRouter/main/scripts/install.sh | bash

# Use a prompt
prompt-router diagnose-ci
```

## ✨ Features

- **Modular Design** - Clean separation of concerns
- **Dry-Run Mode** - Safe testing without clipboard interference
- **Chain Processing** - Execute multiple prompts in sequence
- **Variable Substitution** - Dynamic content with `{{date}}`, `{{user}}`, etc.
- **Alias Resolution** - Configured shortcuts for common prompts
- **Plugin Architecture** - Extensible output handlers and context providers
- **Comprehensive Analytics** - Usage patterns and performance insights

## 📚 Documentation

- [API Documentation](docs/api.md)
- [Usage Examples](docs/examples.md)
- [Deployment Guide](docs/deployment.md)
- [Migration Guide](docs/migration.md)

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.
EOF

    # Create LICENSE
    cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 PromptRouter Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

    # Create CHANGELOG
    cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to PromptRouter will be documented in this file.

## [Unreleased]

### Added
- Initial project structure
- Core router functionality
- Configuration system
- Plugin architecture
- Comprehensive documentation

### Changed
- Extracted from DgtlEnv project
- Adapted for standalone deployment

### Removed
- DgtlEnv-specific dependencies
EOF

    # Create .gitignore
    cat > .gitignore << 'EOF'
# Logs
logs/
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# nyc test coverage
.nyc_output

# Dependency directories
node_modules/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOF

    log "info" "Documentation created successfully"
}

# --- Installation Script Creation ---
create_installation_script() {
    log "info" "Creating installation script..."

    if [[ $DRY_RUN -eq 1 ]]; then
        echo "Would create installation script"
        return 0
    fi

    cat > scripts/install.sh << 'EOF'
#!/bin/bash

# ##############################################################################
# PromptRouter Installation Script
#
# Installs PromptRouter system-wide for easy access
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/user/PromptRouter/main/scripts/install.sh | bash
#   ./scripts/install.sh
# ##############################################################################

set -eo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INSTALL_DIR="/usr/local/bin"
SYMLINK_NAME="prompt-router"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Logging Functions ---
log() {
    local level=$1
    shift
    local message="$*"

    case $level in
        "info")
            echo -e "${GREEN}[INFO]${NC} $message"
            ;;
        "warn")
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        "error")
            echo -e "${RED}[ERROR]${NC} $message" >&2
            ;;
    esac
}

# --- Validation Functions ---
validate_environment() {
    log "info" "Validating environment..."

    # Check if running as root (for system-wide install)
    if [[ $EUID -eq 0 ]]; then
        log "warn" "Running as root - system-wide installation"
    else
        log "info" "Running as user - local installation"
        INSTALL_DIR="$HOME/.local/bin"
        mkdir -p "$INSTALL_DIR"
    fi

    # Check dependencies
    local deps=("bash" "jq" "find" "grep" "sed")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            log "error" "Required dependency not found: $dep"
            exit 1
        fi
    done

    log "info" "Environment validation passed"
}

# --- Installation Functions ---
install_promptrouter() {
    log "info" "Installing PromptRouter..."

    # Create symlink
    local router_path="$PROJECT_ROOT/core/router.sh"
    local symlink_path="$INSTALL_DIR/$SYMLINK_NAME"

    if [[ -L "$symlink_path" ]]; then
        log "warn" "Removing existing symlink: $symlink_path"
        rm "$symlink_path"
    fi

    ln -sf "$router_path" "$symlink_path"
    chmod +x "$router_path"

    log "info" "PromptRouter installed successfully!"
    log "info" "Usage: $SYMLINK_NAME <prompt-alias>"

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        log "warn" "Please add $INSTALL_DIR to your PATH"
        log "warn" "Add this line to your shell profile:"
        echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    fi
}

# --- Main Function ---
main() {
    log "info" "PromptRouter Installation"
    log "info" "========================"

    validate_environment
    install_promptrouter

    log "info" "Installation completed successfully!"
}

# --- Script Execution ---
main "$@"
EOF

    chmod +x scripts/install.sh
    log "info" "Installation script created successfully"
}

# --- Git Initialization ---
initialize_git() {
    log "info" "Initializing git repository..."

    if [[ $DRY_RUN -eq 1 ]]; then
        echo "Would initialize git repository"
        return 0
    fi

    cd "$NEW_PROJECT_PATH"
    git init
    git add .
    git commit -m "Initial PromptRouter project structure

- Extracted core router from DgtlEnv
- Created modular component architecture
- Set up configuration system
- Added comprehensive documentation
- Created installation script"

    log "info" "Git repository initialized successfully"
}

# --- Summary Function ---
show_summary() {
    log "info" "Migration Summary"
    log "info" "================"

    if [[ $DRY_RUN -eq 1 ]]; then
        echo "Would create:"
        echo "  ✅ Project structure at $NEW_PROJECT_PATH"
        echo "  ✅ Core router components"
        echo "  ✅ Configuration system"
        echo "  ✅ Documentation suite"
        echo "  ✅ Installation script"
        echo "  ✅ Git repository"
    else
        echo "Created:"
        echo "  ✅ Project structure at $NEW_PROJECT_PATH"
        echo "  ✅ Core router components"
        echo "  ✅ Configuration system"
        echo "  ✅ Documentation suite"
        echo "  ✅ Installation script"
        echo "  ✅ Git repository"

        echo ""
        echo "Next steps:"
        echo "  1. cd $NEW_PROJECT_PATH"
        echo "  2. Review and test core functionality"
        echo "  3. Continue with Phase 2 of migration plan"
        echo "  4. Set up GitHub repository"
    fi
}

# --- Main Function ---
main() {
    log "info" "Starting PromptRouter migration..."
    log "info" "================================="

    # Parse arguments
    parse_arguments "$@"

    # Validate environment
    validate_environment

    # Create project structure
    create_project_structure

    # Extract core components
    extract_core_components

    # Adapt configuration
    adapt_configuration

    # Create documentation
    create_documentation

    # Create installation script
    create_installation_script

    # Initialize git
    initialize_git

    # Show summary
    show_summary

    log "info" "Migration starter completed successfully!"
}

# --- Script Execution ---
main "$@"
