param($dir)
$registryKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
Get-ChildItem $dir -Filter '*.ttf' | ForEach-Object {
    Remove-ItemProperty -Path $registryKey -Name $_.Name.Replace($_.Extension, ' (TrueType)') -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:windir\Fonts\$($_.Name)" -Force -ErrorAction SilentlyContinue
}
