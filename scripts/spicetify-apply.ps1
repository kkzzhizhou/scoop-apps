$spotify_running = Get-Process -ErrorAction Ignore -Name Spotify
Stop-Process -ErrorAction Ignore -Name Spotify
# restore should be run separately because if there is no backup, it will error and exit
& "$PSScriptRoot\spicetify.exe" restore --quiet --no-restart
& "$PSScriptRoot\spicetify.exe" backup apply --quiet --no-restart
if (Get-Command "blockthespot" -ErrorAction Ignore) { blockthespot }
if ($spotify_running) { Start-Process "$(& `"$PSScriptRoot\get-spotify-path.ps1`")" }
