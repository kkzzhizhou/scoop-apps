# Installation lifecycle verifier for Scoop bucket tools.
# Tests: install -> version check -> smoke test -> uninstall -> clean check.
#
# Usage:
#   .\verify-installation.ps1 [-Json] [-SkipUninstall] [Tool...]
#   Omit Tool args to test all manifests in the bucket.

param(
    [switch]$Json,
    [switch]$SkipUninstall,
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$Tools
)

$ErrorActionPreference = "Continue"
$BucketName = "dicklesworthstone"
$BucketUrl = "https://github.com/Dicklesworthstone/scoop-bucket"
$LogDir = $(if ($env:LOG_DIR) { $env:LOG_DIR } else { "$env:TEMP\verify-install" })
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$Total = 0
$Passed = 0
$Failed = 0
$Skipped = 0
$Results = @()

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Write-Log {
    param(
        [string]$Level,
        [string]$Message,
        [hashtable]$Extra = @{}
    )
    $ts = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    if ($Json) {
        $obj = @{ timestamp = $ts; level = $Level; message = $Message }
        foreach ($k in $Extra.Keys) { $obj[$k] = $Extra[$k] }
        $obj | ConvertTo-Json -Compress | Write-Host
    }
    else {
        $parts = "[$ts] $($Level.PadRight(5)) $Message"
        foreach ($k in $Extra.Keys) { $parts += " $k=$($Extra[$k])" }
        Write-Host $parts
    }
}

function Test-SmokeTest {
    param([string]$Tool)
    try {
        $output = & $Tool --help 2>&1 | Out-String
        return @{ Output = $output; ExitCode = $LASTEXITCODE }
    }
    catch {
        return @{ Output = $_.Exception.Message; ExitCode = 1 }
    }
}

function Verify-Tool {
    param([string]$Tool)
    $script:Total++
    $startTime = Get-Date
    $phasesTotal = 0
    $phasesPassed = 0

    Write-Log "INFO" "Starting verification" @{ tool = $Tool; phase = "start" }

    # Phase 1: Manifest exists
    $phasesTotal++
    Write-Log "INFO" "Checking manifest" @{ tool = $Tool; phase = "manifest_check" }
    $manifest = "$PSScriptRoot\..\$Tool.json"
    if (-not (Test-Path $manifest)) {
        Write-Log "ERROR" "Manifest not found" @{ tool = $Tool; error_code = "MANIFEST_NOT_FOUND" }
        $script:Failed++
        $script:Results += @{ tool = $Tool; result = "fail"; phase = "manifest_check" }
        return
    }
    $phasesPassed++

    # Phase 2: Install
    $phasesTotal++
    Write-Log "INFO" "Installing" @{ tool = $Tool; phase = "install" }
    try {
        $installOutput = scoop install "${BucketName}/$Tool" 2>&1 | Out-String
        if ($LASTEXITCODE -ne 0 -and $installOutput -notmatch "already installed") {
            Write-Log "ERROR" "Installation failed" @{ tool = $Tool; exit_code = "$LASTEXITCODE"; output = $installOutput.Substring(0, [Math]::Min(500, $installOutput.Length)) }
            $script:Failed++
            $script:Results += @{ tool = $Tool; result = "fail"; phase = "install" }
            return
        }
    }
    catch {
        Write-Log "ERROR" "Installation exception" @{ tool = $Tool; error = $_.Exception.Message }
        $script:Failed++
        $script:Results += @{ tool = $Tool; result = "fail"; phase = "install" }
        return
    }
    $phasesPassed++

    # Phase 3: Version check
    $phasesTotal++
    Write-Log "INFO" "Checking version" @{ tool = $Tool; phase = "version_check" }
    try {
        $versionOutput = & $Tool --version 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0) {
            $version = [regex]::Match($versionOutput, '\d+\.\d+\.\d+').Value
            Write-Log "INFO" "Version OK" @{ tool = $Tool; version = $(if ($version) { $version } else { "unknown" }); phase = "version_check" }
            $phasesPassed++
        }
        else {
            Write-Log "WARN" "Version command failed (non-fatal)" @{ tool = $Tool; exit_code = "$LASTEXITCODE" }
        }
    }
    catch {
        Write-Log "WARN" "Version command exception (non-fatal)" @{ tool = $Tool; error = $_.Exception.Message }
    }

    # Phase 4: Smoke test
    $phasesTotal++
    Write-Log "INFO" "Running smoke test" @{ tool = $Tool; phase = "smoke_test" }
    $smoke = Test-SmokeTest -Tool $Tool
    if ($smoke.ExitCode -ne 0) {
        Write-Log "WARN" "Smoke test returned non-zero (non-fatal)" @{ tool = $Tool; exit_code = "$($smoke.ExitCode)" }
    }
    else {
        Write-Log "INFO" "Smoke test passed" @{ tool = $Tool; phase = "smoke_test" }
        $phasesPassed++
    }

    # Phase 5: Uninstall
    if (-not $SkipUninstall) {
        $phasesTotal++
        Write-Log "INFO" "Uninstalling" @{ tool = $Tool; phase = "uninstall" }
        try {
            $uninstallOutput = scoop uninstall $Tool 2>&1 | Out-String
            if ($LASTEXITCODE -ne 0) {
                Write-Log "ERROR" "Uninstall failed" @{ tool = $Tool; exit_code = "$LASTEXITCODE" }
                $script:Failed++
                $script:Results += @{ tool = $Tool; result = "fail"; phase = "uninstall" }
                return
            }
            $phasesPassed++
        }
        catch {
            Write-Log "ERROR" "Uninstall exception" @{ tool = $Tool; error = $_.Exception.Message }
            $script:Failed++
            $script:Results += @{ tool = $Tool; result = "fail"; phase = "uninstall" }
            return
        }

        # Phase 6: Clean check
        $phasesTotal++
        Write-Log "INFO" "Verifying clean removal" @{ tool = $Tool; phase = "cleanup_check" }
        if (Get-Command $Tool -ErrorAction SilentlyContinue) {
            Write-Log "ERROR" "Tool still in PATH after uninstall" @{ tool = $Tool; phase = "cleanup_check" }
            $script:Failed++
            $script:Results += @{ tool = $Tool; result = "fail"; phase = "cleanup_check" }
            return
        }
        $phasesPassed++
    }

    $duration = ((Get-Date) - $startTime).TotalSeconds
    Write-Log "INFO" "Verification complete" @{ tool = $Tool; result = "pass"; phases = "$phasesPassed/$phasesTotal"; duration_seconds = [Math]::Round($duration, 1).ToString() }
    $script:Passed++
    $script:Results += @{ tool = $Tool; result = "pass"; phases_passed = $phasesPassed; phases_total = $phasesTotal; duration_seconds = [Math]::Round($duration, 1) }
}

# Determine tool list
if (-not $Tools -or $Tools.Count -eq 0) {
    $Tools = Get-ChildItem "$PSScriptRoot\.." -Filter "*.json" |
        Where-Object { $_.Name -ne "LICENSE" } |
        ForEach-Object { $_.BaseName }
}

if ($Tools.Count -eq 0) {
    Write-Log "ERROR" "No tools to verify"
    exit 4
}

Write-Log "INFO" "Starting installation verification" @{ tool_count = "$($Tools.Count)"; platform = "Windows"; skip_uninstall = "$SkipUninstall" }

# Ensure bucket is available
$buckets = scoop bucket list 2>&1 | Out-String
if ($buckets -notmatch $BucketName) {
    Write-Log "INFO" "Adding bucket" @{ bucket = $BucketName }
    scoop bucket add $BucketName $BucketUrl 2>&1 | Out-Null
}

foreach ($tool in $Tools) {
    Verify-Tool -Tool $tool
}

# Summary
Write-Log "INFO" "Suite complete" @{ total = "$Total"; passed = "$Passed"; failed = "$Failed"; skipped = "$Skipped" }

# Write JSON results file
$resultsObj = @{
    generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    platform     = "Windows"
    total        = $Total
    passed       = $Passed
    failed       = $Failed
    skipped      = $Skipped
    tools        = $Results
}
$resultsPath = Join-Path $LogDir "verify-results-$Timestamp.json"
$resultsObj | ConvertTo-Json -Depth 4 | Set-Content $resultsPath
Write-Log "INFO" "Results written" @{ path = $resultsPath }

exit $Failed
