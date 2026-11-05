<#
.SYNOPSIS
    Core Script and Function Library.
.DESCRIPTION
    Copyright (C) 2026 hu3rror. Licensed under the MIT License (see LICENSE in the repository root).
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('pre_install', 'post_install', 'uninstall')]
    [string]$Phase,

    [string]$Dir,

    [string]$PersistDir,

    # Windows 防火墙规则（New-NetFirewallRule -Program）在运行时是通过进程内核镜像路径做匹配的。
    # 如果传入 current 这类 Junction 联接点路径，会导致规则创建成功但因内核路径不匹配而失效。
    # 因此，创建防火墙规则时必须传入物理路径 $OriginalDir。
    [string]$OriginalDir
)

switch ($Phase) {
    'pre_install' {
        $mihomoExe = Get-ChildItem "$Dir\mihomo*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($mihomoExe) {
            Rename-Item $mihomoExe.FullName -NewName 'mihomo.exe'
        }
        if (Test-Path "$Dir\shawl.exe") {
            Rename-Item "$Dir\shawl.exe" -NewName 'mihomo-service.exe'
        }

        foreach ($name in @('mihomo-helper.ps1', 'mihomo-shawl-setup.ps1')) {
            $source = Join-Path $PSScriptRoot $name
            $target = Join-Path $Dir $name
            if ((Test-Path $source) -and ($source -ne $target)) {
                Copy-Item $source -Destination $target -Force
            }
        }

        foreach ($folder in @('', 'config', 'ui', 'proxies', 'rules', 'logs')) {
            $targetFolder = if ($folder) { "$PersistDir\$folder" } else { "$PersistDir" }
            if (!(Test-Path $targetFolder)) {
                New-Item -Path $targetFolder -ItemType Directory | Out-Null
            }
        }

        $oldConfig = "$PersistDir\config.yaml"
        $newConfig = "$PersistDir\config\config.yaml"
        if (Test-Path $oldConfig) {
            if (!(Test-Path $newConfig)) {
                Move-Item -Path $oldConfig -Destination $newConfig -Force
            } else {
                Remove-Item $newConfig -Force -ErrorAction SilentlyContinue
                Move-Item -Path $oldConfig -Destination $newConfig -Force
            }
        }

        if (!(Test-Path $newConfig)) {
            New-Item -Path $newConfig -ItemType File | Out-Null
        }
        if (!(Test-Path "$PersistDir\cache.db")) {
            New-Item -Path "$PersistDir\cache.db" -ItemType File | Out-Null
        }
    }

    'post_install' {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        $servicePath = "$Dir\mihomo-service.exe"
        $logDir = "$Dir\logs"

        $RealDir = if ($OriginalDir) { $OriginalDir } else { $Dir }
        $RealMihomoExe = "$RealDir\mihomo.exe"

        $argsList = @(
            'add',
            '--name', 'mihomo-shawl',
            '--cwd', "$Dir",
            '--log-dir', "$logDir",
            '--log-rotate', 'bytes=10485760',
            '--log-retain', '8',
            '--stop-timeout', '5000',
            '--',
            "$Dir\mihomo.exe",
            '-d', '.',
            '-f', 'config/config.yaml'
        )

        if ($isAdmin) {
            sc.exe delete mihomo-shawl | Out-Null
            & "$servicePath" $argsList | Out-Null
            sc.exe config mihomo-shawl start= auto | Out-Null

            Remove-NetFirewallRule -DisplayName 'Mihomo-In-TCP', 'Mihomo-In-UDP' -ErrorAction SilentlyContinue | Out-Null
            New-NetFirewallRule -DisplayName 'Mihomo-In-TCP' -Direction Inbound -Program $RealMihomoExe -Action Allow -Profile Any -Protocol TCP -ErrorAction SilentlyContinue | Out-Null
            New-NetFirewallRule -DisplayName 'Mihomo-In-UDP' -Direction Inbound -Program $RealMihomoExe -Action Allow -Profile Any -Protocol UDP -ErrorAction SilentlyContinue | Out-Null
            Write-Host 'Mihomo Windows service registered and firewall rules configured successfully.' -ForegroundColor Green

            $hasConfig = $PersistDir -and (Test-Path "$PersistDir\config\config.yaml") -and ((Get-Item "$PersistDir\config\config.yaml").Length -gt 0)
            if ($hasConfig) {
                $svc = Get-Service -Name 'mihomo-shawl' -ErrorAction SilentlyContinue
                if ($svc -and $svc.Status -eq 'Running') {
                    Restart-Service -Name 'mihomo-shawl' -Force -ErrorAction SilentlyContinue
                    Write-Host 'Existing config.yaml detected - service restarted.' -ForegroundColor Green
                } else {
                    Start-Service -Name 'mihomo-shawl' -ErrorAction SilentlyContinue
                    Write-Host 'Existing config.yaml detected - service started.' -ForegroundColor Green
                }
            } else {
                Write-Host 'No existing config.yaml content found - service registered but NOT started.' -ForegroundColor Yellow
                Write-Host 'Please edit config.yaml, then run "mihomo-helper start".' -ForegroundColor Yellow
            }
        } else {
            Write-Host 'Not running as Administrator. Requesting UAC elevation to configure Windows service and firewall rules...' -ForegroundColor Yellow

            $joinedArgs = ($argsList | ForEach-Object { "'$_'" }) -join ' '
            $hasConfig = $PersistDir -and (Test-Path "$PersistDir\config\config.yaml") -and ((Get-Item "$PersistDir\config\config.yaml").Length -gt 0)
            $serviceStartCmd = if ($hasConfig) {
                "; `$svc = Get-Service -Name 'mihomo-shawl' -ErrorAction SilentlyContinue" +
                "; if (`$svc -and `$svc.Status -eq 'Running') { Restart-Service -Name 'mihomo-shawl' -Force -ErrorAction SilentlyContinue } else { Start-Service -Name 'mihomo-shawl' -ErrorAction SilentlyContinue }"
            } else {
                ''
            }

            $cmdString = @(
                "sc.exe delete mihomo-shawl | Out-Null; & '$servicePath' $joinedArgs"
                "; sc.exe config mihomo-shawl start= auto | Out-Null"
                "; Remove-NetFirewallRule -DisplayName 'Mihomo-In-TCP','Mihomo-In-UDP' -ErrorAction SilentlyContinue"
                "; New-NetFirewallRule -DisplayName 'Mihomo-In-TCP' -Direction Inbound -Program '$RealMihomoExe' -Action Allow -Profile Any -Protocol TCP -ErrorAction SilentlyContinue | Out-Null"
                "; New-NetFirewallRule -DisplayName 'Mihomo-In-UDP' -Direction Inbound -Program '$RealMihomoExe' -Action Allow -Profile Any -Protocol UDP -ErrorAction SilentlyContinue | Out-Null"
                $serviceStartCmd
            ) -join ''

            try {
                Start-Process powershell -ArgumentList '-NoProfile', '-WindowStyle', 'Hidden', '-Command', $cmdString -Verb RunAs -Wait -ErrorAction Stop
                if ($hasConfig) {
                    Write-Host 'Mihomo Windows service registered, firewall rules configured, and service (re)started.' -ForegroundColor Green
                } else {
                    Write-Host 'Mihomo Windows service registered and firewall rules configured. Service NOT started (no existing config.yaml).' -ForegroundColor Yellow
                    Write-Host 'Please edit config.yaml, then run "mihomo-helper start".' -ForegroundColor Yellow
                }
            } catch {
                Write-Warning 'UAC elevation denied. Service was not registered and firewall rules were not added.'
            }
        }
    }

    'uninstall' {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        $services = @('mihomo', 'mihomo-shawl') | Get-Service -ErrorAction SilentlyContinue

        if ($isAdmin) {
            if ($services) {
                foreach ($service in $services) {
                    if ($service.Status -eq 'Running') {
                        Write-Host "Stopping '$($service.Name)' service..." -ForegroundColor Yellow
                        Stop-Service -Name $service.Name -Force -ErrorAction SilentlyContinue | Out-Null
                    }
                    Write-Host "Uninstalling '$($service.Name)' service..." -ForegroundColor Yellow
                    sc.exe delete $service.Name | Out-Null
                }
            }
            Write-Host 'Stopping any remaining Mihomo processes...' -ForegroundColor Yellow
            Stop-Process -Name 'mihomo', 'mihomo-service' -Force -ErrorAction SilentlyContinue | Out-Null
            Remove-NetFirewallRule -DisplayName 'Mihomo-In-TCP', 'Mihomo-In-UDP' -ErrorAction SilentlyContinue | Out-Null
        } else {
            Write-Host 'Not running as Administrator. Requesting elevation via UAC to stop/uninstall service, terminate processes, and remove firewall rules...' -ForegroundColor Yellow

            $elevatedCmds = @()
            if ($services) {
                foreach ($service in $services) {
                    if ($service.Status -eq 'Running') {
                        $elevatedCmds += "Stop-Service -Name '$($service.Name)' -Force -ErrorAction SilentlyContinue"
                    }
                    $elevatedCmds += "sc.exe delete '$($service.Name)'"
                }
            }
            $elevatedCmds += "Stop-Process -Name 'mihomo','mihomo-service' -Force -ErrorAction SilentlyContinue"
            $elevatedCmds += "Remove-NetFirewallRule -DisplayName 'Mihomo-In-TCP','Mihomo-In-UDP' -ErrorAction SilentlyContinue"
            $cmdString = $elevatedCmds -join '; '
            try {
                Start-Process powershell -ArgumentList '-NoProfile', '-WindowStyle', 'Hidden', '-Command', $cmdString -Verb RunAs -Wait -ErrorAction Stop
            } catch {
                Write-Warning 'UAC elevation denied. Failed to stop/uninstall service, terminate processes, and remove firewall rules.'
            }
        }
    }
}
