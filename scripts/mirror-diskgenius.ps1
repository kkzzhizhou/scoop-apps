# Mirror DiskGenius CN edition from Lanzou webdisk to this repo's GitHub Releases.
# Run from repo root (or scripts/): powershell -File scripts/mirror-diskgenius.ps1
#
# Flow:
#   1. checkver upstream (internal.eassos.com update.php)
#   2. if manifest already at that version -> exit
#   3. download CN zip x64+x86 from Lanzou via Edge (scripts/lanzou-dl.cjs)
#   4. create GitHub release  tag=diskgenius-zh-v<version>, upload both zips
#   5. rewrite bucket/src manifest (version/url/hash), build, commit, push
#
# Prereqs: gh (authed), node + playwright-core (scripts/ has package.json),
#          local Edge, bun (for scripts/build.ts).
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $repoRoot

# --- 1. upstream version ---
$updateInfo = (New-Object System.Net.WebClient).DownloadString('https://internal.eassos.com/update/diskgenius/update.php')
if ($updateInfo -notmatch '\[([\d.]+)\]') { throw 'cannot parse upstream version' }
$upstream = $Matches[1]
$manifest = Get-Content 'bucket/diskgenius-zh.json' -Raw | ConvertFrom-Json
Write-Host "upstream=$upstream  manifest=$($manifest.version)"
if ($upstream -eq $manifest.version) { Write-Host 'already up to date'; exit 0 }

# --- 2. derive names ---
$clean = $upstream -replace '\.', ''
$x64 = "DG${clean}_x64.zip"
$x86 = "DG${clean}_x86.zip"
$tmp = Join-Path $env:TEMP "diskgenius-mirror-$upstream"
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

# --- 3. download from lanzou (real Edge, non-headless) ---
Push-Location $PSScriptRoot
if (-not (Test-Path 'node_modules/playwright-core')) { npm i playwright-core --silent }
node lanzou-dl.cjs DG64 (Join-Path $tmp $x64)
if ($LASTEXITCODE -ne 0) { Pop-Location; throw 'x64 download failed' }
node lanzou-dl.cjs DG32 (Join-Path $tmp $x86)
if ($LASTEXITCODE -ne 0) { Pop-Location; throw 'x86 download failed' }
Pop-Location
$h64 = (Get-FileHash (Join-Path $tmp $x64) -Algorithm SHA256).Hash.ToLower()
$h86 = (Get-FileHash (Join-Path $tmp $x86) -Algorithm SHA256).Hash.ToLower()
Write-Host "x64 sha256=$h64"
Write-Host "x86 sha256=$h86"

# --- 4. github release ---
$tag = "diskgenius-zh-v$upstream"
gh release create $tag --title "DiskGenius CN $upstream" `
  --notes "Mirrored from official Lanzou share (eassos.lanzoue.com/DG64, DG32) for stable direct download links. Source: diskgenius.cn" `
  (Join-Path $tmp $x64) (Join-Path $tmp $x86)
if ($LASTEXITCODE -ne 0) { throw 'gh release create failed' }

# --- 5. rewrite manifests (bucket+src), build, push ---
$relBase = "https://github.com/LaelLuo/scoop/releases/download/$tag"
foreach ($f in @('bucket/diskgenius-zh.json', 'src/bucket/diskgenius-zh.json')) {
    $j = Get-Content $f -Raw | ConvertFrom-Json
    $j.version = $upstream
    $j.architecture.'64bit'.url = "$relBase/$x64"
    $j.architecture.'64bit'.hash = $h64
    $j.architecture.'32bit'.url = "$relBase/$x86"
    $j.architecture.'32bit'.hash = $h86
    $j | ConvertTo-Json -Depth 10 | Set-Content $f -Encoding utf8
}
Push-Location $PSScriptRoot
bun build.ts --only diskgenius-zh
Pop-Location
git add -- bucket/diskgenius-zh.json src/bucket/diskgenius-zh.json
git commit -m "diskgenius-zh: Update to version $upstream (mirror from Lanzou)"
git pull --rebase
git push
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "DONE $upstream"
