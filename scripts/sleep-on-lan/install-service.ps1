nssm install SleepOnLAN "$SOLBinPath"
nssm set SleepOnLAN Description Sleep-On-LAN service installed by scoop installer.
nssm set SleepOnLAN AppStdout "$SOLLogPath"
nssm set SleepOnLAN AppStderr "$SOLLogPath"
Write-Host "Updating Windows firewall rules..."
Remove-NetFirewallRule -Description "Work with Sleep-On-LAN service." -ErrorAction SilentlyContinue
New-NetFirewallRule `
    -DisplayName "SleepOnLAN" `
    -Description "Work with Sleep-On-LAN service." `
    -Direction Inbound `
    -Protocol TCP `
    -Action Allow `
    -LocalPort $SOLPort `
| Out-Null
nssm start SleepOnLAN
