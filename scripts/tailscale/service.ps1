# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Error "Tailscale service setup requires administrator rights."
    Write-Host "Please run this script as administrator." -ForegroundColor Yellow
    exit 1
}

# Get current directory
$dir = $PSScriptRoot

Write-Host "Setting up Tailscale Service..." -ForegroundColor Cyan
Write-Host "Directory: $dir"

# Create the service
$servicePath = "$dir\tailscaled.exe"
if (-not (Test-Path $servicePath)) {
    Write-Error "tailscaled.exe not found at: $servicePath"
    exit 1
}

# Remove existing service if it exists
$existingService = Get-Service -Name "Tailscale" -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "Removing existing Tailscale Service..."
    Stop-Service -Name "Tailscale" -Force -ErrorAction SilentlyContinue
    sc.exe delete "Tailscale" | Out-Null
    Start-Sleep -Seconds 2
}

# Create new service
Write-Host "Creating Tailscale Service..."
try {
    $dependencies = @('Dnscache', 'iphlpsvc', 'netprofm', 'WinHttpAutoProxySvc')
    New-Service -Name "Tailscale" `
                -BinaryPathName "$servicePath" `
                -DependsOn $dependencies `
                -DisplayName "Tailscale" `
                -ErrorAction Stop | Out-Null
    Write-Host "Service created successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to create service: $_"
    exit 1
}

# Start the service
Write-Host "Starting Tailscale Service..."
try {
    Start-Service -Name "Tailscale" -ErrorAction Stop
    Write-Host "Service started successfully." -ForegroundColor Green
} catch {
    Write-Warning "Failed to start service: $_"
    Write-Host "You can manually start the service later." -ForegroundColor Yellow
}

Write-Host "`nTailscale Service setup completed successfully!" -ForegroundColor Green
