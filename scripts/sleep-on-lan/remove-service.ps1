nssm stop SleepOnLAN
nssm remove SleepOnLAN confirm
Write-Host "Removing Windows firewall rules ..."
Remove-NetFirewallRule -Description "Work with Sleep-On-LAN service." -ErrorAction SilentlyContinue
