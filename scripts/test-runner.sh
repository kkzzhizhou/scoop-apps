#!/usr/bin/env bash
# Test runner for scoop-bucket
# Usage: ./scripts/test-runner.sh [--json] [--filter=PATTERN] [SUITE]
# Suites: unit, all (default: all)
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Parse arguments
LOG_FORMAT="${LOG_FORMAT:-text}"
FILTER=""
SUITE="all"

for arg in "$@"; do
    case "$arg" in
        --json) LOG_FORMAT="json" ;;
        --filter=*) FILTER="${arg#--filter=}" ;;
        unit|all) SUITE="$arg" ;;
        *)
            echo "Usage: $0 [--json] [--filter=PATTERN] [unit|all]"
            exit 1
            ;;
    esac
done

export LOG_FORMAT

echo "============================================"
echo "scoop-bucket test runner"
echo "Suite: $SUITE"
echo "Format: $LOG_FORMAT"
[[ -n "$FILTER" ]] && echo "Filter: $FILTER"
echo "============================================"

total_passed=0
total_failed=0
total_files=0

run_test_file() {
    local test_file="$1"
    local name
    name=$(basename "$test_file")

    echo ""
    echo ">>> Running: $name"

    local output exit_code
    output=$(bash "$test_file" 2>&1)
    exit_code=$?

    echo "$output"

    # Extract counts from output
    local passed failed
    passed=$(echo "$output" | grep "^Tests:" | grep -oP '\d+ passed' | grep -oP '\d+' || echo 0)
    failed=$(echo "$output" | grep "^Tests:" | grep -oP '\d+ failed' | grep -oP '\d+' || echo 0)

    total_passed=$((total_passed + passed))
    total_failed=$((total_failed + failed))
    total_files=$((total_files + 1))

    return $exit_code
}

# Find and run test files
test_dir="$REPO_DIR/tests"

if [[ ! -d "$test_dir" ]]; then
    echo "No tests/ directory found. Nothing to run."
    exit 0
fi

exit_code=0

case "$SUITE" in
    unit)
        for f in "$test_dir"/unit/test_*.sh; do
            [[ -f "$f" ]] || continue
            [[ -n "$FILTER" && "$(basename "$f")" != *"$FILTER"* ]] && continue
            run_test_file "$f" || exit_code=1
        done
        ;;
    all)
        for f in "$test_dir"/*/test_*.sh "$test_dir"/test_*.sh; do
            [[ -f "$f" ]] || continue
            [[ -n "$FILTER" && "$(basename "$f")" != *"$FILTER"* ]] && continue
            run_test_file "$f" || exit_code=1
        done
        ;;
esac

echo ""
echo "============================================"
echo "Overall Results ($total_files test files)"
echo "============================================"
echo "Tests: $total_passed passed, $total_failed failed"
echo "============================================"

exit $exit_code
