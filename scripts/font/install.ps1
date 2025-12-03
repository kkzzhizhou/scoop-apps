param($dir)
$registryKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
Get-ChildItem $dir -Filter '*.ttf' | ForEach-Object {
    New-ItemProperty -Path $registryKey -Name $_.Name.Replace($_.Extension, ' (TrueType)') -Value $_.Name -Force | Out-Null
    Copy-Item $_.FullName "$env:windir\Fonts" -Force -ErrorAction SilentlyContinue
}
