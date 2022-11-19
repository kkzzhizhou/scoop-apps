Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -RunAsAdmin -ScoopDir "$env:USERPROFILE\scoop" -ScoopGlobalDir "$env:ProgramData\scoop" -ScoopCacheDir "$env:USERPROFILE\scoop\cache" -NoProxy
scoop install gsudo git scoop-search
scoop config SCOOP_REPO 'https://github.com/Ash258/Scoop-Core'
scoop update
scoop bucket add 'Base'
scoop bucket add Scoop-Apps 'https://github.com/ACooper81/scoop-apps'
# gsudo
scoop install aria2 7zip git gsudo dark innounp lessmsi scoop-search --global --no-cache
Add-MpPreference -ExclusionPath "$env:ProgramData\scoop"
Add-MpPreference -ExclusionPath 'C:\ProgramData\scoop'
[Environment]::SetEnvironmentVariable('SCOOP', "$env:USERPROFILE\scoop", 'User')
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', 'C:\ProgramData\scoop', 'Machine')
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
scoop update
scoop checkup
