param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('pre_install', 'post_install', 'uninstall')]
    [string]$Phase,

    # 对应安装/更新阶段的 apps\<app>\current 目录路径 ($dir)
    [string]$Dir,

    # 对应持久化目录路径 ($persist_dir)
    [string]$PersistDir,

    # 对应 Scoop 的真实版本物理目录 ($original_dir)。
    # Windows 防火墙规则（New-NetFirewallRule -Program）在运行时是通过进程内核镜像路径做匹配的。
    # 如果传入 current 这类 Junction 联接点路径，会导致规则创建成功但因内核路径不匹配而失效。
    # 因此，创建防火墙规则时必须传入物理路径 $OriginalDir。
    [string]$OriginalDir
)

switch ($Phase) {
    'pre_install' {
        # 1. 规范化程序及服务包装器的执行文件名（获取第一个匹配项，避免通配符碰撞）
        $mihomoExe = Get-ChildItem "$Dir\mihomo*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($mihomoExe) {
            Rename-Item $mihomoExe.FullName -NewName 'mihomo.exe'
        }
        if (Test-Path "$Dir\shawl.exe") {
            Rename-Item "$Dir\shawl.exe" -NewName 'mihomo-service.exe'
        }

        # 2. 复制控制脚本至安装目录。利用 Select-Object -ExpandProperty 规避空引用异常
        $controlSource = Resolve-Path "$bucketsdir\*\scripts\mihomo-helper.ps1" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -First 1
        if ($controlSource) {
            Copy-Item $controlSource -Destination "$Dir\mihomo-helper.ps1" -Force
        }

        # 3. 预创建关键持久化文件与目录，避免 Scoop 建立软链接时因目标缺失而报错
        if (!(Test-Path "$PersistDir")) {
            New-Item -Path "$PersistDir" -ItemType Directory | Out-Null
        }
        if (!(Test-Path "$PersistDir\cache.db")) {
            New-Item -Path "$PersistDir\cache.db" -ItemType File | Out-Null
        }
        if (!(Test-Path "$PersistDir\config.yaml")) {
            New-Item -Path "$PersistDir\config.yaml" -ItemType File | Out-Null
        }
    }

    'post_install' {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        $servicePath = "$Dir\mihomo-service.exe"
        $logDir = "$Dir\logs"

        # 若未显式传入 $OriginalDir（如手动调用测试），则使用 $Dir 兜底，防止脚本抛错
        $RealDir = if ($OriginalDir) { $OriginalDir } else { $Dir }
        $RealMihomoExe = "$RealDir\mihomo.exe"

        # 构造注册至 Shawl 的后台服务命令及运行参数
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
            '-f', 'config.yaml'
        )

        if ($isAdmin) {
            # 配置 Windows 服务 (管理员上下文直接执行)
            sc.exe delete mihomo-shawl | Out-Null
            & "$servicePath" $argsList | Out-Null
            sc.exe config mihomo-shawl start= auto | Out-Null

            # 配置网络入站防火墙规则 (管理员上下文直接执行)
            Remove-NetFirewallRule -DisplayName 'Mihomo-In-TCP', 'Mihomo-In-UDP', 'Mihomo-Out' -ErrorAction SilentlyContinue | Out-Null
            New-NetFirewallRule -DisplayName 'Mihomo-In-TCP' -Direction Inbound -Program $RealMihomoExe -Action Allow -Profile Any -Protocol TCP -ErrorAction SilentlyContinue | Out-Null
            New-NetFirewallRule -DisplayName 'Mihomo-In-UDP' -Direction Inbound -Program $RealMihomoExe -Action Allow -Profile Any -Protocol UDP -ErrorAction SilentlyContinue | Out-Null
            Write-Host 'Mihomo Windows service registered and firewall rules configured successfully.' -ForegroundColor Green
        } else {
            Write-Host 'Not running as Administrator. Requesting UAC elevation to configure Windows service and firewall rules...' -ForegroundColor Yellow

            # 此处须提前拼合参数。因 PowerShell 中 '+' 的运算优先级高于 '-join'，
            # 直接在长字符串中使用会使后续追加的所有防火墙配置被合入 join 拼接符内导致丢失。
            $joinedArgs = ($argsList | ForEach-Object { "'$_'" }) -join ' '
            $cmdString = "sc.exe delete mihomo-shawl | Out-Null; & '$servicePath' " + $joinedArgs + `
                "; sc.exe config mihomo-shawl start= auto | Out-Null" + `
                "; Remove-NetFirewallRule -DisplayName 'Mihomo-In-TCP','Mihomo-In-UDP','Mihomo-Out' -ErrorAction SilentlyContinue" + `
                "; New-NetFirewallRule -DisplayName 'Mihomo-In-TCP' -Direction Inbound -Program '$RealMihomoExe' -Action Allow -Profile Any -Protocol TCP -ErrorAction SilentlyContinue | Out-Null" + `
                "; New-NetFirewallRule -DisplayName 'Mihomo-In-UDP' -Direction Inbound -Program '$RealMihomoExe' -Action Allow -Profile Any -Protocol UDP -ErrorAction SilentlyContinue | Out-Null"

            try {
                Start-Process powershell -ArgumentList '-NoProfile', '-WindowStyle', 'Hidden', '-Command', $cmdString -Verb RunAs -Wait -ErrorAction Stop
                Write-Host 'Mihomo Windows service registered and firewall rules configured successfully.' -ForegroundColor Green
            } catch {
                Write-Warning 'UAC elevation denied. Service was not registered and firewall rules were not added.'
            }
        }
        Write-Host ''
        Write-Host 'INFO: If your TUN/Mixed mode requires outbound rule, run PowerShell as Administrator and execute:' -ForegroundColor Cyan
        Write-Host "New-NetFirewallRule -DisplayName 'Mihomo-Out' -Direction Outbound -Program '$RealMihomoExe' -Action Allow -Profile Any" -ForegroundColor Gray
        Write-Host ''
    }

    'uninstall' {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        $services = @('mihomo', 'mihomo-shawl') | Get-Service -ErrorAction SilentlyContinue

        if ($isAdmin) {
            # 停止并移除所有相关服务
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
            # 清理可能残留的后台进程与关联防火墙规则
            Write-Host 'Stopping any remaining Mihomo processes...' -ForegroundColor Yellow
            Stop-Process -Name 'mihomo', 'mihomo-service' -Force -ErrorAction SilentlyContinue | Out-Null
            Remove-NetFirewallRule -DisplayName 'Mihomo-In-TCP', 'Mihomo-In-UDP', 'Mihomo-Out' -ErrorAction SilentlyContinue | Out-Null
        } else {
            Write-Host 'Not running as Administrator. Requesting elevation via UAC to stop/uninstall service, terminate processes, and remove firewall rules...' -ForegroundColor Yellow

            # 构造需要在管理员权限下合并执行的命令队列
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
            $elevatedCmds += "Remove-NetFirewallRule -DisplayName 'Mihomo-In-TCP','Mihomo-In-UDP','Mihomo-Out' -ErrorAction SilentlyContinue"
            $cmdString = $elevatedCmds -join '; '
            try {
                Start-Process powershell -ArgumentList '-NoProfile', '-WindowStyle', 'Hidden', '-Command', $cmdString -Verb RunAs -Wait -ErrorAction Stop
            } catch {
                Write-Warning 'UAC elevation denied. Failed to stop/uninstall service, terminate processes, and remove firewall rules.'
            }
        }
    }
}
