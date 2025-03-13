Remove-NetFirewallRule -Description "Work with WinBox Beta." -ErrorAction SilentlyContinue
'TCP', 'UDP' | ForEach-Object {
    New-NetFirewallRule `
        -DisplayName "WinBox Beta" `
        -Profile "Private, Public" `
        -Description "Work with WinBox Beta." `
        -Direction Inbound `
        -Protocol $_ `
        -Action Allow `
        -Program "$BinPath" `
        -EdgeTraversalPolicy DeferToUser `
    | Out-Null
}
