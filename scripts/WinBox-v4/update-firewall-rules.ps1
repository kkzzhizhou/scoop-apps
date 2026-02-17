Remove-NetFirewallRule -Description "Work with WinBox-v4 from scoop bucket Scoop4kariiin." -ErrorAction SilentlyContinue
'TCP', 'UDP' | ForEach-Object {
    New-NetFirewallRule `
        -DisplayName "WinBox" `
        -Profile "Private, Public" `
        -Description "Work with WinBox-v4 from scoop bucket Scoop4kariiin." `
        -Direction Inbound `
        -Protocol $_ `
        -Action Allow `
        -Program "$BinPath" `
        -EdgeTraversalPolicy DeferToUser `
    | Out-Null
}
