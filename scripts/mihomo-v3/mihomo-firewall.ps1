<#
.SYNOPSIS
    Creates or removes the Windows Firewall rules for the mihomo core.

.DESCRIPTION
    Adds the inbound TCP+UDP rules the core needs for its listeners, and
    optionally the outbound rule some TUN setups ask for. Both rules point at the
    mihomo.exe you pass in and carry the display names 'Mihomo-In' / 'Mihomo-Out'
    (change them with -RuleName).

    The changes need administrative rights, so unless the caller is already
    elevated the script re-runs itself through UAC (RunAs). Add -NoElevate to skip
    that step, e.g. when testing from an already elevated shell.

    The script is standalone: run it directly, or let it be driven from a manifest
    hook, e.g. the mihomo-v3 manifest uses

        & "$scoopdir\buckets\scoop-private\scripts\mihomo-v3\mihomo-firewall.ps1" -Action Enable  -ProgramPath "$dir\mihomo.exe"
        & "$scoopdir\buckets\scoop-private\scripts\mihomo-v3\mihomo-firewall.ps1" -Action Disable -ProgramPath "$dir\mihomo.exe"

    When it elevates itself, the script is re-read from disk, so it searches
    <scoopdir>\buckets\<bucket>\scripts\mihomo-v3\ before giving up; a manifest
    hook is not required for that lookup.

.PARAMETER Action
    Enable creates the rules, Disable removes them.

.PARAMETER ProgramPath
    Path of the mihomo.exe the rules point at. Disable only uses it for the log
    message; the rules themselves are looked up by name.

.PARAMETER ProgramPathBase64
    Same as -ProgramPath, Base64 (UTF-8) encoded. Used by the elevation round trip
    so that paths containing quotes survive intact.

.PARAMETER RuleName
    Base display name of the rules. Defaults to 'Mihomo', matching the names the
    previous inline manifest scripts used ('Mihomo-In' / 'Mihomo-Out').

.PARAMETER NoOutbound
    Do not create (and, with -Action Disable, do not remove) the outbound rule.

.PARAMETER NoElevate
    Do not re-run through UAC. The script then fails instead of prompting when the
    current process is not elevated.

.EXAMPLE
    .\mihomo-firewall.ps1 -Action Enable -ProgramPath 'C:\mihomo\mihomo.exe'

    Opens one UAC prompt and creates 'Mihomo-In' (TCP+UDP) and 'Mihomo-Out'.

.EXAMPLE
    .\mihomo-firewall.ps1 -Action Disable

    Opens one UAC prompt and removes the rules. -ProgramPath may be omitted.

.EXAMPLE
    .\mihomo-firewall.ps1 -Action Enable -ProgramPath 'C:\mihomo\mihomo.exe' -WhatIf

    Shows which rules would be reset and created without touching the system and
    without a UAC prompt.
#>
#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('Enable', 'Disable')]
    [string]
    $Action,

    [Parameter()]
    [string]
    $ProgramPath,

    [Parameter()]
    [string]
    $ProgramPathBase64,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]
    $RuleName = 'Mihomo',

    [Parameter()]
    [switch]
    $NoOutbound,

    [Parameter()]
    [switch]
    $NoElevate
)

$ErrorActionPreference = 'Stop'

function Resolve-ProgramPath {
    param(
        [string] $Path,
        [string] $PathBase64
    )

    if ($PathBase64) {
        return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($PathBase64))
    }
    if ($Path) { return $Path }
    return $null
}

function Get-FirewallScriptPath {
    param([string] $AppName)

    # The elevated instance is a fresh powershell.exe, so the script has to find
    # itself again. The hook may not have $bucket (scoop's uninstall flow never
    # sets it), hence the scan of <root>\<bucket>\scripts\<app> instead of
    # trusting a variable. Handles both bucket layouts: scripts inside bucket/ or
    # next to it.
    $fromScriptRoot = Join-Path (Split-Path $PSScriptRoot -Parent) "$AppName\mihomo-firewall.ps1"
    if ($PSScriptRoot -and (Test-Path $fromScriptRoot)) { return $fromScriptRoot }

    $bucketsRoots = @(
        $bucketsdir
        if ($scoopdir) { Join-Path $scoopdir 'buckets' }
        if ($env:SCOOP) { Join-Path $env:SCOOP 'buckets' }
    ) | Where-Object { $_ -and (Test-Path $_) }

    foreach ($root in $bucketsRoots) {
        foreach ($bucketDir in Get-ChildItem $root -Directory -ErrorAction SilentlyContinue) {
            $candidate = Join-Path $bucketDir.FullName "scripts\$AppName\mihomo-firewall.ps1"
            if (Test-Path $candidate) { return $candidate }
        }
    }
    return $null
}

function Test-Elevated {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($identity)).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Invoke-MihomoFirewall {
    param([System.Management.Automation.PSCmdlet] $Cmdlet)

    $inboundRule = "$RuleName-In"
    $outboundRule = "$RuleName-Out"
    $rules = @($inboundRule)
    if (-not $NoOutbound) { $rules += $outboundRule }
    $ruleList = $rules -join "', '"

    # --- elevation ---------------------------------------------------------
    if (-not (Test-Elevated) -and -not $WhatIfPreference) {
        if ($NoElevate) {
            Write-Error 'Administrator rights are required to change firewall rules.'
            exit 1
        }
        if (-not (Get-Command Invoke-ExternalCommand -ErrorAction SilentlyContinue)) {
            $scoopHome = $env:SCOOP_HOME
            if (-not $scoopHome -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
                $scoopHome = scoop prefix scoop | Select-Object -Last 1
            }
            if ($scoopHome -and (Test-Path "$scoopHome\lib\core.ps1")) {
                . "$scoopHome\lib\core.ps1"
            }
        }
        if (-not (Get-Command Invoke-ExternalCommand -ErrorAction SilentlyContinue)) {
            Write-Error 'Invoke-ExternalCommand is unavailable; cannot request elevation.'
            exit 1
        }

        $scriptPath = Get-FirewallScriptPath -AppName 'mihomo-v3'
        if (-not $scriptPath) {
            Write-Error "Cannot locate mihomo-firewall.ps1 under '$PSScriptRoot'."
            exit 1
        }

        # Re-run this file in an elevated shell. The program path travels as
        # Base64 and the whole inner command as -EncodedCommand, so no quoting
        # layer can mangle it. Parameters are read from the function's scope.
        $innerArgs = @("-Action $Action", '-NoElevate')
        if ($resolvedPath) {
            $innerArgs += "-ProgramPathBase64 $([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($resolvedPath)))"
        }
        if ($RuleName -ne 'Mihomo') { $innerArgs += "-RuleName $RuleName" }
        if ($NoOutbound) { $innerArgs += '-NoOutbound' }
        $innerCommand = "& '$scriptPath' $($innerArgs -join ' ')"
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($innerCommand))

        # Activity and ContinueExitCodes double as the caller-visible result: the
        # elevated child may share this console, but it is not guaranteed to.
        $activity = if ($Action -eq 'Enable') {
            "Requesting elevation via UAC to add firewall rules '$ruleList'..."
        } else {
            "Requesting elevation via UAC to remove firewall rules '$ruleList'..."
        }
        $result = if ($Action -eq 'Enable') { 'Firewall rules updated.' } else { 'Firewall rules removed.' }
        # A '+' or ';' inside the hashtable literal gets parsed as an argument,
        # so build the map first and pass the variable.
        $exitMessages = @{ 0 = $result }

        try {
            Invoke-ExternalCommand powershell -ArgumentList @(
                '-NoProfile'
                '-ExecutionPolicy Bypass'
                '-EncodedCommand'
                $encoded
            ) -RunAs -Quiet -Activity $activity -ContinueExitCodes $exitMessages -ErrorAction Stop
        } catch {
            $detail = "$($_.Exception.GetType().FullName): $($_.Exception.Message)"
            Write-Warning "UAC elevation was denied or the elevated run failed; firewall rules were not changed. ($detail)"
            exit 1
        }
        return
    }

    # --- firewall changes --------------------------------------------------
    # Drop then recreate, so the rule always ends up attached to the current
    # $dir\mihomo.exe instead of an older version directory.
    if ($Cmdlet.ShouldProcess("firewall rules '$ruleList'", 'Reset')) {
        foreach ($rule in $rules) {
            Get-NetFirewallRule -DisplayName $rule -ErrorAction SilentlyContinue |
                Remove-NetFirewallRule -ErrorAction SilentlyContinue
        }
    }

    if ($Action -eq 'Disable') {
        if (-not $WhatIfPreference) {
            Write-Host "Removed firewall rules '$ruleList'." -ForegroundColor Cyan
        }
        exit 0
    }

    if ($Cmdlet.ShouldProcess("inbound rule '$inboundRule' (TCP+UDP) for $resolvedPath", 'Create')) {
        New-NetFirewallRule -DisplayName $inboundRule -Direction Inbound -Program $resolvedPath `
            -Action Allow -Profile Any -Protocol TCP -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName $inboundRule -Direction Inbound -Program $resolvedPath `
            -Action Allow -Profile Any -Protocol UDP -ErrorAction SilentlyContinue | Out-Null
    }

    if (-not $NoOutbound -and $Cmdlet.ShouldProcess("outbound rule '$outboundRule' for $resolvedPath", 'Create')) {
        New-NetFirewallRule -DisplayName $outboundRule -Direction Outbound -Program $resolvedPath `
            -Action Allow -Profile Any -ErrorAction SilentlyContinue | Out-Null
    }

    if (-not $WhatIfPreference) {
        Write-Host "Firewall rules '$ruleList' are in place." -ForegroundColor Cyan
    }
}

$resolvedPath = Resolve-ProgramPath -Path $ProgramPath -PathBase64 $ProgramPathBase64
if (-not $resolvedPath -and $Action -eq 'Enable') {
    Write-Error 'A program path is required to create the firewall rules.'
    exit 1
}

# $PSCmdlet only exists in this scope, so hand it to the function for
# ShouldProcess (-WhatIf / -Confirm) to work there as well.
Invoke-MihomoFirewall -Cmdlet $PSCmdlet
