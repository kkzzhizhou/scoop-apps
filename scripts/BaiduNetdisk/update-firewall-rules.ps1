Remove-NetFirewallRule -Description "Work with BaiduNetdisk from scoop bucket Scoop4kariiin." -ErrorAction SilentlyContinue
'TCP', 'UDP' | ForEach-Object {
    New-NetFirewallRule `
        -DisplayName "BaiduNetdiskHost" `
        -Profile "Private, Public" `
        -Description "Work with BaiduNetdisk from scoop bucket Scoop4kariiin." `
        -Direction Inbound `
        -Protocol $_ `
        -Action Allow `
        -Program "$BNHPaths" `
        -EdgeTraversalPolicy DeferToUser `
    | Out-Null
    New-NetFirewallRule `
        -DisplayName "BaiduNetdiskUnite" `
        -Profile "Private, Public" `
        -Description "Work with BaiduNetdisk from scoop bucket Scoop4kariiin." `
        -Direction Inbound `
        -Protocol $_ `
        -Action Allow `
        -Program "$BNUPaths" `
        -EdgeTraversalPolicy DeferToUser `
    | Out-Null
}
