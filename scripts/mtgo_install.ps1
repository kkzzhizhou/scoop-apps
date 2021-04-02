param($dir)

start $dir\setup.exe -wait

# ClickOnce installer will start MTGO right away, let's stop it right away too

# wait until MTGO has started
$started = $false
Do {
    $status = Get-Process mtgo -ErrorAction SilentlyContinue
    If (!($status)) { Start-Sleep -Seconds 1 }
    Else { $started = $true }
}
Until ( $started )

# then close it
Stop-Process -Name mtgo
