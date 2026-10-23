#!/usr/bin/env bash
# Update a Scoop manifest to a specific upstream release.
# Usage: ./update-manifest.sh <tool> <version>
#
# The pinned hash is always computed from the real Windows asset: the asset is
# downloaded, hashed locally, and cross-checked against the release's .sha256
# sidecar when one is published. A release that does not ship the asset, a
# sidecar that disagrees, or a hash that is not 64 hex characters is a hard
# failure and the manifest is left untouched.
#
# This replaces the old "curl the sidecar and cut the first field" flow, which
# turned GitHub's 404 body ("Not Found") into the literal hash "Not" and
# committed it (scoop-bucket#5), and which advanced manifests to releases that
# never built a Windows artifact at all (scoop-bucket#6).
set -euo pipefail

TOOL="${1:-}"
VERSION="${2:-}"

if [[ -z "$TOOL" || -z "$VERSION" ]]; then
  echo "Usage: $0 <tool> <version>" >&2
  echo "Example: $0 cass 0.6.26" >&2
  exit 2
fi

# Strip 'v' prefix if present
VERSION="${VERSION#v}"
if [[ ! "$VERSION" =~ ^[0-9]+(\.[0-9]+)*([.-][0-9A-Za-z.]+)?$ ]]; then
  echo "Error: '$VERSION' does not look like a release version" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUCKET_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST_FILE="$BUCKET_DIR/${TOOL}.json"

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "Error: Manifest file not found: $MANIFEST_FILE" >&2
  exit 1
fi

for dep in curl jq; do
  command -v "$dep" >/dev/null 2>&1 || { echo "Error: required tool not found: $dep" >&2; exit 1; }
done

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -d' ' -f1
  else
    echo "Error: neither sha256sum nor shasum is available" >&2
    return 1
  fi
}

# Scoop manifests come in two shapes: architecture-keyed ("architecture.64bit")
# and flat (top-level "url"/"hash"). Handle both, preferring the autoupdate
# template (with $version substituted) so the asset name is exactly what Scoop
# itself would fetch; fall back to rewriting the version in the current URL.
if jq -e '.architecture."64bit"' "$MANIFEST_FILE" >/dev/null 2>&1; then
  ARCH_KEYED=1
  TEMPLATE="$(jq -r '.autoupdate.architecture."64bit".url // empty' "$MANIFEST_FILE")"
  CURRENT_URL="$(jq -r '.architecture."64bit".url // empty' "$MANIFEST_FILE")"
else
  ARCH_KEYED=0
  TEMPLATE="$(jq -r '.autoupdate.url // empty' "$MANIFEST_FILE")"
  CURRENT_URL="$(jq -r '.url // empty' "$MANIFEST_FILE")"
fi

if [[ -n "$TEMPLATE" ]]; then
  NEW_URL="${TEMPLATE//\$version/$VERSION}"
elif [[ -n "$CURRENT_URL" ]]; then
  NEW_URL="$(printf '%s' "$CURRENT_URL" | sed -E "s#/v[0-9]+(\.[0-9]+)*([.-][0-9A-Za-z.]+)?/#/v${VERSION}/#")"
else
  echo "Error: $MANIFEST_FILE has neither an autoupdate URL template nor a current URL" >&2
  exit 1
fi

if [[ "$NEW_URL" != *"$VERSION"* ]]; then
  echo "Error: could not derive a v${VERSION} download URL from $MANIFEST_FILE (got: $NEW_URL)" >&2
  exit 1
fi

# Scoop's "#/name.exe" suffix renames the download; it is not part of the URL.
DOWNLOAD_URL="${NEW_URL%%#*}"
ASSET_NAME="${DOWNLOAD_URL##*/}"

echo "Updating $TOOL to version $VERSION"
echo "Asset: $DOWNLOAD_URL"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# -f makes a 404 a failure instead of a saved HTML error page. This is the
# guard that prevents "Not Found" from ever becoming a hash again.
if ! curl -fsSL --retry 3 --retry-delay 2 --max-time 600 -o "$WORK_DIR/$ASSET_NAME" "$DOWNLOAD_URL"; then
  echo "Error: release v${VERSION} of $TOOL does not publish $ASSET_NAME (download failed)." >&2
  echo "       The manifest was not changed; the release has no Windows asset at that URL." >&2
  exit 1
fi

if [[ ! -s "$WORK_DIR/$ASSET_NAME" ]]; then
  echo "Error: downloaded asset is empty: $DOWNLOAD_URL" >&2
  exit 1
fi

CHECKSUM="$(sha256_file "$WORK_DIR/$ASSET_NAME")"
CHECKSUM="$(printf '%s' "$CHECKSUM" | tr '[:upper:]' '[:lower:]')"
if [[ ! "$CHECKSUM" =~ ^[0-9a-f]{64}$ ]]; then
  echo "Error: computed hash is not a sha256 digest: '$CHECKSUM'" >&2
  exit 1
fi

# Cross-check against the published sidecar when the release ships one. A
# missing sidecar is fine (the locally computed hash stands); a sidecar that
# exists but disagrees is not.
SIDECAR_URL="${DOWNLOAD_URL}.sha256"
if curl -fsSL --retry 2 --max-time 60 -o "$WORK_DIR/sidecar" "$SIDECAR_URL" 2>/dev/null; then
  SIDECAR_HASH="$(grep -Eo '[0-9a-fA-F]{64}' "$WORK_DIR/sidecar" | head -n1 || true)"
  SIDECAR_HASH="$(printf '%s' "$SIDECAR_HASH" | tr '[:upper:]' '[:lower:]')"
  if [[ -z "$SIDECAR_HASH" ]]; then
    echo "Error: sidecar $SIDECAR_URL exists but contains no sha256 digest" >&2
    exit 1
  fi
  if [[ "$SIDECAR_HASH" != "$CHECKSUM" ]]; then
    echo "Error: sidecar hash disagrees with the downloaded asset" >&2
    echo "       sidecar:  $SIDECAR_HASH" >&2
    echo "       computed: $CHECKSUM" >&2
    exit 1
  fi
  echo "Checksum: $CHECKSUM (matches published .sha256 sidecar)"
else
  echo "Checksum: $CHECKSUM (computed locally; no .sha256 sidecar published)"
fi

# Update the manifest (version, hash, and URL in one pass)
if [[ "$ARCH_KEYED" == 1 ]]; then
  jq --indent 2 --arg version "$VERSION" --arg hash "$CHECKSUM" --arg url "$NEW_URL" '
    .version = $version |
    .architecture."64bit".hash = $hash |
    .architecture."64bit".url = $url
  ' "$MANIFEST_FILE" > "${MANIFEST_FILE}.tmp"
else
  jq --indent 2 --arg version "$VERSION" --arg hash "$CHECKSUM" --arg url "$NEW_URL" '
    .version = $version |
    .hash = $hash |
    .url = $url
  ' "$MANIFEST_FILE" > "${MANIFEST_FILE}.tmp"
fi
mv "${MANIFEST_FILE}.tmp" "$MANIFEST_FILE"

echo "Manifest updated: $MANIFEST_FILE"
echo ""
echo "Changes:"
git -C "$BUCKET_DIR" --no-pager diff -- "${TOOL}.json" || true
