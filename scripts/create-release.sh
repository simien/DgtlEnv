#!/bin/bash
# DgtlEnv Release Management Script
# Automates the release process for GitHub

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[RELEASE]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to validate version format
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format. Use semantic versioning (e.g., 1.0.0)"
        exit 1
    fi
}

# Function to check if version already exists
check_version_exists() {
    local version=$1
    if git tag | grep -q "^v$version$"; then
        print_error "Version v$version already exists"
        exit 1
    fi
}

# Function to update changelog
update_changelog() {
    local version=$1
    local date=$(date +%Y-%m-%d)

    print_status "Updating CHANGELOG.md..."

    # Create temporary file
    cat > temp_changelog.md << EOF
# Changelog

All notable changes to DgtlEnv will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

EOF

    # Add the rest of the changelog
    tail -n +8 CHANGELOG.md >> temp_changelog.md

    # Move temporary file to replace original
    mv temp_changelog.md CHANGELOG.md

    print_success "CHANGELOG.md updated"
}

# Function to run pre-release checks
run_pre_release_checks() {
    print_status "Running pre-release checks..."

    # Check if working directory is clean
    if [[ -n $(git status --porcelain) ]]; then
        print_error "Working directory is not clean. Please commit or stash changes."
        exit 1
    fi

    # Run security sanitizer
    if [[ -f "scripts/pre-release-sanitizer.sh" ]]; then
        print_status "Running security sanitizer..."
        ./scripts/pre-release-sanitizer.sh --dry-run
    fi

    # Check for required files
    required_files=("README.md" "CHANGELOG.md" "LICENSE" "CONTRIBUTING.md" "SECURITY.md")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file missing: $file"
            exit 1
        fi
    done

    print_success "Pre-release checks passed"
}

# Function to create release
create_release() {
    local version=$1
    local message=${2:-"Release v$version"}

    print_status "Creating release v$version..."

    # Update changelog
    update_changelog "$version"

    # Commit changelog changes
    git add CHANGELOG.md
    git commit -m "Update changelog for v$version"

    # Create and push tag
    git tag -a "v$version" -m "$message"
    git push origin "v$version"

    print_success "Release v$version created and pushed"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <version> [message]"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0"
    echo "  $0 1.1.0 'Add new optimization features'"
    echo ""
    echo "This script will:"
    echo "  1. Validate the version format"
    echo "  2. Check if version already exists"
    echo "  3. Run pre-release security checks"
    echo "  4. Update CHANGELOG.md"
    echo "  5. Create and push the release tag"
    echo ""
    echo "The GitHub Actions workflow will automatically:"
    echo "  - Create a GitHub release"
    echo "  - Generate release assets (zip file)"
    echo "  - Upload changelog"
}

# Main script logic
main() {
    # Check if version is provided
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi

    local version=$1
    local message=${2:-"Release v$version"}

    print_status "Starting release process for v$version..."

    # Validate version format
    validate_version "$version"

    # Check if version already exists
    check_version_exists "$version"

    # Run pre-release checks
    run_pre_release_checks

    # Create release
    create_release "$version" "$message"

    print_success "Release process completed successfully!"
    print_status "GitHub Actions will automatically create the release"
    print_status "Monitor the workflow at: https://github.com/dgtlenv-maintainer/DgtlEnv/actions"
}

# Run main function with all arguments
main "$@"
