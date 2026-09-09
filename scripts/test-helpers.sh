#!/usr/bin/env bash
# Test helper library for scoop-bucket unit tests
# Source this file from test scripts: source "$(dirname "$0")/test-helpers.sh"
#
# Provides:
#   - Assertion functions (assert_equals, assert_contains, assert_file_exists, etc.)
#   - Structured JSON logging
#   - Test lifecycle management (setup/teardown with temp dirs)
#   - Mock infrastructure for curl/git/gh
#   - TAP-compatible output

set -uo pipefail

#==============================================================================
# State
#==============================================================================

declare -g _TEST_PASSED=0
declare -g _TEST_FAILED=0
declare -g _TEST_SKIPPED=0
declare -g _ASSERT_PASSED=0
declare -g _ASSERT_FAILED=0
declare -g _TEST_START_TIME=""
declare -g _TEST_NAME=""
declare -g _TEST_DIR=""
declare -g _TEST_LOG_FORMAT="${LOG_FORMAT:-text}"  # text|json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

#==============================================================================
# Logging
#==============================================================================

_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
}

_millis() {
    date +%s%3N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1000))'
}

log_test() {
    local level="$1" msg="$2"
    shift 2
    local ts
    ts=$(_timestamp)

    if [[ "$_TEST_LOG_FORMAT" == "json" ]]; then
        printf '{"timestamp":"%s","level":"%s","test":"%s","message":"%s"' "$ts" "$level" "$_TEST_NAME" "$msg"
        while [[ $# -ge 2 ]]; do
            printf ',"%s":"%s"' "$1" "$2"
            shift 2
        done
        printf '}\n'
    else
        printf "[%s] %-4s %s\n" "$ts" "$level" "$msg"
    fi
}

#==============================================================================
# Test lifecycle
#==============================================================================

setup_test() {
    local name="$1"
    _TEST_NAME="$name"
    _TEST_START_TIME=$(_millis)
    _TEST_DIR=$(mktemp -d)
    log_test "INFO" "Starting: $name"
}

teardown_test() {
    if [[ -n "$_TEST_DIR" && -d "$_TEST_DIR" ]]; then
        rm -rf "$_TEST_DIR"
    fi
    _TEST_DIR=""
}

#==============================================================================
# Assertions
#==============================================================================

pass() {
    local msg="$1"
    _ASSERT_PASSED=$((_ASSERT_PASSED + 1))
    echo "PASS: $msg"
}

fail() {
    local msg="$1"
    _ASSERT_FAILED=$((_ASSERT_FAILED + 1))
    echo "FAIL: $msg"
}

assert_equals() {
    local expected="$1" actual="$2" msg="${3:-Values should be equal}"
    if [[ "$expected" == "$actual" ]]; then
        pass "$msg"
    else
        fail "$msg"
        echo "       Expected: $expected"
        echo "       Actual:   $actual"
    fi
}

assert_not_equals() {
    local unexpected="$1" actual="$2" msg="${3:-Values should differ}"
    if [[ "$unexpected" != "$actual" ]]; then
        pass "$msg"
    else
        fail "$msg"
        echo "       Should not be: $unexpected"
    fi
}

assert_contains() {
    local haystack="$1" needle="$2" msg="${3:-Should contain substring}"
    if [[ "$haystack" == *"$needle"* ]]; then
        pass "$msg"
    else
        fail "$msg"
        echo "       Expected substring: $needle"
        echo "       In: ${haystack:0:200}"
    fi
}

assert_not_contains() {
    local haystack="$1" needle="$2" msg="${3:-Should not contain substring}"
    if [[ "$haystack" != *"$needle"* ]]; then
        pass "$msg"
    else
        fail "$msg"
        echo "       Unexpected substring: $needle"
    fi
}

assert_file_exists() {
    local file="$1" msg="${2:-File should exist: $1}"
    if [[ -f "$file" ]]; then
        pass "$msg"
    else
        fail "$msg"
    fi
}

assert_file_not_exists() {
    local file="$1" msg="${2:-File should not exist: $1}"
    if [[ ! -f "$file" ]]; then
        pass "$msg"
    else
        fail "$msg"
    fi
}

assert_file_contains() {
    local file="$1" pattern="$2" msg="${3:-File should contain pattern}"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        pass "$msg"
    else
        fail "$msg"
        echo "       Pattern: $pattern"
        echo "       File: $file"
    fi
}

assert_exit_code() {
    local expected="$1" actual="$2" msg="${3:-Exit code should match}"
    assert_equals "$expected" "$actual" "$msg"
}

assert_not_empty() {
    local value="$1" msg="${2:-Value should not be empty}"
    if [[ -n "$value" ]]; then
        pass "$msg"
    else
        fail "$msg"
    fi
}

assert_json_field() {
    local json="$1" field="$2" expected="$3" msg="${4:-JSON field should match}"
    local actual
    actual=$(echo "$json" | jq -r "$field" 2>/dev/null)
    assert_equals "$expected" "$actual" "$msg"
}

#==============================================================================
# Mock infrastructure
#==============================================================================

# File-based mock for curl (survives subshells)
declare -g MOCK_CURL_LOG=""
declare -g MOCK_CURL_RESPONSES=""

setup_curl_mock() {
    MOCK_CURL_LOG="$_TEST_DIR/curl_calls.log"
    MOCK_CURL_RESPONSES="$_TEST_DIR/curl_responses"
    mkdir -p "$MOCK_CURL_RESPONSES"
    : > "$MOCK_CURL_LOG"
}

# Register a mock response for a URL pattern
# Usage: mock_curl_response "pattern" "response_body" [exit_code]
mock_curl_response() {
    local pattern="$1" body="$2" exit_code="${3:-0}"
    local safe_name
    safe_name=$(echo "$pattern" | md5sum | cut -d' ' -f1)
    echo "$body" > "$MOCK_CURL_RESPONSES/${safe_name}.body"
    echo "$exit_code" > "$MOCK_CURL_RESPONSES/${safe_name}.exit"
    echo "$pattern" > "$MOCK_CURL_RESPONSES/${safe_name}.pattern"
}

# Mock curl function - call setup_curl_mock first, then define this in your test
_mock_curl() {
    local url=""
    local args=("$@")

    # Extract URL (last non-flag argument or -L target)
    for arg in "${args[@]}"; do
        if [[ "$arg" != -* ]]; then
            url="$arg"
        fi
    done

    echo "$*" >> "$MOCK_CURL_LOG"

    # Find matching response
    for pattern_file in "$MOCK_CURL_RESPONSES"/*.pattern; do
        [[ -f "$pattern_file" ]] || continue
        local pattern
        pattern=$(cat "$pattern_file")
        if [[ "$url" == *"$pattern"* || "$*" == *"$pattern"* ]]; then
            local base="${pattern_file%.pattern}"
            cat "${base}.body"
            return "$(cat "${base}.exit")"
        fi
    done

    echo "MOCK_CURL: no response for: $url" >&2
    return 1
}

curl_mock_called_with() {
    local pattern="$1"
    [[ -f "$MOCK_CURL_LOG" ]] && grep -q "$pattern" "$MOCK_CURL_LOG"
}

curl_mock_call_count() {
    if [[ -f "$MOCK_CURL_LOG" ]]; then
        wc -l < "$MOCK_CURL_LOG"
    else
        echo 0
    fi
}

# File-based mock for git
declare -g MOCK_GIT_LOG=""

setup_git_mock() {
    MOCK_GIT_LOG="$_TEST_DIR/git_calls.log"
    : > "$MOCK_GIT_LOG"
}

git_mock_called_with() {
    local pattern="$1"
    [[ -f "$MOCK_GIT_LOG" ]] && grep -q "$pattern" "$MOCK_GIT_LOG"
}

#==============================================================================
# Test runner
#==============================================================================

run_test() {
    local func="$1"
    local name="${func#test_}"

    echo ""
    echo "Running: $func"
    echo "----------------------------------------"

    setup_test "$name"

    local exit_code=0
    local before_fail=$_ASSERT_FAILED
    "$func" || exit_code=$?

    local duration=0
    local now
    now=$(_millis)
    if [[ -n "$_TEST_START_TIME" ]]; then
        duration=$((now - _TEST_START_TIME))
    fi

    if [[ $exit_code -ne 0 ]] || [[ $_ASSERT_FAILED -gt $before_fail ]]; then
        _TEST_FAILED=$((_TEST_FAILED + 1))
        log_test "FAIL" "$name (${duration}ms)"
        echo "TEST FAILED: $func"
    else
        _TEST_PASSED=$((_TEST_PASSED + 1))
        log_test "PASS" "$name (${duration}ms)"
        echo "TEST PASSED: $func"
    fi

    teardown_test
}

print_results() {
    echo ""
    echo "============================================"
    echo "Test Results"
    echo "============================================"
    echo "Tests:      $_TEST_PASSED passed, $_TEST_FAILED failed, $_TEST_SKIPPED skipped"
    echo "Assertions: $_ASSERT_PASSED passed, $_ASSERT_FAILED failed"
    echo "============================================"

    if [[ "$_TEST_LOG_FORMAT" == "json" ]]; then
        printf '{"summary":{"tests_passed":%d,"tests_failed":%d,"tests_skipped":%d,"assertions_passed":%d,"assertions_failed":%d}}\n' \
            "$_TEST_PASSED" "$_TEST_FAILED" "$_TEST_SKIPPED" "$_ASSERT_PASSED" "$_ASSERT_FAILED"
    fi

    [[ $_TEST_FAILED -eq 0 ]]
}
