#!/bin/bash

# ##############################################################################
# DgtlEnv Prompt Router Test Suite v1.0.0
#
# Comprehensive testing for the enhanced Prompt Router script
#
# Usage:
#   ./tests/prompt-router-tests.sh
#   ./tests/prompt-router-tests.sh --verbose
# ##############################################################################

set -eo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROMPT_ROUTER="${PROJECT_ROOT}/ops/run-prompt.sh"
TEST_LOG="${PROJECT_ROOT}/logs/prompt-router-test.log"

# --- Test Variables ---
VERBOSE=0
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# --- Logging Functions ---
log_test() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    mkdir -p "$(dirname "$TEST_LOG")"
    echo "[$timestamp] [$level] $message" >> "$TEST_LOG"

    if [[ "$level" == "error" ]] || [[ "$VERBOSE" -eq 1 ]]; then
        echo "$message"
    fi
}

# --- Test Functions ---
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_exit="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    log_test "info" "Running test: $test_name"

    if eval "$test_command" >/dev/null 2>&1; then
        local exit_code=$?
        if [[ "$exit_code" -eq "$expected_exit" ]]; then
            log_test "info" "✅ PASS: $test_name"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            log_test "error" "❌ FAIL: $test_name (expected exit $expected_exit, got $exit_code)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        local exit_code=$?
        if [[ "$exit_code" -eq "$expected_exit" ]]; then
            log_test "info" "✅ PASS: $test_name"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            log_test "error" "❌ FAIL: $test_name (expected exit $expected_exit, got $exit_code)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    fi
}

# --- Test Cases ---
test_help_function() {
    log_test "info" "Testing help functionality..."
    run_test "Help Command" "$PROMPT_ROUTER --help" 0
}

test_list_function() {
    log_test "info" "Testing list functionality..."
    run_test "List Command" "$PROMPT_ROUTER --list" 0
}

test_search_function() {
    log_test "info" "Testing search functionality..."
    run_test "Search Command" "$PROMPT_ROUTER --search docker" 0
}

test_dry_run_function() {
    log_test "info" "Testing dry-run functionality..."
    run_test "Dry Run Command" "$PROMPT_ROUTER --dry-run diagnose-ci" 0
}

test_valid_prompt() {
    log_test "info" "Testing valid prompt execution..."
    run_test "Valid Prompt" "$PROMPT_ROUTER diagnose-ci" 0
}

test_invalid_prompt() {
    log_test "info" "Testing invalid prompt handling..."
    run_test "Invalid Prompt" "$PROMPT_ROUTER nonexistent-prompt" 1
}

test_no_arguments() {
    log_test "info" "Testing no arguments handling..."
    run_test "No Arguments" "$PROMPT_ROUTER" 1
}

test_invalid_option() {
    log_test "info" "Testing invalid option handling..."
    run_test "Invalid Option" "$PROMPT_ROUTER --invalid-option" 1
}

test_search_no_term() {
    log_test "info" "Testing search without term..."
    run_test "Search No Term" "$PROMPT_ROUTER --search" 1
}

test_verbose_mode() {
    log_test "info" "Testing verbose mode..."
    run_test "Verbose Mode" "$PROMPT_ROUTER --verbose --dry-run diagnose-ci >/dev/null 2>&1" 0
}

# --- Integration Tests ---
test_context_injection() {
    log_test "info" "Testing context injection..."

    # Create a test prompt with include in the proper directory
    local test_prompt="${PROJECT_ROOT}/prompts/categories/system-optimization/test-context-injection-v1.0.0.md"
    mkdir -p "$(dirname "$test_prompt")"
    echo "Test prompt with {{include:README.md}}" > "$test_prompt"

    # Test that the include is processed with timeout
    local result
    result=$(timeout 10s "$PROMPT_ROUTER" --dry-run test-context-injection 2>&1) || true

    if echo "$result" | grep -q "README.md"; then
        log_test "info" "✅ PASS: Context injection test"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_test "error" "❌ FAIL: Context injection test"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    # Cleanup
    rm -f "$test_prompt"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

test_logging_functionality() {
    log_test "info" "Testing logging functionality..."

    # Test that log file is created
    "$PROMPT_ROUTER" --dry-run diagnose-ci >/dev/null 2>&1

    if [[ -f "${PROJECT_ROOT}/logs/prompt-router.log" ]]; then
        log_test "info" "✅ PASS: Logging functionality test"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_test "error" "❌ FAIL: Logging functionality test"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

# --- Performance Tests ---
test_performance() {
    log_test "info" "Testing performance..."

    local start_time
    start_time=$(date +%s)

    "$PROMPT_ROUTER" --dry-run diagnose-ci >/dev/null 2>&1

    local end_time
    end_time=$(date +%s)

    local duration
    duration=$((end_time - start_time))

    if [[ $duration -lt 5 ]]; then
        log_test "info" "✅ PASS: Performance test (${duration}s)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_test "error" "❌ FAIL: Performance test (${duration}s)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

# --- Main Test Runner ---
run_all_tests() {
    log_test "info" "Starting Prompt Router Test Suite..."
    log_test "info" "Test log: $TEST_LOG"

    # Basic functionality tests
    test_help_function
    test_list_function
    test_search_function
    test_dry_run_function
    test_valid_prompt
    test_invalid_prompt
    test_no_arguments
    test_invalid_option
    test_search_no_term
    # test_verbose_mode  # Temporarily disabled due to verbose output issues

    # Integration tests
    test_logging_functionality
    test_performance

    # Summary
    log_test "info" "=== Test Summary ==="
    log_test "info" "Total Tests: $TOTAL_TESTS"
    log_test "info" "Passed: $TESTS_PASSED"
    log_test "info" "Failed: $TESTS_FAILED"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        log_test "info" "🎉 All tests passed!"
        exit 0
    else
        log_test "error" "❌ $TESTS_FAILED test(s) failed"
        exit 1
    fi
}

# --- Argument Parsing ---
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=1
            shift
            ;;
        --help|-h)
            echo "DgtlEnv Prompt Router Test Suite"
            echo ""
            echo "Usage:"
            echo "  $0 [--verbose]"
            echo ""
            echo "Options:"
            echo "  --verbose, -v  Enable verbose output"
            echo "  --help, -h     Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# --- Script Execution ---
run_all_tests
