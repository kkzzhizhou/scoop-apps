[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('start', 'stop', 'restart', 'status', 'enable', 'disable', 'log', 'help')]
    [string]$Action = 'status',

    [Parameter()]
    [switch]$Tail
)

$ServiceName = 'mihomo-shawl'

function Test-Admin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Show-Help {
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor DarkGray
    Write-Host "  mihomo-helper [<Action>] [-Tail]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available Actions:" -ForegroundColor DarkGray
    Write-Host "  status   " -NoNewline; Write-Host "- Show service registration and status (Default)" -ForegroundColor Gray
    Write-Host "  start    " -NoNewline; Write-Host "- Start the service (Requires Admin)" -ForegroundColor Gray
    Write-Host "  stop     " -NoNewline; Write-Host "- Stop the service (Requires Admin)" -ForegroundColor Gray
    Write-Host "  restart  " -NoNewline; Write-Host "- Restart the service (Requires Admin)" -ForegroundColor Gray
    Write-Host "  enable   " -NoNewline; Write-Host "- Set service to start automatically on boot (Requires Admin)" -ForegroundColor Gray
    Write-Host "  disable  " -NoNewline; Write-Host "- Set service to manual start (Requires Admin)" -ForegroundColor Gray
    Write-Host "  log      " -NoNewline; Write-Host "- View log files" -ForegroundColor Gray
    Write-Host "  help     " -NoNewline; Write-Host "- Show this help message" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Options:" -ForegroundColor DarkGray
    Write-Host "  -Tail    " -NoNewline; Write-Host "- Tail the log dynamically (only works with 'log' action)" -ForegroundColor Gray
    Write-Host ""
}

# 需要管理员权限的动作队列
$ElevatedActions = @('start', 'stop', 'restart', 'enable', 'disable')

# 自提权机制（Self-Elevation）
if ($Action -in $ElevatedActions -and -not (Test-Admin)) {
    Write-Host "Action '$Action' requires Administrator privileges. Requesting UAC elevation..." -ForegroundColor Yellow
    try {
        $arguments = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"", $Action)
        if ($Tail) { $arguments += "-Tail" }
        $psExe = (Get-Process -Id $PID).Path
        Start-Process $psExe -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -Wait -ErrorAction Stop
    } catch {
        Write-Error "UAC elevation denied or failed."
    }
    return
}

switch ($Action) {
    'status' {
        if ($PSBoundParameters.Count -eq 0) {
            Show-Help
            Write-Host "-----------------------" -ForegroundColor DarkGray
            Write-Host "Current Service Status:" -ForegroundColor DarkGray
            Write-Host "-----------------------" -ForegroundColor DarkGray
        }

        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if (!$service) {
            Write-Host "Service '$ServiceName' is not registered." -ForegroundColor Red
            return
        }
        $statusColor = if ($service.Status -eq 'Running') { 'Green' } else { 'Yellow' }
        Write-Host "Service Name: " -NoNewline; Write-Host $service.Name -ForegroundColor Cyan
        Write-Host "Status:       " -NoNewline; Write-Host $service.Status -ForegroundColor $statusColor
        Write-Host "Start Type:   " -NoNewline; Write-Host $service.StartType -ForegroundColor Cyan
    }
    'start' {
        Start-Service -Name $ServiceName -ErrorAction Stop
    }
    'stop' {
        Stop-Service -Name $ServiceName -Force -ErrorAction Stop
    }
    'restart' {
        Restart-Service -Name $ServiceName -Force -ErrorAction Stop
    }
    'enable' {
        sc.exe config $ServiceName start= auto | Out-Null
        Write-Host "Service configured to start automatically on boot." -ForegroundColor Green
    }
    'disable' {
        sc.exe config $ServiceName start= demand | Out-Null
        Write-Host "Service configured to manual start." -ForegroundColor Yellow
    }
    'log' {
        $logDir = Join-Path $PSScriptRoot "logs"
        $logPath = $null

        if (Test-Path $logDir) {
            $latestLog = Get-ChildItem -Path $logDir -Filter "*mihomo-shawl*.log" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
            if ($latestLog) {
                $logPath = $latestLog.FullName
            }
        }

        if (!$logPath -or !(Test-Path $logPath)) {
            Write-Host "No log file found under logs directory. Ensure the service has been started at least once." -ForegroundColor Red
            return
        }

        if ($Tail) {
            Get-Content -Path $logPath -Tail 50 -Wait
        } else {
            Get-Content -Path $logPath -Tail 100
        }
    }
    'help' {
        Show-Help
    }
}
