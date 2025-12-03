gsudo
scoop install aria2 7zip git gsudo dark innounp lessmsi scoop-search --global --no-cache
sudo scoop list
Add-MpPreference -ExclusionPath 'C:\ProgramData\scoop'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', 'C:\ProgramData\scoop', 'Machine')
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
scoop update
scoop checkup
