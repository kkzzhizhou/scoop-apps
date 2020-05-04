$spotify_path = & "$PSScriptRoot\get-spotify-path.ps1"

# spicetify-cli refuses to apply without a backup, and for that, spicetify-cli needs a prefs file so it can tell which version of Spotify is currently installed.
if (-not (Test-Path "$env:APPDATA\Spotify\prefs")) {
    $spotify_version = (Select-String -Path $spotify_path -Pattern '\\d\\.\\d\\.\\d+\\.\\d+\\.[a-z1-9]+' | Select-Object -First 1).Matches[0].Groups[0].Value
    New-Item -ItemType Directory -Force -Path "$env:APPDATA\\Spotify" | Out-Null
    Set-Content "$env:APPDATA\Spotify\prefs" "app.last-launched-version=`"$spotify_version`""
}

Stop-Process -Name Spotify

$config_exists = Test-Path "$env:USERPROFILE\.spicetify\config.ini"

& "$PSScriptRoot\spicetify.exe" config spotify_path "$(Resolve-Path(Split-Path $spotify_path))" --quiet

if (-not $config_exists) {
    & "$PSScriptRoot\spicetify.exe" config experimental_features 1 --quiet
    & "$PSScriptRoot\spicetify.exe" config extensions "autoSkipExplicit.js|keyboardShortcut.js|queueAll.js|shuffle+.js|webnowplaying.js" --quiet
}
