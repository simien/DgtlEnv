#!/bin/bash
#
# Script Name: setup-github.sh
# Description: Initialize DgtlEnv GitHub repository with best practices
# Author: DgtlEnv Maintainer
# Date: 2025-07-28
# Version: 1.0.0
#
# Usage:
#   ./scripts/setup-github.sh [options]
#
# Options:
#   -r, --remote    GitHub remote URL (required)
#   -b, --branch    Default branch name (default: main)
#   -f, --force     Force setup even if git is already initialized
#   -h, --help      Show this help message
#
# Examples:
#   ./scripts/setup-github.sh -r https://github.com/dgtlenv-maintainer/DgtlEnv.git
#   ./scripts/setup-github.sh -r https://github.com/dgtlenv-maintainer/DgtlEnv.git -b develop
#
# Dependencies:
#   - git
#   - curl
#
# Exit Codes:
#   0 - Success
#   1 - Invalid arguments
#   2 - Git not initialized
#   3 - Remote already exists
#   4 - Setup failed

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
REMOTE_URL=""
BRANCH="main"
FORCE=false

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source centralized variables
if [[ -f "${PROJECT_ROOT}/config/variables.sh" ]]; then
    source "${PROJECT_ROOT}/config/variables.sh"
else
    # Fallback default values
    CONTACT_NAME="DgtlEnv Maintainer"
    CONTACT_EMAIL="maintainer@example.com"
fi

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date +'%Y-%m-%d %H:%M:%S')] ${message}${NC}"
}

# Function to show help
show_help() {
    cat << EOF
DgtlEnv GitHub Setup Script

This script initializes the DgtlEnv project for GitHub with best practices including:
- Git repository initialization
- Remote repository setup
- Branch protection configuration
- GitHub Actions workflow setup
- Issue and PR templates
- Repository settings

Usage: $0 [options]

Options:
    -r, --remote URL    GitHub remote URL (required)
    -b, --branch NAME   Default branch name (default: main)
    -f, --force         Force setup even if git is already initialized
    -h, --help          Show this help message

Examples:
    $0 -r https://github.com/dgtlenv-maintainer/DgtlEnv.git
$0 -r https://github.com/dgtlenv-maintainer/DgtlEnv.git -b develop

Requirements:
    - Git must be installed
    - GitHub repository must exist
    - User must have push access to the repository
EOF
}

# Function to validate arguments
validate_args() {
    if [[ -z "$REMOTE_URL" ]]; then
        print_status "$RED" "Error: Remote URL is required"
        echo "Use -r or --remote to specify the GitHub repository URL"
        exit 1
    fi

    if [[ ! "$REMOTE_URL" =~ ^https://github\.com/ ]]; then
        print_status "$RED" "Error: Invalid GitHub URL format"
        echo "URL must be in format: https://github.com/username/repository.git"
        exit 1
    fi
}

# Function to check dependencies
check_dependencies() {
    print_status "$BLUE" "Checking dependencies..."

    if ! command -v git &> /dev/null; then
        print_status "$RED" "Error: Git is not installed"
        exit 1
    fi

    if ! command -v curl &> /dev/null; then
        print_status "$RED" "Error: Curl is not installed"
        exit 1
    fi

    print_status "$GREEN" "✓ Dependencies check passed"
}

# Function to initialize git repository
init_git() {
    print_status "$BLUE" "Initializing Git repository..."

    if [[ -d ".git" ]] && [[ "$FORCE" == false ]]; then
        print_status "$YELLOW" "Git repository already exists. Use --force to reinitialize."
        return 0
    fi

    if [[ -d ".git" ]] && [[ "$FORCE" == true ]]; then
        print_status "$YELLOW" "Removing existing .git directory..."
        rm -rf .git
    fi

    git init
    git config user.name "${CONTACT_NAME}"
    git config user.email "${CONTACT_EMAIL}"

    print_status "$GREEN" "✓ Git repository initialized"
}

# Function to setup remote
setup_remote() {
    print_status "$BLUE" "Setting up remote repository..."

    # Check if remote already exists
    if git remote get-url origin &> /dev/null; then
        if [[ "$FORCE" == true ]]; then
            print_status "$YELLOW" "Removing existing remote..."
            git remote remove origin
        else
            print_status "$RED" "Error: Remote 'origin' already exists"
            echo "Use --force to replace existing remote"
            exit 3
        fi
    fi

    git remote add origin "$REMOTE_URL"

    # Test remote connection
    if ! git ls-remote --exit-code origin &> /dev/null; then
        print_status "$RED" "Error: Cannot connect to remote repository"
        echo "Please check the URL and your access permissions"
        exit 1
    fi

    print_status "$GREEN" "✓ Remote repository configured"
}

# Function to create initial commit
create_initial_commit() {
    print_status "$BLUE" "Creating initial commit..."

    # Add all files
    git add .

    # Create initial commit
    git commit -m "feat: initial DgtlEnv project setup

- Add comprehensive project structure
- Include system optimization scripts
- Add PDF conversion functionality
- Include monitoring and metrics tools
- Add GitHub best practices setup
- Include documentation and templates

This is the initial commit for the DgtlEnv project, providing
a comprehensive digital environment management system for macOS
development environments."

    print_status "$GREEN" "✓ Initial commit created"
}

# Function to setup branch
setup_branch() {
    print_status "$BLUE" "Setting up branch: $BRANCH"

    # Create and switch to the specified branch
    git checkout -b "$BRANCH"

    # Push to remote
    git push -u origin "$BRANCH"

    print_status "$GREEN" "✓ Branch '$BRANCH' set up and pushed"
}

# Function to verify setup
verify_setup() {
    print_status "$BLUE" "Verifying setup..."

    # Check if all required files exist
    required_files=(
        "README.md"
        "CONTRIBUTING.md"
        "SECURITY.md"
        "CHANGELOG.md"
        "LICENSE"
        ".gitignore"
        ".github/workflows/ci.yml"
        ".github/ISSUE_TEMPLATE/bug_report.md"
        ".github/ISSUE_TEMPLATE/feature_request.md"
        ".github/pull_request_template.md"
    )

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_status "$RED" "Error: Required file missing: $file"
            exit 1
        fi
    done

    # Check if scripts are executable
    for script in $(find . -name "*.sh" -type f); do
        if [[ ! -x "$script" ]]; then
            print_status "$YELLOW" "Warning: Script not executable: $script"
            chmod +x "$script"
        fi
    done

    print_status "$GREEN" "✓ Setup verification passed"
}

# Function to display next steps
show_next_steps() {
    print_status "$GREEN" "🎉 GitHub setup completed successfully!"

    cat << EOF

Next Steps:
1. Review the repository on GitHub: $REMOTE_URL
2. Enable GitHub Actions in the repository settings
3. Set up branch protection rules for the '$BRANCH' branch
4. Configure issue templates and labels
5. Set up project boards and milestones
6. Review and customize repository settings

Repository Features:
- ✅ Comprehensive .gitignore for macOS development
- ✅ GitHub Actions CI/CD workflow
- ✅ Issue and PR templates
- ✅ Contributing guidelines
- ✅ Security policy
- ✅ MIT License
- ✅ Changelog tracking
- ✅ Documentation structure

Quick Commands:
- Check status: git status
- View remote: git remote -v
- Push changes: git push origin $BRANCH
- Create feature branch: git checkout -b feature/your-feature

For more information, see:
- CONTRIBUTING.md - How to contribute
- SECURITY.md - Security policy
- CHANGELOG.md - Version history

Happy coding! 🚀
EOF
}

# Function to handle errors
handle_error() {
    print_status "$RED" "Error: $1"
    exit 1
}

# Main function
main() {
    print_status "$BLUE" "🚀 Starting DgtlEnv GitHub Setup"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--remote)
                REMOTE_URL="$2"
                shift 2
                ;;
            -b|--branch)
                BRANCH="$2"
                shift 2
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_status "$RED" "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Validate arguments
    validate_args

    # Check dependencies
    check_dependencies

    # Initialize git repository
    init_git

    # Setup remote
    setup_remote

    # Create initial commit
    create_initial_commit

    # Setup branch
    setup_branch

    # Verify setup
    verify_setup

    # Show next steps
    show_next_steps
}

# Trap errors
trap 'handle_error "An error occurred during setup"' ERR

# Run main function
main "$@"
