$spotify_path = scoop which Spotify

if (-not $spotify_path) {
    Write-Error "The spotify-latest` package is not installed."
    exit 1
}

$spotify_dir = Split-Path $spotify_path

if ((Split-Path (Split-Path $spotify_dir) -leaf) -ne "spotify-latest") {
    Write-Error "The `spotify-latest` package is not installed."
    exit 1
}

$spotify_running = Get-Process -ErrorAction Ignore -Name Spotify
Stop-Process -ErrorAction Ignore -Name Spotify | Out-Null

Move-Item -Force "$spotify_dir\chrome_elf.dll" -Destination "$spotify_dir\chrome_elf.dll.original"
Copy-Item "$PSScriptRoot\chrome_elf.dll" -Destination "$spotify_dir"
if (-not (Get-Content -ErrorAction Ignore "$spotify_dir\config.ini")) { Copy-Item "$PSScriptRoot\config.ini" -Destination "$spotify_dir" }

if ($spotify_running) { Start-Process "$spotify_path" }
