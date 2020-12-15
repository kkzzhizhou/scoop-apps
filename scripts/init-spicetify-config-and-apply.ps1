$spotify_running = Get-Process -ErrorAction Ignore -Name Spotify
& "$PSScriptRoot\init-spicetify-config.ps1"
& "$PSScriptRoot\spicetify-apply.ps1" -quiet
if ($spotify_running) { Start-Process "$(& `"$PSScriptRoot\get-spotify-path.ps1`")" }
