#!/usr/bin/env bash
# Installation lifecycle verifier for Scoop bucket tools.
# Bash wrapper that delegates to PowerShell on Windows, or tests manifests
# structurally on non-Windows CI (validates JSON, URLs, checksums).
#
# Usage:
#   ./verify-installation.sh [--json] [--verbose] [TOOL...]
#   Omit TOOL args to test all manifests in the bucket.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

JSON_MODE="${JSON_MODE:-false}"
VERBOSE="${VERBOSE:-false}"
LOG_DIR="${LOG_DIR:-/tmp/verify-install}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$LOG_DIR"

# Parse flags
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --json)    JSON_MODE="true"; shift ;;
        --verbose) VERBOSE="true"; shift ;;
        -*)        echo "Unknown flag: $1" >&2; exit 4 ;;
        *)         POSITIONAL+=("$1"); shift ;;
    esac
done
set -- "${POSITIONAL[@]+"${POSITIONAL[@]}"}"

_ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

log() {
    local level="$1" msg="$2"
    shift 2
    local ts
    ts=$(_ts)

    if [[ "$JSON_MODE" == "true" ]]; then
        printf '{"timestamp":"%s","level":"%s","message":"%s"' "$ts" "$level" "$msg"
        while [[ $# -ge 2 ]]; do
            local key="$1" val="$2"
            val="${val//\"/\\\"}"
            printf ',"%s":"%s"' "$key" "$val"
            shift 2
        done
        printf '}\n'
    else
        printf "[%s] %-5s %s" "$ts" "$level" "$msg"
        while [[ $# -ge 2 ]]; do
            printf " %s=%s" "$1" "$2"
            shift 2
        done
        printf '\n'
    fi
}

TOTAL=0
PASSED=0
FAILED=0
declare -a RESULTS_ARRAY=()

# On Windows (Git Bash / MSYS), delegate to PowerShell
if [[ "$(uname -o 2>/dev/null)" == "Msys" ]] || [[ -n "${WINDIR:-}" ]]; then
    log "INFO" "Windows detected, delegating to PowerShell"
    PS_FLAGS=()
    [[ "$JSON_MODE" == "true" ]] && PS_FLAGS+=("-Json")
    powershell.exe -ExecutionPolicy Bypass -File "$SCRIPT_DIR/verify-installation.ps1" ${PS_FLAGS[@]+"${PS_FLAGS[@]}"} "$@"
    exit $?
fi

# On Linux/macOS: validate manifest structure (can't run Scoop)
validate_manifest() {
    local tool="$1"
    local manifest="$REPO_DIR/${tool}.json"
    TOTAL=$((TOTAL + 1))

    log "INFO" "Validating manifest" "tool" "$tool" "phase" "start"

    # Check file exists
    if [[ ! -f "$manifest" ]]; then
        log "ERROR" "Manifest not found" "tool" "$tool"
        FAILED=$((FAILED + 1))
        RESULTS_ARRAY+=("{\"tool\":\"$tool\",\"result\":\"fail\",\"phase\":\"file_check\"}")
        return 1
    fi

    # Validate JSON syntax
    if ! jq empty "$manifest" 2>/dev/null; then
        log "ERROR" "Invalid JSON" "tool" "$tool"
        FAILED=$((FAILED + 1))
        RESULTS_ARRAY+=("{\"tool\":\"$tool\",\"result\":\"fail\",\"phase\":\"json_check\"}")
        return 1
    fi

    # Validate required fields
    local version
    version=$(jq -r '.version // empty' "$manifest")
    if [[ -z "$version" ]]; then
        log "ERROR" "Missing version field" "tool" "$tool"
        FAILED=$((FAILED + 1))
        RESULTS_ARRAY+=("{\"tool\":\"$tool\",\"result\":\"fail\",\"phase\":\"version_check\"}")
        return 1
    fi

    # Validate URL field exists
    local url
    url=$(jq -r '.architecture."64bit".url // .url // empty' "$manifest")
    if [[ -z "$url" ]]; then
        log "ERROR" "Missing download URL" "tool" "$tool"
        FAILED=$((FAILED + 1))
        RESULTS_ARRAY+=("{\"tool\":\"$tool\",\"result\":\"fail\",\"phase\":\"url_check\"}")
        return 1
    fi

    # Validate the pinned hash is a real sha256 digest. An empty string or a
    # stray error fragment (the literal "Not" from a 404 body, scoop-bucket#5)
    # means Scoop cannot verify what it downloads, so this is a hard failure.
    local hash
    hash=$(jq -r '.architecture."64bit".hash // .hash // empty' "$manifest")
    if [[ ! "$hash" =~ ^[0-9a-fA-F]{64}$ ]]; then
        log "ERROR" "Pinned hash is not a sha256 digest" "tool" "$tool" "hash" "${hash:-<empty>}"
        FAILED=$((FAILED + 1))
        RESULTS_ARRAY+=("{\"tool\":\"$tool\",\"result\":\"fail\",\"phase\":\"hash_check\"}")
        return 1
    fi

    # Validate URL is reachable (HEAD request with timeout)
    local http_code
    http_code=$(curl -sL -o /dev/null -w '%{http_code}' --connect-timeout 10 --max-time 30 "$url" 2>/dev/null) || true
    if [[ "$http_code" == "200" ]] || [[ "$http_code" == "302" ]]; then
        log "INFO" "URL reachable" "tool" "$tool" "url" "$url" "http_code" "$http_code"
    else
        log "WARN" "URL check returned $http_code (non-fatal)" "tool" "$tool" "url" "$url"
    fi

    log "INFO" "Manifest valid" "tool" "$tool" "version" "$version" "result" "pass"
    PASSED=$((PASSED + 1))
    RESULTS_ARRAY+=("{\"tool\":\"$tool\",\"result\":\"pass\",\"version\":\"$version\"}")
    return 0
}

# Determine tool list
TOOLS=()
if [[ ${#POSITIONAL[@]} -gt 0 ]]; then
    TOOLS=("${POSITIONAL[@]}")
else
    shopt -s nullglob
    for f in "$REPO_DIR"/*.json; do
        name=$(basename "$f" .json)
        TOOLS+=("$name")
    done
    shopt -u nullglob
fi

if [[ ${#TOOLS[@]} -eq 0 ]]; then
    log "ERROR" "No tools to verify"
    exit 4
fi

log "INFO" "Starting Scoop manifest verification" "tool_count" "${#TOOLS[@]}" "platform" "$(uname -sm)"

for tool in "${TOOLS[@]}"; do
    validate_manifest "$tool" || true
done

log "INFO" "Suite complete" "total" "$TOTAL" "passed" "$PASSED" "failed" "$FAILED"

# Write JSON results
{
    printf '{"generated_at":"%s","platform":"%s","total":%d,"passed":%d,"failed":%d,"tools":[%s]}\n' \
        "$(_ts)" "$(uname -sm)" "$TOTAL" "$PASSED" "$FAILED" \
        "$(IFS=,; echo "${RESULTS_ARRAY[*]}")"
} > "$LOG_DIR/scoop-verify-results-$TIMESTAMP.json"

log "INFO" "Results written" "path" "$LOG_DIR/scoop-verify-results-$TIMESTAMP.json"

[[ $FAILED -eq 0 ]]
