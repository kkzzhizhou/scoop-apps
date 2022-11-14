# Project URL - https://github.com/starise/Scoop-Confetti
# MIT License - Copyright (c) 2020 Andrea Brandi

#Requires -RunAsAdministrator

param (
    [Parameter(Mandatory=$true)][string]$option
)

function Get-EventQueryTrigger($query) {
    $CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
    $eventTrigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
    $eventTrigger.Subscription = $query
    $eventTrigger.Enabled = $true

    return $eventTrigger
}

function Register-DisplayCalSchTasks($query) {
    # Set custom event query
    $eventQuery =
@"
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Power-Troubleshooter'] and (Level=4 or Level=0) and (EventID=1)]]</Select>
  </Query>
</QueryList>
"@
    # Create array of triggers
    $triggers = @()
    $triggers += New-ScheduledTaskTrigger -AtLogOn
    $triggers += Get-EventQueryTrigger($eventQuery)

    # Generate scheduled task settings
    $settings = @{
        Name        = "DisplayCAL Profile Loader Launcher"
        Description = "This task launches the profile loader with the applicable privileges for logged in users"
        Principal   = New-ScheduledTaskPrincipal -GroupId 'Interactive' -RunLevel 'Limited'
        Action      = New-ScheduledTaskAction -Execute "$PSScriptRoot\DisplayCAL-apply-profiles-launcher.exe"
        Triggers    = $triggers
    }

    # Register the scheduled task
    Register-ScheduledTask `
        -TaskName $settings.Name `
        -Description $settings.Description `
        -Principal $settings.Principal `
        -Action $settings.Action `
        -Trigger $settings.Triggers `
        -ErrorAction 'SilentlyContinue'
}

function DisplayCalSchTasks {
    switch ($option) {
        Register {
            Register-DisplayCalSchTasks | Out-Null
        }
        Unregister {
            Unregister-ScheduledTask -TaskName "DisplayCAL Profile Loader Launcher" -Confirm:$false -ErrorAction 'SilentlyContinue'
        }
        default {
            Write-Host "DisplayCalSchTasks: '$option' isn't a valid option."
        }
    }
}

DisplayCalSchTasks $option
