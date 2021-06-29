function addhosts([string]$IPURL){
    if((Get-Content $env:windir\System32\drivers\etc\hosts |?{$_ -match "$IPURL"}) -eq $null){
        "$IPURL" | Out-File -FilePath "$env:windir\System32\drivers\etc\hosts" -Append -encoding ascii
        Write-Host "add hosts success:$IPURL"
    }else{
        Write-Host "$IPURL alreay exists, ignored."
    }
}

addhosts "127.0.0.1 scene.vip.xunlei.com"
