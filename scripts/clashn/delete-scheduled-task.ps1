# delete 'clash-core' scheduled task

$ScheduledTaskName = "clashn-core"
if ($null -ne (Get-ScheduledTask -TaskName $ScheduledTaskName -ErrorAction SilentlyContinue)) {
    Stop-ScheduledTask -TaskName $ScheduledTaskName
    Unregister-ScheduledTask -TaskName $ScheduledTaskName -Confirm:$false
} else {
    Write-Host "'$ScheduledTaskName' task not found" -ForegroundColor Red
    exit 1
}

if ($null -eq (Get-ScheduledTask -TaskName $ScheduledTaskName -ErrorAction SilentlyContinue)) {
    Write-Host "'$ScheduledTaskName' scheduled task delete success." -ForegroundColor Green
} else {
    Write-Host "'$ScheduledTaskName' scheduled task delete failed." -ForegroundColor Red
}
