# create 'clash-core' scheduled task

$ScheduledTaskName = "clashn-core"
if ($null -eq (Get-ScheduledTask -TaskName $ScheduledTaskName -ErrorAction SilentlyContinue)) {
    try {
        $ScheduledTaskDescription = "Run $($ScheduledTaskName) at startup"
        $Program = "$(scoop prefix clashn-core)/clashN.exe"
        $ScheduledTaskAction = New-ScheduledTaskAction -Execute "$Program"
        # $SystemSID = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::LocalSystemSid, $null);
        # $SystemAccountName = $SystemSID.Translate([System.Security.Principal.NTAccount]).Value.ToString();
        # $ScheduledTaskPrincipal = New-ScheduledTaskPrincipal -UserId $SystemAccountName -RunLevel Highest
        $UserId = "$env:USERDOMAIN\$env:USERNAME"
        $ScheduledTaskPrincipal = New-ScheduledTaskPrincipal -UserId $UserId -RunLevel Highest
        $ScheduledTaskTrigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
        $ScheduledTaskSettings = New-ScheduledTaskSettingsSet
        $ScheduledTaskObject = New-ScheduledTask -Action $ScheduledTaskAction -Principal $ScheduledTaskPrincipal -Trigger $ScheduledTaskTrigger -Settings $ScheduledTaskSettings -Description $ScheduledTaskDescription

        Register-ScheduledTask -TaskName $ScheduledTaskName -InputObject $ScheduledTaskObject | Out-Null

        if ((Get-ScheduledTask -TaskName $ScheduledTaskName).State -eq 'Ready') {
            Write-Host "'clashn-core' scheduled task created successfully." -ForegroundColor Green
        }

        Start-ScheduledTask -TaskName $ScheduledTaskName
    } catch {
        Write-Host "'clashn-core' scheduled task create failed." -ForegroundColor Red
    }
} else {
    Write-Host "'clashn-core' scheduled task already exists." -ForegroundColor Yellow
}
