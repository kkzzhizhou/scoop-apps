#!/usr/bin/env bash
# lint-manifests.sh — validate every Scoop manifest in this bucket.
#
# Checks, per manifest (*.json at the repo root):
#   1. The file parses as JSON.
#   2. Every architecture entry (and any top-level url) has a non-empty hash
#      that looks like a real digest (64-hex sha256, or "<algo>:<hex>").
#   3. Every download URL actually exists (HTTP 200 after redirects).
#
# Usage: scripts/lint-manifests.sh [--offline]
#   --offline  skip the URL-existence checks (hash checks only)
#
# Exit status: 0 if all manifests pass, 1 otherwise.

set -uo pipefail

OFFLINE=0
if [ "${1:-}" = "--offline" ]; then
  OFFLINE=1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAILS=0
CHECKED=0

extract_pairs() {
  # Prints TSV lines: <context>\t<url>\t<hash> for each url/hash pair.
  python3 - "$1" <<'PYEOF'
import json, sys

path = sys.argv[1]
with open(path) as f:
    m = json.load(f)

def emit(ctx, url, h):
    print(f"{ctx}\t{url or ''}\t{h if h is not None else '<missing>'}")

arch = m.get("architecture")
if isinstance(arch, dict):
    for name, entry in arch.items():
        if isinstance(entry, dict) and ("url" in entry or "hash" in entry):
            emit(f"architecture.{name}", entry.get("url"), entry.get("hash"))
if "url" in m:
    h = m.get("hash")
    if isinstance(m["url"], list):
        hashes = h if isinstance(h, list) else [h] * len(m["url"])
        for i, u in enumerate(m["url"]):
            emit(f"url[{i}]", u, hashes[i] if i < len(hashes) else None)
    else:
        emit("url", m["url"], h)
PYEOF
}

check_url() {
  # HEAD first; some hosts reject HEAD, so fall back to a ranged GET.
  local url="$1" code
  code=$(curl -o /dev/null -sIL -w '%{http_code}' --max-time 30 "$url" 2>/dev/null)
  if [ "$code" != "200" ]; then
    code=$(curl -o /dev/null -sL -w '%{http_code}' --max-time 30 -r 0-0 "$url" 2>/dev/null)
  fi
  [ "$code" = "200" ] || [ "$code" = "206" ]
}

for manifest in "$ROOT"/*.json; do
  [ -e "$manifest" ] || continue
  name=$(basename "$manifest")
  CHECKED=$((CHECKED + 1))

  if ! python3 -m json.tool "$manifest" >/dev/null 2>&1; then
    echo "FAIL $name: not valid JSON"
    FAILS=$((FAILS + 1))
    continue
  fi

  pairs=$(extract_pairs "$manifest")
  if [ -z "$pairs" ]; then
    echo "WARN $name: no url/hash entries found"
    continue
  fi

  while IFS=$'\t' read -r ctx url hash; do
    [ -n "$ctx" ] || continue
    if [ -z "$hash" ] || [ "$hash" = "<missing>" ]; then
      echo "FAIL $name [$ctx]: hash is empty or missing"
      FAILS=$((FAILS + 1))
    elif ! printf '%s' "$hash" | grep -qE '^([a-fA-F0-9]{64}|(sha1|sha256|sha512|md5):[a-fA-F0-9]+)$'; then
      echo "FAIL $name [$ctx]: hash does not look like a digest: '$hash'"
      FAILS=$((FAILS + 1))
    fi
    if [ -z "$url" ]; then
      echo "FAIL $name [$ctx]: url is empty"
      FAILS=$((FAILS + 1))
    elif [ "$OFFLINE" -eq 0 ]; then
      if check_url "$url"; then
        echo "  ok $name [$ctx]: $url"
      else
        echo "FAIL $name [$ctx]: url does not exist: $url"
        FAILS=$((FAILS + 1))
      fi
    fi
  done <<EOF
$pairs
EOF
done

echo
echo "Checked $CHECKED manifests; $FAILS failure(s)."
[ "$FAILS" -eq 0 ]
