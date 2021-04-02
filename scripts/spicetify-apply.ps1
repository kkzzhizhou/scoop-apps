[CmdletBinding()]
param (
    [Switch]$quiet = $false
)

$spotify_running = Get-Process -ErrorAction Ignore -Name Spotify
Stop-Process -ErrorAction Ignore -Name Spotify

# restore should be run separately because if there is no backup, it will error and exit
# This must be run with --quiet to prevent the version mismatch warning
& "$PSScriptRoot\spicetify.exe" restore --quiet --no-restart

if ($quiet) { & "$PSScriptRoot\spicetify.exe" backup apply --quiet --no-restart }
else { & "$PSScriptRoot\spicetify.exe" backup apply --no-restart }

if (Get-Command "blockthespot" -ErrorAction Ignore) { blockthespot }
if ($spotify_running) { Start-Process "$(& `"$PSScriptRoot\get-spotify-path.ps1`")" }
