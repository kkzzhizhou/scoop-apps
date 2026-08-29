# ToolMaster DS - auto-update scoop manifests in this bucket
# Runs checkver + autoupdate for every manifest in .\bucket
param(
    [string]$BucketDir = "."
)

$ErrorActionPreference = 'Continue'

# Ensure scoop is installed
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "scoop not found, installing..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

$bucketDir = Resolve-Path $BucketDir
$bucket = Join-Path $bucketDir 'bucket'

if (-not (Test-Path $bucket)) {
    Write-Host "No bucket directory found: $bucket"
    exit 1
}

$updated = 0
$manifests = Get-ChildItem -Path $bucket -Filter *.json
Write-Host "Found $($manifests.Count) manifests"

foreach ($m in $manifests) {
    $name = $m.BaseName
    Write-Host "--- Checking $name ---"
    scoop checkver $name -u 2>&1 | Write-Host
    if ($LASTEXITCODE -eq 0) {
        $updated++
    }
}

Write-Host "Done. Updated $updated manifest(s)."
if ($updated -gt 0) { exit 0 } else { exit 0 }
