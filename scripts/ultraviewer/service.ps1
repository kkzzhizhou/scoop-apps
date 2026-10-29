# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Error "UltraViewer Service setup requires administrator rights."
    Write-Host "Please run this script as administrator." -ForegroundColor Yellow
    exit 1
}

# Get current directory
$dir = $PSScriptRoot

Write-Host "Setting up UltraViewer Service..." -ForegroundColor Cyan
Write-Host "Directory: $dir"

# Create the service
$servicePath = "$dir\UltraViewer_Service.exe"
if (-not (Test-Path $servicePath)) {
    Write-Error "UltraViewer_Service.exe not found at: $servicePath"
    exit 1
}

# Remove existing service if it exists
$existingService = Get-Service -Name "UltraViewer Service" -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "Removing existing UltraViewer Service..."
    Stop-Service -Name "UltraViewer Service" -Force -ErrorAction SilentlyContinue
    sc.exe delete "UltraViewer Service" | Out-Null
    Start-Sleep -Seconds 2
}

# Create new service
Write-Host "Creating UltraViewer Service..."
try {
    New-Service -Name "UltraViewer Service" -BinaryPathName "$servicePath" -DisplayName "UltraViewer Service" -ErrorAction Stop | Out-Null
    Write-Host "Service created successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to create service: $_"
    exit 1
}

# Start the service
Write-Host "Starting UltraViewer Service..."
try {
    Start-Service -Name "UltraViewer Service" -ErrorAction Stop
    Write-Host "Service started successfully." -ForegroundColor Green
} catch {
    Write-Warning "Failed to start service: $_"
    Write-Host "You can manually start the service later." -ForegroundColor Yellow
}

Write-Host "`nUltraViewer Service setup completed successfully!" -ForegroundColor Green
