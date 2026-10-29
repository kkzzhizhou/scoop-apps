# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "NextDNS Service setup requires administrator rights."
    Write-Host "Please run this script as administrator." -ForegroundColor Yellow
    exit 1
}

# Get current directory
$dir = $PSScriptRoot
Write-Host "Setting up NextDNS Service..." -ForegroundColor Cyan
Write-Host "Directory: $dir"

# Check for service executable
$servicePath = "$dir\NextDNSService.exe"
if (-not (Test-Path $servicePath)) {
    Write-Error "NextDNSService.exe not found at: $servicePath"
    exit 1
}

# Check for driver files
$driverFolder = "$dir\Driver"
$driverInf = "$driverFolder\NextDNSEngine.inf"
$driverCat = "$driverFolder\NextDNSEngine.cat"
$driverSys = "$driverFolder\NextDNSEngine.sys"

Write-Host "`nChecking driver files..." -ForegroundColor Cyan
if (-not (Test-Path $driverInf)) {
    Write-Error "NextDNSEngine.inf not found at: $driverInf"
    exit 1
}
if (-not (Test-Path $driverCat)) {
    Write-Error "NextDNSEngine.cat not found at: $driverCat"
    exit 1
}
if (-not (Test-Path $driverSys)) {
    Write-Error "NextDNSEngine.sys not found at: $driverSys"
    exit 1
}
Write-Host "All driver files found." -ForegroundColor Green

# Install the driver
Write-Host "`nInstalling NextDNS Driver..." -ForegroundColor Cyan
try {
    $result = pnputil.exe /add-driver "$driverInf" /install 2>&1
    Write-Host $result

    # Exit codes: 0 = success, 259 = already exists (also success)
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 259) {
        if ($LASTEXITCODE -eq 259) {
            Write-Host "Driver already installed in system." -ForegroundColor Green
        } else {
            Write-Host "Driver installed successfully." -ForegroundColor Green
        }
    } else {
        Write-Error "Failed to install driver. Exit code: $LASTEXITCODE"
        exit 1
    }
} catch {
    Write-Error "Failed to install driver: $_"
    exit 1
}

# Copy driver to system32\drivers if not already there
Write-Host "`nCopying driver to system directory..." -ForegroundColor Cyan
$systemDriverPath = "$env:SystemRoot\System32\drivers\NextDNSEngine.sys"
try {
    if (-not (Test-Path $systemDriverPath)) {
        Copy-Item -Path $driverSys -Destination $systemDriverPath -Force
        Write-Host "Driver copied to: $systemDriverPath" -ForegroundColor Green
    } else {
        Write-Host "Driver already exists in system directory." -ForegroundColor Green
    }
} catch {
    Write-Warning "Failed to copy driver to system directory: $_"
}

# Create/Start the driver service
Write-Host "`nConfiguring NextDNS Driver Service..." -ForegroundColor Cyan
$driverService = Get-Service -Name "NextDNSEngine" -ErrorAction SilentlyContinue
if (-not $driverService) {
    Write-Host "Creating NextDNS Driver Service..."
    try {
        sc.exe create NextDNSEngine type=kernel start=demand binPath="$systemDriverPath" | Out-Null
        Write-Host "Driver service created successfully." -ForegroundColor Green
    } catch {
        Write-Warning "Failed to create driver service: $_"
    }
} else {
    Write-Host "Driver service already exists." -ForegroundColor Green
}

# Start the driver
Write-Host "Starting NextDNS Driver..."
try {
    $startResult = sc.exe start NextDNSEngine 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Driver started successfully." -ForegroundColor Green
    } elseif ($LASTEXITCODE -eq 1056) {
        Write-Host "Driver is already running." -ForegroundColor Green
    } else {
        Write-Host $startResult
        Write-Warning "Driver start returned code: $LASTEXITCODE"
        Write-Host "Note: Driver may start automatically when needed by the service." -ForegroundColor Yellow
    }
} catch {
    Write-Warning "Note: Driver may start automatically when needed by the service."
}

# Remove existing service if it exists
$existingService = Get-Service -Name "NextDNSService" -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "`nRemoving existing NextDNS Service..."
    Stop-Service -Name "NextDNSService" -Force -ErrorAction SilentlyContinue
    sc.exe delete "NextDNSService" | Out-Null
    Start-Sleep -Seconds 2
}

# Create new service
Write-Host "Creating NextDNS Service..."
try {
    New-Service -Name "NextDNSService" -BinaryPathName "$servicePath" -DisplayName "NextDNS Service" -ErrorAction Stop | Out-Null
    Write-Host "Service created successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to create service: $_"
    exit 1
}

# Start the service
Write-Host "Starting NextDNS Service..."
try {
    Start-Service -Name "NextDNSService" -ErrorAction Stop
    Write-Host "Service started successfully." -ForegroundColor Green
} catch {
    Write-Warning "Failed to start service: $_"
    Write-Host "You can manually start the service later." -ForegroundColor Yellow
}

Write-Host "`nNextDNS Service and Driver setup completed successfully!" -ForegroundColor Green
Write-Host "`nYou can now run the NextDNS GUI application." -ForegroundColor Cyan
