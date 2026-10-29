# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Error "ProtonVPN Service setup requires administrator rights."
    Write-Host "Please run this script as administrator." -ForegroundColor Yellow
    exit 1
}

$dir = $PSScriptRoot
$servicePath   = "$dir\version\ProtonVPNService.exe"
$wgServicePath = "$dir\version\ProtonVPN.WireGuardService.exe"
$wgConfPath    = "$dir\version\ServiceData\WireGuard\ProtonVPN.conf"

Write-Host "Setting up ProtonVPN Services..." -ForegroundColor Cyan
Write-Host "Main service exe : $servicePath"
Write-Host "WireGuard service: $wgServicePath"
Write-Host "WireGuard config : $wgConfPath"

# ---------------------------------------------------------------------------
# Validate paths
# ---------------------------------------------------------------------------
if (-not (Test-Path $servicePath)) {
    Write-Error "ProtonVPNService.exe not found at: $servicePath"
    exit 1
}

if (-not (Test-Path $wgServicePath)) {
    Write-Error "ProtonVPN.WireGuardService.exe not found at: $wgServicePath"
    exit 1
}

if (-not (Test-Path $wgConfPath)) {
    Write-Error "WireGuard config not found at: $wgConfPath"
    exit 1
}

# ---------------------------------------------------------------------------
# Helper: remove a service cleanly if it already exists
# ---------------------------------------------------------------------------
function Remove-ServiceIfExists {
    param([string]$Name)
    $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($svc) {
        Write-Host "Removing existing '$Name' service..."
        Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
        sc.exe delete $Name | Out-Null
        Start-Sleep -Seconds 2
    }
}

# ---------------------------------------------------------------------------
# 1. ProtonVPN Service (main)
# ---------------------------------------------------------------------------
Remove-ServiceIfExists -Name "ProtonVPN Service"

Write-Host "Creating ProtonVPN Service..."
try {
    New-Service -Name "ProtonVPN Service" `
        -BinaryPathName "`"$servicePath`"" `
        -StartupType Manual `
        -DependsOn 'Tcpip' `
        -DisplayName "ProtonVPN Service" `
        -ErrorAction Stop | Out-Null
    Write-Host "ProtonVPN Service created successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to create ProtonVPN Service: $_"
    exit 1
}

# ---------------------------------------------------------------------------
# 2. ProtonVPN WireGuard Service
# ---------------------------------------------------------------------------
Remove-ServiceIfExists -Name "ProtonVPN WireGuard"

Write-Host "Creating ProtonVPN WireGuard service..."
try {
    $wgBinaryPath = "`"$wgServicePath`" `"$wgConfPath`" udp"

    New-Service -Name "ProtonVPN WireGuard" `
        -BinaryPathName $wgBinaryPath `
        -StartupType Manual `
        -DependsOn @('Nsi', 'Tcpip') `
        -DisplayName "ProtonVPN WireGuard" `
        -ErrorAction Stop | Out-Null
    Write-Host "ProtonVPN WireGuard service created successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to create ProtonVPN WireGuard service: $_"
    exit 1
}

Write-Host "`nProtonVPN Service setup completed successfully!" -ForegroundColor Green
Write-Host "You can now start the ProtonVPN application." -ForegroundColor Cyan
