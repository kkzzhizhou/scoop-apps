# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Error "Surfshark Service setup requires administrator rights."
    Write-Host "Please run this script as administrator." -ForegroundColor Yellow
    exit 1
}

# Get current directory
$dir = $PSScriptRoot

Write-Host "Setting up Surfshark Service..." -ForegroundColor Cyan
Write-Host "Directory: $dir"

# Create the service
$servicePath = "$dir\Surfshark.Service.exe"
if (-not (Test-Path $servicePath)) {
    Write-Error "Surfshark.Service.exe not found at: $servicePath"
    exit 1
}

# Remove existing service if it exists
$existingService = Get-Service -Name "Surfshark Service" -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "Removing existing Surfshark Service..."
    Stop-Service -Name "Surfshark Service" -Force -ErrorAction SilentlyContinue
    sc.exe delete "Surfshark Service" | Out-Null
    Start-Sleep -Seconds 2
}

# Create new service
Write-Host "Creating Surfshark Service..."
try {
    New-Service -Name "Surfshark Service" -BinaryPathName "$servicePath" -DisplayName "Surfshark Service" -ErrorAction Stop | Out-Null
    Write-Host "Service created successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to create service: $_"
    exit 1
}

# Start the service
Write-Host "Starting Surfshark Service..."
try {
    Start-Service -Name "Surfshark Service" -ErrorAction Stop
    Write-Host "Service started successfully." -ForegroundColor Green
} catch {
    Write-Warning "Failed to start service: $_"
    Write-Host "You can manually start the service later." -ForegroundColor Yellow
}

Write-Host "`nSurfshark Service setup completed successfully!" -ForegroundColor Green
