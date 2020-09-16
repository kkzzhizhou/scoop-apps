function addhosts([string]$IPURL){
    if((Get-Content $env:windir\System32\drivers\etc\hosts |?{$_ -match "$IPURL"}) -eq $null){
        "$IPURL" | Out-File -FilePath "$env:windir\System32\drivers\etc\hosts" -Append -encoding ascii
        Write-Host "add hosts success:$IPURL"
    }else{
        Write-Host "$IPURL alreay exists, ignored."
    }
}

addhosts "127.0.0.1 transact.netsarang.com"
addhosts "127.0.0.1 update.netsarang.com"
addhosts "127.0.0.1 www.netsarang.com"
addhosts "127.0.0.1 www.netsarang.co.kr"
addhosts "127.0.0.1 sales.netsarang.com"
addhosts "127.0.0.1 active.netsarang.com"
addhosts "127.0.0.1 up.netsarang.com"