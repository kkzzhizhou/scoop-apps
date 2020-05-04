$spotify_running = Get-Process -ErrorAction Ignore -Name Spotify
Stop-Process -ErrorAction Ignore -Name Spotify
& "$PSScriptRoot\spicetify.exe" restore backup apply --quiet --no-restart
if (Get-Command "blockthespot" -ErrorAction Ignore) { blockthespot }
if ($spotify_running) { Start-Process "$(& `"$PSScriptRoot\get-spotify-path.ps1`")" }
