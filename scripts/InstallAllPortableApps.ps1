$ErrorActionPreference = 'SilentlyContinue'
# $Excluded = "*Nightly-*","*NightlyCLI-*","*Alpha-*","*AlphaCLI-*","*Beta-*","*BetaCLI-*","*RC-*","*RCCLI-*","*Dev-*","*DevCLI-*","*Canary-*","*Preview-*"
$Excluded = ""
Get-ChildItem -Path "$env:userprofile\scoop\buckets\scoop-apps\bucket" -File -Recurse -Filter "*Portable.json" -Exclude $Excluded | Select-Object BaseName | ForEach-Object { If(!(test-path -PathType container ("$env:userprofile\scoop\apps\" + $_.Basename))) {scoop install $_.BaseName}}
pause
