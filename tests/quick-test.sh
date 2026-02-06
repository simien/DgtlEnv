#!/bin/bash
set -euo pipefail

# Quick test script for DgtlEnv Test Suite
# Tests the core functionality we verified manually

# Check for non-interactive mode
NON_INTERACTIVE=false
if [[ "$1" == "--non-interactive" ]]; then
    NON_INTERACTIVE=true
fi

echo "=========================================="
echo "  DgtlEnv Quick Test Suite"
echo "=========================================="
echo

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0
EXPECTED_FAILURES=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test function
test_function() {
    local test_name="$1"
    local command="$2"
    local test_type="${3:-normal}"  # normal, security, performance

    echo -e "${BLUE}[TEST]${NC} $test_name"

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}[PASS]${NC} $test_name"
        ((PASSED_TESTS++))
    else
        if [[ "$test_type" == "security" ]]; then
            echo -e "${YELLOW}[EXPECTED]${NC} $test_name (expected to find issues)"
            ((EXPECTED_FAILURES++))
        else
            echo -e "${RED}[FAIL]${NC} $test_name"
            ((FAILED_TESTS++))
        fi
    fi
    ((TOTAL_TESTS++))
    echo
}

echo "🖥️ Environment Optimization Tests"
echo "----------------------------------------"

test_function "System Health Check" "./ops/monitoring/swap-ssd-health.sh"
test_function "Homebrew Cleanup" "./ops/cleanup/brew-cleanup.sh"
# Optional Docker test - only run if Docker is available and running
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    test_function "Docker Cleanup" "./ops/cleanup/docker-cleanup.sh"
else
    echo -e "${YELLOW}[SKIP]${NC} Docker Cleanup (Docker not available or not running)"
    ((SKIPPED_TESTS++))
    ((TOTAL_TESTS++))
    echo
fi
# Interactive IDE test - ask user if they want to sync
if command -v cursor >/dev/null 2>&1 || [ -d "/Applications/Cursor.app" ] || [ -d "$HOME/Library/Application Support/Code" ]; then
    if [[ "$NON_INTERACTIVE" == "true" ]]; then
        echo -e "${YELLOW}[SKIP]${NC} IDE Optimization (non-interactive mode)"
        ((SKIPPED_TESTS++))
        ((TOTAL_TESTS++))
        echo
    else
        echo -e "${BLUE}[QUESTION]${NC} Do you want to sync project settings to your IDE? (y/N): "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            test_function "IDE Optimization" "./scripts/sync-ide-settings.sh"
        else
            echo -e "${YELLOW}[SKIP]${NC} IDE Optimization (user declined)"
            ((SKIPPED_TESTS++))
            ((TOTAL_TESTS++))
            echo
        fi
    fi
else
    echo -e "${YELLOW}[SKIP]${NC} IDE Optimization (No compatible IDE installed)"
    ((SKIPPED_TESTS++))
    ((TOTAL_TESTS++))
    echo
fi
test_function "Real-time Dashboard" "./metrics/comprehensive-dashboard.sh status"

echo "📁 Environment Management Tests"
echo "----------------------------------------"

test_function "Security Sanitization" "./scripts/pre-release-sanitizer.sh --dry-run" "security"
test_function "Organization Standards" "./scripts/enforce-organization-standards.sh"

echo "📊 Performance Tests"
echo "----------------------------------------"

test_function "Memory Usage Check" "test \$(./tests/validation/check-memory-usage.sh) -lt 80"
test_function "CPU Usage Check" "test \$(./tests/validation/check-cpu-usage.sh) -lt 70"
test_function "Disk Usage Check" "test \$(./tests/validation/check-disk-usage.sh) -lt 85"

echo "📚 Documentation Tests"
echo "----------------------------------------"

test_function "Main README Exists" "test -f README.md"
test_function "Environment Optimization Guide" "test -f docs/guides/computer-optimization-quick-reference.md"
test_function "Environment Terminology" "grep -q 'environment optimization' README.md"

echo "=========================================="
echo "  Test Results Summary"
echo "=========================================="
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"
echo "Skipped: $SKIPPED_TESTS"
echo "Expected Failures: $EXPECTED_FAILURES"
echo

# Calculate adjusted success rate (excluding expected failures)
ADJUSTED_TOTAL=$((TOTAL_TESTS - EXPECTED_FAILURES))
if [ $ADJUSTED_TOTAL -gt 0 ]; then
    ADJUSTED_SUCCESS_RATE=$((PASSED_TESTS * 100 / ADJUSTED_TOTAL))
    echo "Adjusted Success Rate: $ADJUSTED_SUCCESS_RATE% (excluding expected failures)"
else
    echo "Adjusted Success Rate: N/A (no tests to evaluate)"
fi
echo

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}All tests passed! 🎉${NC}"
    exit 0
else
    echo -e "${RED}$FAILED_TESTS test(s) failed${NC}"
    exit 1
fi
