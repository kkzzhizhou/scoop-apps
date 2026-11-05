<#
.SYNOPSIS
    Core Script and Function Library.
.DESCRIPTION
    Copyright (C) 2026 hu3rror. Licensed under the MIT License (see LICENSE in the repository root).
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('start', 'stop', 'restart', 'status', 'enable', 'disable', 'repair', 'install', 'log', 'edit', 'reload', 'help')]
    [string]$Action = 'status',

    [Parameter()]
    [switch]$Tail
)

$ServiceName = 'mihomo-shawl'
$script:EditorStdOutLog = Join-Path $env:TEMP 'mihomo-helper-editor-stdout.log'
$script:EditorStdErrLog = Join-Path $env:TEMP 'mihomo-helper-editor-stderr.log'

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
    Write-Host "  start    " -NoNewline; Write-Host "- Start the service (Auto-recovers service if missing) (Requires Admin)" -ForegroundColor Gray
    Write-Host "  stop     " -NoNewline; Write-Host "- Stop the service (Requires Admin)" -ForegroundColor Gray
    Write-Host "  restart  " -NoNewline; Write-Host "- Restart the service (Auto-recovers service if missing) (Requires Admin)" -ForegroundColor Gray
    Write-Host "  enable   " -NoNewline; Write-Host "- Set service to start automatically on boot (Requires Admin)" -ForegroundColor Gray
    Write-Host "  disable  " -NoNewline; Write-Host "- Set service to manual start (Requires Admin)" -ForegroundColor Gray
    Write-Host "  repair   " -NoNewline; Write-Host "- Re-register service and restore firewall rules (e.g. after OS upgrade) (Requires Admin)" -ForegroundColor Gray
    Write-Host "  log      " -NoNewline; Write-Host "- View log files" -ForegroundColor Gray
    Write-Host "  edit     " -NoNewline; Write-Host "- Open config.yaml with the best available editor" -ForegroundColor Gray
    Write-Host "  reload   " -NoNewline; Write-Host "- Reload config.yaml via mihomo's RESTful API (no restart needed)" -ForegroundColor Gray
    Write-Host "  help     " -NoNewline; Write-Host "- Show this help message" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Options:" -ForegroundColor DarkGray
    Write-Host "  -Tail    " -NoNewline; Write-Host "- Tail the log dynamically (only works with 'log' action)" -ForegroundColor Gray
    Write-Host ""
}

# Windows Firewall kernel rule matching requires the real physical executable path.
function Get-PhysicalDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        $item = Get-Item -LiteralPath $Path -ErrorAction Stop
        if ($item.LinkType -eq 'Junction' -and $item.Target) {
            $target = if ($item.Target -is [array] -or $item.Target -is [System.Collections.IList]) {
                $item.Target[0]
            } else {
                [string]$item.Target
            }
            if ($target -and (Test-Path $target)) {
                return $target
            }
        }
    } catch { }

    return $Path
}

function Install-MihomoServiceRegistration {
    param(
        [switch]$StartAfterInstall
    )

    $dir = $PSScriptRoot
    $realDir = Get-PhysicalDirectory -Path $dir
    $servicePath = Join-Path $dir 'mihomo-service.exe'
    $mihomoExe = Join-Path $dir 'mihomo.exe'
    $realMihomoExe = Join-Path $realDir 'mihomo.exe'
    $logDir = Join-Path $dir 'logs'

    if (!(Test-Path $servicePath) -or !(Test-Path $mihomoExe)) {
        Write-Host "Executable files ('mihomo-service.exe' or 'mihomo.exe') not found in '$dir'." -ForegroundColor Red
        return $false
    }

    if (!(Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    $argsList = @(
        'add',
        '--name', $ServiceName,
        '--cwd', "$dir",
        '--log-dir', "$logDir",
        '--log-rotate', 'bytes=10485760',
        '--log-retain', '8',
        '--stop-timeout', '5000',
        '--',
        "$mihomoExe",
        '-d', '.',
        '-f', 'config/config.yaml'
    )

    Write-Host "Registering Windows service '$ServiceName' via Shawl..." -ForegroundColor Cyan
    sc.exe delete $ServiceName 2>$null | Out-Null
    & "$servicePath" $argsList | Out-Null
    sc.exe config $ServiceName start= auto | Out-Null

    Write-Host "Configuring Windows firewall rules for '$realMihomoExe'..." -ForegroundColor Cyan
    Remove-NetFirewallRule -DisplayName 'Mihomo-In-TCP', 'Mihomo-In-UDP' -ErrorAction SilentlyContinue | Out-Null
    New-NetFirewallRule -DisplayName 'Mihomo-In-TCP' -Direction Inbound -Program $realMihomoExe -Action Allow -Profile Any -Protocol TCP -ErrorAction SilentlyContinue | Out-Null
    New-NetFirewallRule -DisplayName 'Mihomo-In-UDP' -Direction Inbound -Program $realMihomoExe -Action Allow -Profile Any -Protocol UDP -ErrorAction SilentlyContinue | Out-Null

    Write-Host "Mihomo Windows service registered and firewall rules configured successfully." -ForegroundColor Green

    if ($StartAfterInstall) {
        $configPath = Join-Path $dir 'config\config.yaml'
        $hasConfig = (Test-Path $configPath) -and ((Get-Item $configPath).Length -gt 0)
        if ($hasConfig) {
            Start-Service -Name $ServiceName -ErrorAction SilentlyContinue
            Write-Host "Service '$ServiceName' started." -ForegroundColor Green
        } else {
            Write-Host "No config content found in '$configPath' - service registered but NOT started." -ForegroundColor Yellow
            Write-Host "Please edit config.yaml, then run 'mihomo-helper start'." -ForegroundColor Yellow
        }
    }
    return $true
}

function Get-FileAssociationCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Extension
    )

    try {
        $userChoiceKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice"
        if (!(Test-Path -Path $userChoiceKeyPath)) {
            return $null
        }

        $progId = (Get-ItemProperty -Path $userChoiceKeyPath -ErrorAction Stop).ProgId
        if ([string]::IsNullOrWhiteSpace($progId)) {
            return $null
        }

        $commandKeyPath = "Registry::HKEY_CLASSES_ROOT\$progId\shell\open\command"
        if (!(Test-Path -Path $commandKeyPath)) {
            return $null
        }

        $commandKey = Get-Item -Path $commandKeyPath -ErrorAction Stop
        $command = $commandKey.GetValue('')
        if ([string]::IsNullOrWhiteSpace($command)) {
            return $null
        }

        return $command
    } catch {
        return $null
    }
}

function Invoke-AssociatedEditor {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandTemplate,
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $CommandTemplate = [Environment]::ExpandEnvironmentVariables($CommandTemplate)

    $exe = $null
    $argTemplate = ''

    if ($CommandTemplate -match '^\s*"([^"]+)"(.*)$') {
        $exe = $Matches[1]
        $argTemplate = $Matches[2]
    } elseif ($CommandTemplate -match '^\s*(\S+)(.*)$') {
        $exe = $Matches[1]
        $argTemplate = $Matches[2]
    } else {
        return $false
    }

    if (!(Test-Path -Path $exe -PathType Leaf)) {
        return $false
    }

    if ($argTemplate -match '%1') {
        $argString = $argTemplate -replace '%1', "`"$FilePath`""
    } elseif ([string]::IsNullOrWhiteSpace($argTemplate)) {
        $argString = "`"$FilePath`""
    } else {
        $argString = "$argTemplate `"$FilePath`""
    }

    try {
        Start-Process -FilePath $exe `
            -ArgumentList $argString `
            -RedirectStandardOutput $script:EditorStdOutLog `
            -RedirectStandardError $script:EditorStdErrLog `
            -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Open-ConfigFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    if (!(Test-Path -Path $FilePath -PathType Leaf)) {
        Write-Host "Config file not found: $FilePath" -ForegroundColor Red
        return $false
    }

    foreach ($ext in @('.yaml', '.yml')) {
        $cmdTemplate = Get-FileAssociationCommand -Extension $ext
        if ($cmdTemplate) {
            if (Invoke-AssociatedEditor -CommandTemplate $cmdTemplate -FilePath $FilePath) {
                Write-Host "Opened with system default ($ext) association." -ForegroundColor Green
                return $true
            }
        }
    }

    $codeCmd = Get-Command 'code' -ErrorAction SilentlyContinue
    if ($codeCmd) {
        try {
            Start-Process -FilePath $codeCmd.Source `
                -ArgumentList "`"$FilePath`"" `
                -RedirectStandardOutput $script:EditorStdOutLog `
                -RedirectStandardError $script:EditorStdErrLog `
                -ErrorAction Stop | Out-Null
            Write-Host "Opened with VS Code." -ForegroundColor Green
            return $true
        } catch {
        }
    }

    $vscodeCandidates = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
        "$env:ProgramFiles\Microsoft VS Code\Code.exe",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
    )
    foreach ($candidate in $vscodeCandidates) {
        if ($candidate -and (Test-Path -Path $candidate -PathType Leaf)) {
            try {
                Start-Process -FilePath $candidate `
                    -ArgumentList "`"$FilePath`"" `
                    -RedirectStandardOutput $script:EditorStdOutLog `
                    -RedirectStandardError $script:EditorStdErrLog `
                    -ErrorAction Stop | Out-Null
                Write-Host "Opened with VS Code." -ForegroundColor Green
                return $true
            } catch {
                continue
            }
        }
    }

    try {
        Start-Process -FilePath 'notepad.exe' -ArgumentList "`"$FilePath`"" -ErrorAction Stop | Out-Null
        Write-Host "Opened with Notepad (fallback)." -ForegroundColor Yellow
        return $true
    } catch {
        Write-Host "Failed to open config file with any known editor." -ForegroundColor Red
        return $false
    }
}

function Get-MihomoConfigValue {
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter(Mandatory = $true)]
        [string[]]$Lines,
        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    if (!$Lines -or $Lines.Count -eq 0) {
        return $null
    }

    $escapedKey = [Regex]::Escape($Key)
    foreach ($line in $Lines) {
        if ($null -eq $line) { continue }
        if ($line -match "^$escapedKey\s*:\s*(?<val>.*)$") {
            $val = $Matches['val'].Trim()

            if ($val -match '^"(?<inner>.*?)"') {
                return $Matches['inner']
            }
            if ($val -match "^'(?<inner>.*?)'") {
                return $Matches['inner']
            }

            # Strip a trailing ' #comment' (YAML requires whitespace before '#')
            $val = ($val -split '\s+#', 2)[0].Trim()

            if ([string]::IsNullOrWhiteSpace($val)) {
                return $null
            }
            return $val
        }
    }
    return $null
}

function Invoke-MihomoReload {
    $configPath = Join-Path $PSScriptRoot 'config\config.yaml'
    if (!(Test-Path -Path $configPath -PathType Leaf)) {
        Write-Host "Config file not found: $configPath" -ForegroundColor Red
        return
    }

    $fileInfo = Get-Item -Path $configPath
    if ($fileInfo.Length -eq 0) {
        Write-Host "Config file '$configPath' is 0 bytes." -ForegroundColor Red
        try {
            $scoopRoot = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
            $persistConfig = Join-Path $scoopRoot 'persist\mihomo-shawl-service\config\config.yaml'
            if (Test-Path -Path $persistConfig -PathType Leaf) {
                $persistSize = (Get-Item -Path $persistConfig).Length
                Write-Host "Persisted copy: $persistConfig ($persistSize bytes)" -ForegroundColor DarkGray
                if ($persistSize -gt 0) {
                    Write-Host "The persisted copy still has content. You can restore it manually, e.g.:" -ForegroundColor Yellow
                    Write-Host "  Copy-Item '$persistConfig' '$configPath' -Force" -ForegroundColor Gray
                }
            }
        } catch {
        }
        return
    }

    $rawContent = $null
    try {
        $rawContent = Get-Content -Path $configPath -Raw -ErrorAction Stop
    } catch {
        Write-Host "Failed to read '$configPath': $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    if ([string]::IsNullOrWhiteSpace($rawContent)) {
        Write-Host "Config file '$configPath' was read but contains no usable content ($($fileInfo.Length) bytes on disk)." -ForegroundColor Red
        Write-Host "The file may be using an encoding PowerShell could not auto-detect. Try re-saving it as UTF-8." -ForegroundColor Yellow
        return
    }

    $lines = @($rawContent -split '\r?\n')

    $controllerAddr = Get-MihomoConfigValue -Lines $lines -Key 'external-controller'
    $secret = Get-MihomoConfigValue -Lines $lines -Key 'secret'

    if ([string]::IsNullOrWhiteSpace($controllerAddr)) {
        Write-Host "'external-controller' is not set (or is empty) in config.yaml." -ForegroundColor Red
        Write-Host "Add e.g. 'external-controller: 127.0.0.1:9090' to config.yaml to enable API-based reload." -ForegroundColor Yellow
        return
    }

    if ($controllerAddr -notmatch '^(?<host>[^:/\\]*):(?<port>\d+)$') {
        Write-Host "Unsupported 'external-controller' format: $controllerAddr" -ForegroundColor Red
        Write-Host "This command only supports plain 'host:port' values (e.g. 127.0.0.1:9090)." -ForegroundColor Yellow
        return
    }

    $ctrlHost = $Matches['host']
    $ctrlPort = $Matches['port']
    if ([string]::IsNullOrWhiteSpace($ctrlHost) -or $ctrlHost -eq '0.0.0.0' -or $ctrlHost -eq '::') {
        $ctrlHost = '127.0.0.1'
    }

    $uri = "http://${ctrlHost}:${ctrlPort}/configs?force=true"

    $headers = @{}
    if (![string]::IsNullOrWhiteSpace($secret)) {
        $headers['Authorization'] = "Bearer $secret"
    }

    # Empty path/payload -> mihomo reloads from the config path it was
    # originally started with (i.e. this same config.yaml).
    $body = '{"path":"","payload":""}'

    Write-Host "Reloading config via mihomo API ($uri)..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri $uri -Method Put -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing -ErrorAction Stop
        if ($response.StatusCode -eq 204) {
            Write-Host 'Config reloaded successfully.' -ForegroundColor Green
        } else {
            Write-Host "Reload request returned unexpected HTTP status: $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            switch ($statusCode) {
                401 { Write-Host "Authentication failed (401). Check the 'secret' value in config.yaml." -ForegroundColor Red }
                400 { Write-Host "Reload rejected (400). The edited config.yaml may contain invalid syntax; check 'mihomo-helper log' for details." -ForegroundColor Red }
                default { Write-Host "Reload request failed with HTTP $statusCode." -ForegroundColor Red }
            }
        } else {
            Write-Host "Failed to reach mihomo API at $uri" -ForegroundColor Red
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Make sure the mihomo service is running ('mihomo-helper start')." -ForegroundColor Yellow
        }
    }
}

$ElevatedActions = @('start', 'stop', 'restart', 'enable', 'disable', 'repair', 'install')

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
            Write-Host "Service '$ServiceName' is not registered (may have been cleared after Windows Update)." -ForegroundColor Red
            Write-Host "Run 'mihomo-helper repair' to re-register the service and restore firewall rules." -ForegroundColor Yellow
            return
        }
        $statusColor = if ($service.Status -eq 'Running') { 'Green' } else { 'Yellow' }
        Write-Host "Service Name: " -NoNewline; Write-Host $service.Name -ForegroundColor Cyan
        Write-Host "Status:       " -NoNewline; Write-Host $service.Status -ForegroundColor $statusColor
        Write-Host "Start Type:   " -NoNewline; Write-Host $service.StartType -ForegroundColor Cyan
    }
    'start' {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if (!$service) {
            Write-Host "Service '$ServiceName' is not registered. Attempting auto-recovery..." -ForegroundColor Yellow
            $installed = Install-MihomoServiceRegistration -StartAfterInstall
            if (!$installed) {
                Write-Host "Failed to automatically register service '$ServiceName'." -ForegroundColor Red
            }
            return
        }
        Start-Service -Name $ServiceName -ErrorAction Stop
        Write-Host "Service '$ServiceName' started." -ForegroundColor Green
    }
    'stop' {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if (!$service) {
            Write-Host "Service '$ServiceName' is not registered." -ForegroundColor Red
            return
        }
        Stop-Service -Name $ServiceName -Force -ErrorAction Stop
        Write-Host "Service '$ServiceName' stopped." -ForegroundColor Yellow
    }
    'restart' {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if (!$service) {
            Write-Host "Service '$ServiceName' is not registered. Attempting auto-recovery..." -ForegroundColor Yellow
            $installed = Install-MihomoServiceRegistration -StartAfterInstall
            if (!$installed) {
                Write-Host "Failed to automatically register service '$ServiceName'." -ForegroundColor Red
            }
            return
        }
        Restart-Service -Name $ServiceName -Force -ErrorAction Stop
        Write-Host "Service '$ServiceName' restarted." -ForegroundColor Green
    }
    'enable' {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if (!$service) {
            Write-Host "Service '$ServiceName' is not registered. Attempting auto-recovery..." -ForegroundColor Yellow
            Install-MihomoServiceRegistration | Out-Null
        }
        sc.exe config $ServiceName start= auto | Out-Null
        Write-Host "Service configured to start automatically on boot." -ForegroundColor Green
    }
    'disable' {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if (!$service) {
            Write-Host "Service '$ServiceName' is not registered." -ForegroundColor Red
            return
        }
        sc.exe config $ServiceName start= demand | Out-Null
        Write-Host "Service configured to manual start." -ForegroundColor Yellow
    }
    'repair' {
        Install-MihomoServiceRegistration -StartAfterInstall
    }
    'install' {
        Install-MihomoServiceRegistration -StartAfterInstall
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
    'edit' {
        $configPath = Join-Path $PSScriptRoot 'config\config.yaml'
        Write-Host "Target config file: $configPath" -ForegroundColor DarkGray
        Open-ConfigFile -FilePath $configPath | Out-Null
        Start-Sleep -Milliseconds 500
        Remove-Item -Path $script:EditorStdOutLog, $script:EditorStdErrLog -ErrorAction SilentlyContinue
    }
    'reload' {
        Invoke-MihomoReload
    }
    'help' {
        Show-Help
    }
}
