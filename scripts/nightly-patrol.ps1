#Requires -Version 7.0
<#
.SYNOPSIS
  scoop 夜巡（本地版）：由 Windows 计划任务「scoop 夜巡」每天 04:00 以用户本人账号运行。

.DESCRIPTION
  只做确定性步骤：Git 同步 → SymbolicLink 预检 → scoop update（逐个）→ 清理 → checkver → Actions → DiskGenius → 写日志。
  不修清单、不提交（DiskGenius 镜像脚本自带的提交除外）、不停进程、不装新软件、不删用户数据。
  需要 bot 介入时向 webhook POST 一个 JSON（date / reasons / summary / log_path）。

.PARAMETER DryRunWake
  只组装 payload 并写入 workdir/auto-update/pending-wake-*.json，不真的发送。

.PARAMETER SimulateFailure
  强制走「需要唤醒」分支用于测试：跳过所有真实操作（不更新软件、不清理），不受「当天日志已完整」限制，
  日志与 payload 文件名带 .simulated 后缀，不改 state.json。
#>
[CmdletBinding()]
param(
    [switch]$DryRunWake,
    [switch]$SimulateFailure
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ───────────────────────── 基础变量 ─────────────────────────
$RepoRoot   = Split-Path $PSScriptRoot -Parent
$ScoopRoot  = if ($env:SCOOP) { $env:SCOOP } else { 'D:\Scoop' }
$ScoopPs1   = Join-Path $ScoopRoot 'apps\scoop\current\bin\scoop.ps1'
$AppsDir    = Join-Path $ScoopRoot 'apps'
$PersistDir = Join-Path $ScoopRoot 'persist'
$CacheDir   = if ($env:SCOOP_CACHE) { $env:SCOOP_CACHE } else { Join-Path $ScoopRoot 'cache' }
$PwshPath   = (Get-Process -Id $PID).Path
$Repo       = 'LaelLuo/scoop'
$AuDir      = Join-Path $RepoRoot 'workdir\auto-update'
$StatePath  = Join-Path $AuDir 'state.json'
$WebhookCfg = Join-Path $env:USERPROFILE '.config\scoop-nightly\webhook.json'
$Utf8NoBom  = [System.Text.UTF8Encoding]::new($false)

# 运行中也不唤醒的软件（bot 自身守护进程常驻，必然「正在运行」）
$IgnoreRunningWake = @('grok-bot')
$SkipWakeNights = 3       # 同一软件连续被跳过多少晚后唤醒
$AvailWakeNights = 2      # 清单 available 连续多少晚后唤醒

$BjTz = try { [TimeZoneInfo]::FindSystemTimeZoneById('China Standard Time') } catch { [TimeZoneInfo]::FindSystemTimeZoneById('Asia/Shanghai') }
function ConvertTo-Dto($v) { if ($v -is [datetime]) { return [DateTimeOffset]$v }; return [DateTimeOffset]::Parse([string]$v, [System.Globalization.CultureInfo]::InvariantCulture) }
function Get-Bj { [TimeZoneInfo]::ConvertTime([DateTimeOffset]::Now, $BjTz) }
$Start   = Get-Bj
$Today   = $Start.ToString('yyyy-MM-dd')
$Suffix  = if ($SimulateFailure) { '.simulated' } else { '' }
$LogPath = Join-Path $AuDir "$Today$Suffix.md"
$RawDir  = Join-Path $AuDir "raw-$Today$Suffix"
$PendingPath = Join-Path $AuDir "pending-wake-$Today$Suffix.json"

New-Item -ItemType Directory -Force -Path $AuDir | Out-Null

# ───────────────────────── 工具函数 ─────────────────────────
function Write-Log([string]$Text) {
    [System.IO.File]::AppendAllText($LogPath, $Text + "`r`n", $Utf8NoBom)
}
$script:SectionNo = 0
function Write-Section([string]$Title, [string]$Body) {
    $script:SectionNo++
    Write-Log ''
    Write-Log "## $($script:SectionNo). $Title"
    if ($Body) { Write-Log $Body }
    Write-Host "[$($script:SectionNo)] $Title"
}
function Format-Bytes([double]$b) {
    if ($b -ge 1GB) { return ('{0:N2} GB' -f ($b / 1GB)) }
    if ($b -ge 1MB) { return ('{0:N1} MB' -f ($b / 1MB)) }
    return ('{0:N0} KB' -f ($b / 1KB))
}
function Clean-Lines($lines) {
    foreach ($l in $lines) {
        $s = [string]$l
        $s = [regex]::Replace($s, '\x1b\[[0-9;]*[A-Za-z]', '')
        if ($s.Contains("`r")) { $s = ($s -split "`r" | Where-Object { $_.Trim() } | Select-Object -Last 1) }
        if ($null -ne $s) { $s.TrimEnd() }
    }
}
function Save-Raw([string]$Name, $Lines) {
    New-Item -ItemType Directory -Force -Path $RawDir | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $RawDir "$Name.txt"), ((@($Lines) -join "`r`n") + "`r`n"), $Utf8NoBom)
}
function Get-Excerpt($Lines, [int]$Last = 20) {
    $x = @($Lines | Where-Object { $_ -and $_.Trim() })
    if ($x.Count -le $Last) { return ($x -join "`n") }
    return ("…（共 $($x.Count) 行，完整输出见 raw-$Today$Suffix\）`n" + (($x | Select-Object -Last $Last) -join "`n"))
}
# 运行外部/脚本命令并捕获全部输出（含 Write-Host），返回 @{Lines; Exit}
function Invoke-Capture([scriptblock]$Block) {
    $global:LASTEXITCODE = 0
    $raw = @(& $Block *>&1)
    $code = $LASTEXITCODE
    $lines = @(Clean-Lines ($raw | ForEach-Object { if ($_ -is [pscustomobject] -and -not ($_ -is [System.Management.Automation.InformationRecord])) { ($_ | Out-String).TrimEnd() } else { "$_" } }))
    return @{ Lines = $lines; Exit = $code }
}
function Get-GitLines([string[]]$GitArgs) {
    $r = Invoke-Capture { git -C $RepoRoot @GitArgs }
    return $r
}

# ───────────────────────── 链接快照 ─────────────────────────
function Get-LinkInfo($item) {
    # 注意：PS7 的 Test-Path 与 .NET 的 Directory.Exists 对悬空符号链接都可能返回 True，
    # 所以用 ResolveLinkTarget($true) 解析到最终目标，再看目标是否真实存在（对 SymbolicLink 与 Junction 都有效）
    $acc = $false
    if (-not $item.LinkType) { $acc = $true }
    elseif ($item.LinkType -eq 'HardLink') { $acc = [System.IO.File]::Exists($item.FullName) }   # scoop 的 persist 文件用硬链接
    else { try { $t = $item.ResolveLinkTarget($true); $acc = [bool]($t -and $t.Exists) } catch { $acc = $false } }
    [pscustomobject]@{
        Path       = $item.FullName
        Type       = [string]$item.LinkType
        Target     = ($item.Target -join ';')
        Accessible = $acc
    }
}
function Get-ExternalLinkInfos {
    $res = [System.Collections.Generic.List[object]]::new()
    foreach ($root in @($env:APPDATA, $env:LOCALAPPDATA, $env:USERPROFILE) | Select-Object -Unique) {
        Get-ChildItem -LiteralPath $root -Force -ErrorAction SilentlyContinue | Where-Object { $_.LinkType } | ForEach-Object { $res.Add((Get-LinkInfo $_)) }
    }
    return $res
}
# 返回与 $app 相关的便携链接：AppData/LocalAppData/用户目录（一层）里指向其 persist/apps 目录的链接，
# persist\<app>\ 下的链接，apps\<app>\current 及 current 下的链接
function Get-AppLinks([string]$App, $External = $null) {
    $res = [System.Collections.Generic.List[object]]::new()
    $pat = '^' + [regex]::Escape($ScoopRoot) + '\\(?:persist|apps)\\' + [regex]::Escape($App) + '(?:\\|$)'
    if ($null -eq $External) { $External = Get-ExternalLinkInfos }
    foreach ($l in $External) { if ($l.Target -match $pat) { $res.Add($l) } }
    $pDir = Join-Path $PersistDir $App
    if (Test-Path -LiteralPath $pDir) {
        Get-ChildItem -LiteralPath $pDir -Force -ErrorAction SilentlyContinue | Where-Object { $_.LinkType } | ForEach-Object { $res.Add((Get-LinkInfo $_)) }
    }
    $cur = Join-Path $AppsDir "$App\current"
    if (Test-Path -LiteralPath $cur) {
        $res.Add((Get-LinkInfo (Get-Item -LiteralPath $cur -Force)))
        # current 下的硬链接只在 persist 里有同名文件时才算「便携链接」（其他多链接文件如 bun.exe 不算）
        Get-ChildItem -LiteralPath $cur -Force -ErrorAction SilentlyContinue | Where-Object { $_.LinkType -and ($_.LinkType -ne 'HardLink' -or (Test-Path -LiteralPath (Join-Path $pDir $_.Name))) } | ForEach-Object { $res.Add((Get-LinkInfo $_)) }
    }
    return @($res | Sort-Object Path -Unique)
}
function Get-AllLinks {
    $apps = @(Get-ChildItem -LiteralPath $AppsDir -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object Name)
    $all = [System.Collections.Generic.List[object]]::new()
    $ext = Get-ExternalLinkInfos
    foreach ($a in $apps) { foreach ($l in (Get-AppLinks $a $ext)) { $all.Add([pscustomobject]@{ App = $a; Link = $l }) } }
    return $all
}
function Format-Link($l) { "{0} [{1}] -> {2}{3}" -f $l.Path, $(if ($l.Type) { $l.Type } else { '无' }), $l.Target, $(if ($l.Accessible) { '' } else { '  ⚠不可访问' }) }
# 更新前后对比：返回问题列表（空 = 完好）
function Compare-Links($Before, $After) {
    $issues = [System.Collections.Generic.List[string]]::new()
    $afterMap = @{}; foreach ($a in $After) { $afterMap[$a.Path] = $a }
    foreach ($b in $Before) {
        if (-not $afterMap.ContainsKey($b.Path)) {
            if ($b.Path -match '\\current$') { $issues.Add("current 丢失：$($b.Path)") } else { $issues.Add("链接消失：$($b.Path)（原 $($b.Type) -> $($b.Target)）") }
            continue
        }
        $a = $afterMap[$b.Path]
        if ($b.Type -ne $a.Type) { $issues.Add("链接类型变化：$($b.Path) $($b.Type) -> $($a.Type)") }
        elseif ($b.Path -notmatch '\\current$' -and $b.Target -ne $a.Target) { $issues.Add("链接目标变化：$($b.Path) $($b.Target) -> $($a.Target)") }
    }
    foreach ($a in $After) { if (-not $a.Accessible) { $issues.Add("不可访问：$($a.Path) -> $($a.Target)") } }
    return @($issues | Select-Object -Unique)
}

# ───────────────────────── 预检 ─────────────────────────
function Remove-TestPath([string]$p) {
    if (Test-Path -LiteralPath $p) {
        $i = Get-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
        if ($i -and $i.LinkType) { $i.Delete() } else { Remove-Item -LiteralPath $p -Force -Recurse -ErrorAction SilentlyContinue }
    }
}
function Test-SymlinkPrecheck {
    $stamp = '{0}-{1}' -f $Today.Replace('-', ''), $PID
    $pre = Join-Path $env:TEMP "scoop-patrol-$stamp\pre"
    $persistTest = Join-Path $PersistDir ".patrol-symtest-$stamp"
    $r = [ordered]@{ file = $false; dir = $false; cross = $false; cleanup_ok = $false; error = '' }
    $detail = [System.Collections.Generic.List[string]]::new()
    try {
        New-Item -ItemType Directory -Force -Path $pre | Out-Null
        # 1) 文件型
        $ft = Join-Path $pre 'file-target.txt'; $fl = Join-Path $pre 'file-link.txt'
        'precheck-file' | Set-Content -LiteralPath $ft -Encoding UTF8
        New-Item -ItemType SymbolicLink -Path $fl -Target $ft -Force | Out-Null
        $fi = Get-Item -LiteralPath $fl -Force
        $r.file = ($fi.LinkType -eq 'SymbolicLink') -and ((Get-Content -LiteralPath $fl -Raw) -match 'precheck-file')
        $detail.Add("file_symlink=$($r.file) type=$($fi.LinkType)")
        # 2) 目录型
        $dt = Join-Path $pre 'dir-target'; $dl = Join-Path $pre 'dir-link'
        New-Item -ItemType Directory -Force -Path $dt | Out-Null
        'precheck-dir' | Set-Content -LiteralPath (Join-Path $dt 'inside.txt') -Encoding UTF8
        New-Item -ItemType SymbolicLink -Path $dl -Target $dt -Force | Out-Null
        $di = Get-Item -LiteralPath $dl -Force
        $r.dir = ($di.LinkType -eq 'SymbolicLink') -and (Test-Path -LiteralPath (Join-Path $dl 'inside.txt'))
        $detail.Add("dir_symlink=$($r.dir) type=$($di.LinkType)")
        # 3) 跨卷：AppData 所在卷 -> persist 所在卷
        New-Item -ItemType Directory -Force -Path $persistTest | Out-Null
        'precheck-cross' | Set-Content -LiteralPath (Join-Path $persistTest 'inside.txt') -Encoding UTF8
        $cl = Join-Path $pre 'symtest'
        New-Item -ItemType SymbolicLink -Path $cl -Target $persistTest -Force | Out-Null
        $ci = Get-Item -LiteralPath $cl -Force
        $r.cross = ($ci.LinkType -eq 'SymbolicLink') -and (Test-Path -LiteralPath (Join-Path $cl 'inside.txt'))
        $detail.Add("cross_vol_symlink=$($r.cross) type=$($ci.LinkType) ($cl -> $persistTest)")
    }
    catch { $r.error = $_.Exception.Message; $detail.Add("异常: $($r.error)") }
    finally {
        foreach ($p in @('file-link.txt', 'file-target.txt', 'dir-link', 'dir-target', 'symtest')) { Remove-TestPath (Join-Path $pre $p) }
        Remove-TestPath $persistTest
        Remove-TestPath $pre
        $parent = Split-Path $pre -Parent
        if ((Test-Path -LiteralPath $parent) -and -not (Get-ChildItem -LiteralPath $parent -Force -ErrorAction SilentlyContinue)) { Remove-Item -LiteralPath $parent -Force -ErrorAction SilentlyContinue }
        $r.cleanup_ok = (-not (Test-Path -LiteralPath $pre)) -and (-not (Test-Path -LiteralPath $persistTest))
    }
    $r.pass = [bool]($r.file -and $r.dir -and $r.cross)
    $r.detail = $detail
    return $r
}

# ───────────────────────── 其他辅助 ─────────────────────────
function Test-AppRunning([string]$App) {
    $prefix = (Join-Path $AppsDir $App) + '\'
    @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase) })
}
function Get-CurrentVersion([string]$App) {
    $cur = Join-Path $AppsDir "$App\current"
    if (-not (Test-Path -LiteralPath $cur)) { return $null }
    $i = Get-Item -LiteralPath $cur -Force
    if ($i.Target) { return (Split-Path ($i.Target -join '') -Leaf) }
    $m = Join-Path $cur 'manifest.json'
    if (Test-Path -LiteralPath $m) { try { return (Get-Content -LiteralPath $m -Raw | ConvertFrom-Json).version } catch { } }
    return $null
}
function Get-OldVersionDirs {
    $out = [System.Collections.Generic.List[string]]::new()
    foreach ($d in (Get-ChildItem -LiteralPath $AppsDir -Directory -Force -ErrorAction SilentlyContinue)) {
        $cv = Get-CurrentVersion $d.Name
        if (-not $cv) { continue }
        foreach ($v in (Get-ChildItem -LiteralPath $d.FullName -Directory -Force -ErrorAction SilentlyContinue)) {
            if ($v.Name -ne 'current' -and $v.Name -ne $cv) { $out.Add("$($d.Name)@$($v.Name)") }
        }
    }
    return @($out)
}
function Get-DirBytes([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    $s = (Get-ChildItem -LiteralPath $Path -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    if ($s) { return [double]$s } else { return 0 }
}
function Get-FreeBytes { try { (Get-PSDrive -Name ($ScoopRoot.Substring(0, 1))).Free } catch { 0 } }
function Add-Reason([string]$Text) { if (-not $script:Reasons.Contains($Text)) { $script:Reasons.Add($Text) } }

function Get-ManifestNames {
    @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'bucket') -Filter *.json -File | ForEach-Object { $_.BaseName })
}
function Invoke-Checkver([string]$App = '') {
    $cvArgs = @('-NoProfile', '-File', (Join-Path $RepoRoot 'bin\checkver.ps1'))
    if ($App) { $cvArgs += @('-App', $App) }
    $r = Invoke-Capture { & $PwshPath @cvArgs }
    $names = [System.Collections.Generic.HashSet[string]]::new([string[]](Get-ManifestNames), [System.StringComparer]::OrdinalIgnoreCase)
    $avail = [ordered]@{}; $errs = [ordered]@{}
    foreach ($l in $r.Lines) {
        if ($l -match '^(?<app>[^\s:]+): (?<msg>.+)$' -and $names.Contains($Matches.app)) {
            $app = $Matches.app; $msg = $Matches.msg
            if ($msg -match '^(?<new>\S+) \(scoop version is (?<old>[^)]+)\)') { $avail[$app] = "$($Matches.old) -> $($Matches.new)" }
            elseif ($msg -match '^\S+$') { }
            else { $errs[$app] = $msg }
        }
    }
    return @{ Lines = $r.Lines; Exit = $r.Exit; Available = $avail; Errors = $errs }
}

# ───────────────────────── 唤醒 ─────────────────────────
function Send-Wake($Payload) {
    $json = $Payload | ConvertTo-Json -Depth 6
    $bytes = $Utf8NoBom.GetBytes($json)
    $writePending = {
        param($why)
        [System.IO.File]::WriteAllText($PendingPath, $json, $Utf8NoBom)
        Write-Log "唤醒 payload 已写入 ``$PendingPath``（$why）。"
        Write-Host "pending-wake -> $PendingPath ($why)"
    }
    if ($DryRunWake) { & $writePending '-DryRunWake：只写盘不发送'; return 'dryrun' }
    if (-not (Test-Path -LiteralPath $WebhookCfg)) { & $writePending '未找到 webhook.json 配置'; return 'no-config' }
    try {
        $cfg = Get-Content -LiteralPath $WebhookCfg -Raw -Encoding utf8 | ConvertFrom-Json
        $url = [string]$cfg.url
        if ([string]::IsNullOrWhiteSpace($url)) { throw 'url 为空' }
        $headers = @{}; $ctype = 'application/json; charset=utf-8'
        if ($cfg.headers) {
            foreach ($p in $cfg.headers.PSObject.Properties) {
                if ([string]::IsNullOrWhiteSpace($p.Name) -or [string]::IsNullOrWhiteSpace([string]$p.Value)) { continue }
                if ($p.Name -ieq 'Content-Type') { $ctype = [string]$p.Value } else { $headers[$p.Name] = [string]$p.Value }
            }
        }
    }
    catch { & $writePending ('webhook.json 无法解析：' + $_.Exception.GetType().Name); return 'bad-config' }
    for ($i = 1; $i -le 3; $i++) {
        try {
            $null = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $bytes -ContentType $ctype -TimeoutSec 30
            Write-Log "已向 webhook 发送唤醒（第 $i 次成功）。"
            Write-Host "webhook 已发送"
            return 'sent'
        }
        catch {
            $code = ''
            try { if ($_.Exception.Response) { $code = ' HTTP ' + [int]$_.Exception.Response.StatusCode } } catch { }
            Write-Log "webhook 第 $i 次发送失败：$($_.Exception.GetType().Name)$code"
            if ($i -lt 3) { Start-Sleep -Seconds (5 * $i) }
        }
    }
    & $writePending 'webhook 3 次发送均失败'
    return 'failed'
}

# ───────────────────────── 单实例 + 当天完整性检查 ─────────────────────────
$mutex = [System.Threading.Mutex]::new($false, 'Global\scoop-nightly-patrol-laelluo')
$hasMutex = $false
try { $hasMutex = $mutex.WaitOne(0) } catch [System.Threading.AbandonedMutexException] { $hasMutex = $true }
if (-not $hasMutex) { Write-Host '另一个夜巡实例正在运行，退出。'; exit 0 }

try {
    if (-not $SimulateFailure -and (Test-Path -LiteralPath $LogPath)) {
        if ((Get-Content -LiteralPath $LogPath -Raw -Encoding utf8) -match '本轮完成') {
            Write-Host "当天日志 $LogPath 已完整，跳过整轮。"
            exit 0
        }
        $bak = Join-Path $AuDir ("$Today.incomplete-{0}.md" -f (Get-Bj).ToString('HHmmss'))
        Move-Item -LiteralPath $LogPath -Destination $bak
        Write-Host "发现不完整的当天日志，已改名为 $bak，重新开始。"
    }
    if ($SimulateFailure -and (Test-Path -LiteralPath $LogPath)) { Remove-Item -LiteralPath $LogPath -Force }

    $script:Reasons = [System.Collections.Generic.List[string]]::new()
    $S = [ordered]@{
        Updated = [System.Collections.Generic.List[string]]::new()
        SkippedRunning = [System.Collections.Generic.List[string]]::new()
        SkippedHeld = [System.Collections.Generic.List[string]]::new()
        Removed = [System.Collections.Generic.List[string]]::new()
        Notes = [System.Collections.Generic.List[string]]::new()
        CleanupText = '未执行'
        CheckverText = '未执行'
        ActionsText = '未执行'
        DiskGeniusText = '未执行'
    }

    # state.json
    $state = @{ lastRunDate = ''; available = @{}; skipped = @{} }
    if (Test-Path -LiteralPath $StatePath) {
        try { $loaded = Get-Content -LiteralPath $StatePath -Raw -Encoding utf8 | ConvertFrom-Json -AsHashtable; if ($loaded) { foreach ($k in $loaded.Keys) { $state[$k] = $loaded[$k] } } } catch { }
    }
    foreach ($k in 'available', 'skipped') { if (-not ($state[$k] -is [hashtable])) { $state[$k] = @{} } }
    $prevGapOk = $false
    if ($state.lastRunDate) {
        try { $gap = ([datetime]::ParseExact($Today, 'yyyy-MM-dd', $null) - [datetime]::ParseExact($state.lastRunDate, 'yyyy-MM-dd', $null)).Days; $prevGapOk = ($gap -ge 0 -and $gap -le 3) } catch { }
    }
    function Get-Nights([string]$Bucket, [string]$Name) {
        $p = $state[$Bucket][$Name]
        if (-not $p) { return 1 }
        if ($p.last -eq $Today) { return [int]$p.nights }
        if ($prevGapOk -and $p.last -eq $state.lastRunDate) { return [int]$p.nights + 1 }
        return 1
    }

    # ───── 日志头 ─────
    Write-Log "# Scoop 每日维护 - $Today$(if ($SimulateFailure) { '（模拟失败测试）' })"
    Write-Log ''
    Write-Log "开始时间（北京时间）：$($Start.ToString('yyyy-MM-dd HH:mm'))"
    Write-Log ''
    $who = '{0}\{1}' -f $env:USERDOMAIN, $env:USERNAME
    Write-Log "执行者：本地脚本 ``scripts/nightly-patrol.ps1``（计划任务「scoop 夜巡」，账号 $who）。参数：DryRunWake=$([bool]$DryRunWake) SimulateFailure=$([bool]$SimulateFailure)。"
    Write-Log "宿主：PSEdition=$($PSVersionTable.PSEdition) PSVersion=$($PSVersionTable.PSVersion) 路径=``$PwshPath``（所有 Scoop 操作在此 pwsh 7 进程内直调 ``$ScoopPs1``）。"
    Write-Log '规则：不停进程、不装新软件、不删用户数据；本脚本不修清单、不提交，修复交给被唤醒的 bot。'
    Write-Host "Scoop 夜巡 $Today  pwsh $($PSVersionTable.PSVersion)"

    $canMutate = $true
    $scoopExists = Test-Path -LiteralPath $ScoopPs1
    $stopUpdates = $false
    $brokenFound = $false

    if ($SimulateFailure) {
        Write-Section '模拟失败（-SimulateFailure）' "跳过所有真实操作（Git 同步、预检、scoop update、清理、checkver、Actions、DiskGenius），仅走「需要唤醒」的判定与发送路径；state.json 不更新。"
        Add-Reason '模拟失败（-SimulateFailure 测试，非真实故障）'
        $S.Notes.Add('本次为模拟运行，没有执行任何真实更新。')
        $S.CleanupText = '未执行（模拟）'; $S.CheckverText = '未执行（模拟）'; $S.ActionsText = '未执行（模拟）'; $S.DiskGeniusText = '未执行（模拟）'
    }
    else {
        if (-not $scoopExists) { Add-Reason "找不到 scoop.ps1：$ScoopPs1"; $canMutate = $false }

        # ───── 1. Git 同步 ─────
        $porc = Get-GitLines @('status', '--porcelain')
        $branch = (Get-GitLines @('rev-parse', '--abbrev-ref', 'HEAD')).Lines | Select-Object -First 1
        $headBefore = (Get-GitLines @('rev-parse', '--short', 'HEAD')).Lines | Select-Object -First 1
        $porcLines = @($porc.Lines | Where-Object { $_.Trim() })
        if ($porcLines.Count -eq 0 -and $branch -eq 'master') {
            $pull = Get-GitLines @('pull', '--ff-only', 'origin', 'master')
            Save-Raw 'git-pull' $pull.Lines
            $headAfter = (Get-GitLines @('rev-parse', '--short', 'HEAD')).Lines | Select-Object -First 1
            $body = "工作区干净，分支 master，HEAD=``$headBefore`` → ``$headAfter``（exit $($pull.Exit)）。`n``````text`n$(Get-Excerpt $pull.Lines 8)`n``````"
            if ($pull.Exit -ne 0) { $S.Notes.Add("git pull --ff-only 失败（exit $($pull.Exit)），本轮 checkver 基于本地现状。") }
        }
        else {
            $body = "工作区有未提交/未跟踪改动或分支不是 master（branch=$branch），**未执行 pull**，保留现状不 stash。`n``````text`n$(Get-Excerpt $porcLines 15)`n``````"
            $S.Notes.Add('Git 工作区有无关改动（或分支非 master），未 pull，已保留。')
        }
        Write-Section 'Git 同步（git status 干净时 git pull --ff-only origin master）' $body

        # ───── 2. SymbolicLink 预检 ─────
        if ($canMutate) {
            $pre = Test-SymlinkPrecheck
            Write-Section 'SymbolicLink 预检（同一 pwsh 进程，隔离临时路径）' ("``````text`n" + ($pre.detail -join "`n") + "`nPRECHECK_PASS=$($pre.pass)  cleanup_ok=$($pre.cleanup_ok)`n``````")
            if (-not $pre.pass) {
                Add-Reason 'SymbolicLink 预检失败（不更新任何软件，仅做只读检查）'
                $canMutate = $false
                $S.Notes.Add('预检失败：未更新任何软件、未执行卸载钩子、未删旧链接、未改用 Junction。')
            }
            elseif (-not $pre.cleanup_ok) { $S.Notes.Add('预检通过，但测试链接/文件未完全清理，请检查 %TEMP%\scoop-patrol-* 与 persist\.patrol-symtest-*。') }
        }
        else { Write-Section 'SymbolicLink 预检' '未执行（scoop.ps1 不存在）。' }

        # ───── 3. 链接基线 + scoop update 索引 + 待更新列表 ─────
        $pending = @()
        if ($canMutate) {
            $baseAll = Get-AllLinks
            $baseBad = @($baseAll | Where-Object { -not $_.Link.Accessible })
            Write-Section '更新前便携链接基线' ("扫描 apps\*\current、persist\*、AppData/LocalAppData/用户目录一层中指向 Scoop 的链接：共 $($baseAll.Count) 条，不可访问 $($baseBad.Count) 条。" + $(if ($baseBad.Count) { "`n``````text`n" + (($baseBad | ForEach-Object { Format-Link $_.Link }) -join "`n") + "`n``````" } else { '' }))
            if ($baseBad.Count) {
                Add-Reason ("断链：更新前基线已有 $($baseBad.Count) 条链接不可访问（" + (($baseBad | Select-Object -First 3 | ForEach-Object { $_.Link.Path }) -join '; ') + '）')
                $brokenFound = $true; $stopUpdates = $true
                $S.Notes.Add('基线已有断链：未更新任何软件，不做 cleanup。')
            }
            $idx = Invoke-Capture { & $ScoopPs1 update }
            Save-Raw 'scoop-index' $idx.Lines
            Write-Section 'scoop update（仅更新索引）' ("exit $($idx.Exit)`n``````text`n$(Get-Excerpt $idx.Lines 6)`n``````")
            if ($idx.Exit -ne 0) { $S.Notes.Add("scoop update 索引更新 exit $($idx.Exit)。") }
        }
        if ($scoopExists) {
            $all = @(& $ScoopPs1 status *>&1)
            $objs = @($all | Where-Object { $_ -is [pscustomobject] -and $_.PSObject.Properties['Name'] -and $_.PSObject.Properties['Latest Version'] })
            Save-Raw 'scoop-status' (Clean-Lines ($all | ForEach-Object { ($_ | Out-String).TrimEnd() }))
            $statusLines = @()
            foreach ($o in $objs) {
                $lv = [string]$o.'Latest Version'; $info = [string]$o.Info
                $statusLines += "{0}  {1} -> {2}  {3}" -f $o.Name, $o.'Installed Version', $(if ($lv) { $lv } else { '-' }), $info
                if ($info -match 'Held') { $S.SkippedHeld.Add("$($o.Name)（hold）") }
                elseif ($info -match 'Manifest removed') { $S.Removed.Add([string]$o.Name) }
                elseif ($lv) { $pending += [pscustomobject]@{ Name = [string]$o.Name; From = [string]$o.'Installed Version'; To = $lv } }
            }
            $pendBody = "待更新 $($pending.Count) 个；hold/清单已移除另计。`n``````text`n" + ($statusLines -join "`n") + "`n``````"
            Write-Section 'scoop status（待更新列表）' $pendBody
        }

        # ───── 4. 逐个更新 ─────
        $updLog = [System.Collections.Generic.List[string]]::new()
        $skippedNow = [System.Collections.Generic.List[string]]::new()
        if ($canMutate -and -not $stopUpdates) {
            foreach ($p in $pending) {
                $app = $p.Name
                if ($stopUpdates) { $updLog.Add("- **$app** $($p.From) → $($p.To)：因前面出现断链/报错，停止其余更新，未处理。"); continue }
                $run = Test-AppRunning $app
                if ($run.Count -gt 0) {
                    $names = ($run | ForEach-Object { $_.ProcessName } | Select-Object -Unique) -join ','
                    $updLog.Add("- **$app** $($p.From) → $($p.To)：运行中（$($run.Count) 个进程：$names），跳过。")
                    $S.SkippedRunning.Add("$app $($p.To)")
                    $skippedNow.Add($app)
                    continue
                }
                $before = Get-AppLinks $app
                $hadPersist = Test-Path -LiteralPath (Join-Path $PersistDir $app)
                $sb = [System.Collections.Generic.List[string]]::new()
                $sb.Add("- **$app** $($p.From) → $($p.To)：无进程，开始更新。更新前链接：" + $(if ($before.Count) { '' } else { '无' }))
                foreach ($l in $before) { $sb.Add("  - " + (Format-Link $l)) }
                $u = Invoke-Capture { & $ScoopPs1 update $app }
                $now = Get-CurrentVersion $app
                $ok = ($u.Exit -eq 0) -and $now -and ($now -ne $p.From)
                if (-not $ok -and (($u.Lines -join "`n") -match '(?i)hash check failed')) {
                    $sb.Add("  - hash 校验失败：scoop cache rm $app 后重试一次。")
                    $null = Invoke-Capture { & $ScoopPs1 cache rm $app }
                    $u2 = Invoke-Capture { & $ScoopPs1 update $app }
                    Save-Raw "update-$app-retry" $u2.Lines
                    $u = $u2; $now = Get-CurrentVersion $app
                    $ok = ($u2.Exit -eq 0) -and $now -and ($now -ne $p.From)
                    if (-not $ok) { Add-Reason "hash 校验失败，重试后仍失败：$app $($p.To)" }
                }
                Save-Raw "update-$app" $u.Lines
                $after = Get-AppLinks $app
                $issues = @(Compare-Links $before $after)
                if ($hadPersist -and -not (Test-Path -LiteralPath (Join-Path $PersistDir $app))) { $issues += "persist 目录丢失：persist\$app" }
                $sb.Add("  - exit $($u.Exit)；更新后版本 $now；更新后链接：")
                foreach ($l in $after) { $sb.Add("    - " + (Format-Link $l)) }
                if ($issues.Count) {
                    $brokenFound = $true; $stopUpdates = $true
                    Add-Reason ("断链/链接异常：$app（" + ($issues -join '；') + '）')
                    $sb.Add("  - ⚠ 链接/persist 异常，停止其余更新，不覆盖配置、不合并目录：")
                    foreach ($i in $issues) { $sb.Add("    - $i") }
                }
                if ($ok) { $S.Updated.Add("$app $($p.From) → $($p.To)"); $sb.Add("  - 更新成功。") }
                else {
                    if (-not ($script:Reasons | Where-Object { $_ -like "*$app*" })) { Add-Reason "更新报错：$app $($p.From) → $($p.To)（exit $($u.Exit)，当前版本 $now）" }
                    $stopUpdates = $true
                    $sb.Add("  - ⚠ 更新未成功，停止其余更新。输出末尾：")
                    $sb.Add("``````text`n$(Get-Excerpt $u.Lines 12)`n``````")
                }
                $updLog.Add(($sb -join "`n"))
            }
        }
        elseif (-not $canMutate) { $updLog.Add('预检失败或 scoop 不可用：本轮不更新任何软件。') }
        elseif ($stopUpdates) { $updLog.Add('基线已有断链：本轮不更新任何软件。') }
        if ($updLog.Count -eq 0) { $updLog.Add('没有待更新的软件。') }
        Write-Section '逐个更新（不用 update --all；运行中跳过；每个更新前后核对链接与 persist）' ($updLog -join "`n")

        # 连续跳过统计
        $newSkipped = @{}
        foreach ($a in $skippedNow) { $n = Get-Nights 'skipped' $a; $newSkipped[$a] = @{ last = $Today; nights = $n } }
        foreach ($a in $newSkipped.Keys) {
            $n = $newSkipped[$a].nights
            if ($n -ge $SkipWakeNights -and $IgnoreRunningWake -notcontains $a) { Add-Reason "软件连续 $n 晚因运行中被跳过：$a" }
            elseif ($n -ge 2) { $S.Notes.Add("$a 已连续 $n 晚因运行中被跳过$(if ($IgnoreRunningWake -contains $a) { '（bot 自身守护进程，不唤醒）' })。") }
        }

        # ───── 5. 清理 ─────
        if ($canMutate -and -not $brokenFound) {
            $oldBefore = Get-OldVersionDirs
            $cacheBefore = Get-DirBytes $CacheDir
            $freeBefore = Get-FreeBytes
            $cl = Invoke-Capture { & $ScoopPs1 cleanup '*' }
            Save-Raw 'cleanup' $cl.Lines
            $oldAfter = Get-OldVersionDirs
            $removedOld = @($oldBefore | Where-Object { $oldAfter -notcontains $_ })
            $locked = @($cl.Lines | Where-Object { $_ -match "(?i)couldn't remove|access to the path|being used by another process|cannot remove|failed" })
            $cr = Invoke-Capture { & $ScoopPs1 cache rm '*' }
            Save-Raw 'cache-rm' $cr.Lines
            $cacheAfter = Get-DirBytes $CacheDir
            $freeAfter = Get-FreeBytes
            $cacheFreed = $cacheBefore - $cacheAfter
            $driveDelta = $freeAfter - $freeBefore
            $bodyC = @(
                "scoop cleanup '*'：exit $($cl.Exit)；清理旧版本 $($removedOld.Count) 个：$(if ($removedOld.Count) { $removedOld -join '、' } else { '无' })。",
                "scoop cache rm '*'：exit $($cr.Exit)；缓存 $(Format-Bytes $cacheBefore) → $(Format-Bytes $cacheAfter)，释放 $(Format-Bytes $cacheFreed)。",
                "$($ScoopRoot.Substring(0,1)): 盘可用空间变化 $(if ($driveDelta -ge 0) { '+' } else { '-' })$(Format-Bytes ([math]::Abs($driveDelta)))（含旧版本目录，受其他写入影响，仅供参考）。"
            )
            if ($locked.Count -or $oldAfter.Count) {
                $bodyC += "未清掉的范围：$(if ($oldAfter.Count) { $oldAfter -join '、' } else { '（无旧版本目录残留）' })；占用相关输出：$(($locked | Select-Object -First 3) -join ' / ')。不强删。"
                $S.Notes.Add("cleanup 有残留或被占用：$($oldAfter -join '、')。")
            }
            Write-Section "清理（scoop cleanup '*' 与 scoop cache rm '*'）" ($bodyC -join "`n")
            $S.CleanupText = "旧版本 $($removedOld.Count) 个（$(if ($removedOld.Count) { $removedOld -join '、' } else { '无' })）；缓存释放 $(Format-Bytes $cacheFreed)；$($ScoopRoot.Substring(0,1)): 盘可用空间变化 $(if ($driveDelta -ge 0) { '+' } else { '-' })$(Format-Bytes ([math]::Abs($driveDelta)))" + $(if ($oldAfter.Count) { "；残留 $($oldAfter -join '、')" } else { '' })

            # 清理后全局复核
            $postAll = Get-AllLinks
            $postBad = @($postAll | Where-Object { -not $_.Link.Accessible })
            $lost = @()
            $postPaths = @{}; foreach ($x in $postAll) { $postPaths[$x.Link.Path] = $x.Link }
            foreach ($x in $baseAll) { if (-not $postPaths.ContainsKey($x.Link.Path)) { $lost += $x.Link.Path } }
            Write-Section '清理后链接复核' ("链接 $($postAll.Count) 条（基线 $($baseAll.Count) 条），不可访问 $($postBad.Count) 条，消失 $($lost.Count) 条。" + $(if ($postBad.Count -or $lost.Count) { "`n``````text`n" + ((@($postBad | ForEach-Object { Format-Link $_.Link }) + @($lost | ForEach-Object { "消失：$_" })) -join "`n") + "`n``````" } else { '' }))
            if ($postBad.Count -or $lost.Count) { Add-Reason "断链：清理后复核发现 $($postBad.Count) 条不可访问、$($lost.Count) 条消失（例：$((@($postBad | ForEach-Object { $_.Link.Path }) + $lost | Select-Object -First 3) -join '; ')）"; $brokenFound = $true }
        }
        else {
            $why = if ($brokenFound) { '本轮出现断链，按规则不做 cleanup。' } else { '预检失败/scoop 不可用，不做 cleanup。' }
            Write-Section '清理' $why
            $S.CleanupText = "未执行（$why）"
        }

        # ───── 6. checkver ─────
        $cv = Invoke-Checkver
        $cvNote = ''
        if ($cv.Errors.Count) {
            # 按规则原样再跑一次再下结论：只重跑出错的清单（整库重跑会连续打 GitHub API，容易触发 403 rate limit）
            Save-Raw 'checkver1' $cv.Lines
            $first = @($cv.Errors.Keys)
            Start-Sleep -Seconds 10
            $retryLines = [System.Collections.Generic.List[string]]::new()
            foreach ($a in $first) {
                $r2 = Invoke-Checkver $a
                $retryLines.AddRange([string[]]@($r2.Lines))
                $cv.Errors.Remove($a)
                foreach ($k in $r2.Errors.Keys) { $cv.Errors[$k] = $r2.Errors[$k] }
                foreach ($k in $r2.Available.Keys) { $cv.Available[$k] = $r2.Available[$k] }
            }
            Save-Raw 'checkver2-retry' $retryLines
            $cvNote = "首次有报错（$($first -join '、')），按规则原样重跑一次（只重跑这些清单）；重跑后仍报错 $($cv.Errors.Count) 项。"
        }
        Save-Raw 'checkver' $cv.Lines
        # 本机 SSL/DNS/超时类错误多是工作站网络问题（Actions 会照常更新），只记日志不唤醒；其他错误才唤醒。
        $netErr = @()
        foreach ($a in $cv.Errors.Keys) {
            if ($cv.Errors[$a] -match 'SSL|DNS|No such host|timed out|timeout|Name or service not known|无法解析|actively refused') { $netErr += $a }
            else { Add-Reason "checkver 报错：$a（$($cv.Errors[$a])）" }
        }
        if ($netErr.Count) { $cvNote += "网络类错误（$($netErr -join '、')）判为本机网络问题，只记录不唤醒。" }
        $newAvail = @{}
        foreach ($a in $cv.Available.Keys) {
            $n = Get-Nights 'available' $a
            $newAvail[$a] = @{ last = $Today; nights = $n }
            if ($n -ge $AvailWakeNights) { Add-Reason "清单 available 连续 $n 晚仍未被更新：$a（$($cv.Available[$a])）" }
        }
        $cvBody = "pwsh -NoProfile -File bin\checkver.ps1（不加 -u），exit $($cv.Exit)。$cvNote`n"
        $cvBody += "- available：" + $(if ($cv.Available.Count) { (($cv.Available.Keys | ForEach-Object { "$_ $($cv.Available[$_])（第 $($newAvail[$_].nights) 晚）" }) -join '；') } else { '无' }) + "`n"
        $cvBody += "- 报错：" + $(if ($cv.Errors.Count) { (($cv.Errors.Keys | ForEach-Object { "$_：$($cv.Errors[$_])" }) -join '；') } else { '无' })
        Write-Section 'checkver 纯查询' $cvBody
        $S.CheckverText = "available：$(if ($cv.Available.Count) { ($cv.Available.Keys | ForEach-Object { "$_（第 $($newAvail[$_].nights) 晚）" }) -join '、' } else { '无' })；报错：$(if ($cv.Errors.Count) { ($cv.Errors.Keys) -join '、' } else { '无' })$(if ($cvNote) { '（已原样重跑一次）' })"

        # ───── 7. GitHub Actions ─────
        $gh = Invoke-Capture { gh run list -R $Repo --limit 15 --json databaseId,workflowName,status,conclusion,createdAt }
        if ($gh.Exit -ne 0) { Start-Sleep -Seconds 5; $gh = Invoke-Capture { gh run list -R $Repo --limit 15 --json databaseId,workflowName,status,conclusion,createdAt } }
        if ($gh.Exit -eq 0) {
            $runs = @(($gh.Lines -join "`n") | ConvertFrom-Json)
            $tbl = $runs | ForEach-Object { "{0} {1} {2} {3} {4}" -f $_.status, $(if ($_.conclusion) { $_.conclusion } else { '-' }), $_.workflowName, $_.databaseId, ([TimeZoneInfo]::ConvertTime((ConvertTo-Dto $_.createdAt), $BjTz).ToString('yyyy-MM-dd HH:mm')) }
            Save-Raw 'gh-runs' $tbl
            $failed = @($runs | Where-Object { $_.conclusion -in 'failure', 'timed_out', 'startup_failure' })
            $unresolved = @()
            foreach ($f in $failed) {
                $later = @($runs | Where-Object { $_.workflowName -eq $f.workflowName -and $_.conclusion -eq 'success' -and (ConvertTo-Dto $_.createdAt) -gt (ConvertTo-Dto $f.createdAt) })
                if ($later.Count -eq 0) { $unresolved += $f }
            }
            foreach ($f in $unresolved) { Add-Reason "GitHub Actions 失败：$($f.workflowName) #$($f.databaseId)（$($f.conclusion)）" }
            $okCount = @($runs | Where-Object { $_.conclusion -eq 'success' }).Count
            $actBody = "gh run list -R $Repo --limit 15：共 $($runs.Count) 次，success $okCount，failure 类 $($failed.Count)（其中后续同名 workflow 已成功的 $($failed.Count - $unresolved.Count)，仍未恢复的 $($unresolved.Count)）。时间为北京时间。`n``````text`n$($tbl -join "`n")`n``````"
            $S.ActionsText = "最近 $($runs.Count) 次中 success $okCount；失败 $($failed.Count)，未恢复 $($unresolved.Count)"
        }
        else {
            $actBody = "gh run list 失败（exit $($gh.Exit)），已重试一次：`n``````text`n$(Get-Excerpt $gh.Lines 5)`n``````"
            $S.ActionsText = "查询失败（gh exit $($gh.Exit)）"
            $S.Notes.Add('gh run list 调用失败，Actions 状态未知。')
        }
        $iss = Invoke-Capture { gh issue list -R $Repo --state open --json number,title }
        if ($iss.Exit -eq 0) {
            $issArr = @(($iss.Lines -join "`n") | ConvertFrom-Json)
            $actBody += "`nOpen issues：$(if ($issArr.Count) { ($issArr | ForEach-Object { "#$($_.number) $($_.title)" }) -join '；' } else { '无' })（仅记录，不触发唤醒）。"
            if ($issArr.Count) { $S.Notes.Add("有 $($issArr.Count) 个 open issue（仅记录）。") }
        }
        Write-Section 'GitHub Actions 与 issues' $actBody

        # ───── 8. DiskGenius ─────
        $dg = Invoke-Capture { & $PwshPath -NoProfile -File (Join-Path $RepoRoot 'scripts\mirror-diskgenius.ps1') }
        $dgText = $dg.Lines -join "`n"
        $captcha = $dgText -match '(?i)验证码|captcha'
        if ($dg.Exit -ne 0 -and -not $captcha) {
            Start-Sleep -Seconds 10
            $dg2 = Invoke-Capture { & $PwshPath -NoProfile -File (Join-Path $RepoRoot 'scripts\mirror-diskgenius.ps1') }
            $dg = $dg2; $dgText = $dg.Lines -join "`n"; $captcha = $dgText -match '(?i)验证码|captcha'
        }
        Save-Raw 'diskgenius' $dg.Lines
        if ($captcha) { Add-Reason 'DiskGenius 镜像遇到验证码（只报告，未重试）'; $S.DiskGeniusText = '遇到验证码，仅报告' }
        elseif ($dg.Exit -ne 0) { Add-Reason "DiskGenius 镜像脚本失败（exit $($dg.Exit)，已重试一次）"; $S.DiskGeniusText = "脚本失败 exit $($dg.Exit)" }
        else { $S.DiskGeniusText = (($dg.Lines | Where-Object { $_ -match 'upstream=|already|release|pushed' }) | Select-Object -First 2) -join '；'; if (-not $S.DiskGeniusText) { $S.DiskGeniusText = '正常' } }
        Write-Section 'DiskGenius 镜像同步（scripts\mirror-diskgenius.ps1）' ("exit $($dg.Exit)`n``````text`n$(Get-Excerpt $dg.Lines 10)`n``````")

        # ───── 更新 state.json ─────
        $state.available = $newAvail
        $state.skipped = $newSkipped
        $state.lastRunDate = $Today
        [System.IO.File]::WriteAllText($StatePath, ($state | ConvertTo-Json -Depth 5), $Utf8NoBom)
    }

    # ───── 小结 ─────
    $needWake = $script:Reasons.Count -gt 0
    $sum = [System.Collections.Generic.List[string]]::new()
    $sum.Add("- 更新：$(if ($S.Updated.Count) { $S.Updated -join '；' } else { '无' })")
    $sum.Add("- 跳过：$((@($S.SkippedRunning | ForEach-Object { "$_（运行中）" }) + @($S.SkippedHeld) + @($S.Removed | ForEach-Object { "$_（清单已移除）" })) -join '；')")
    if ($sum[-1] -eq '- 跳过：') { $sum[-1] = '- 跳过：无' }
    $sum.Add("- 清理：$($S.CleanupText)")
    $sum.Add("- checkver：$($S.CheckverText)")
    $sum.Add("- Actions：$($S.ActionsText)")
    $sum.Add("- DiskGenius：$($S.DiskGeniusText)")
    if ($S.Notes.Count) { $sum.Add("- 备注：$($S.Notes -join ' ')") }
    $sum.Add("- 需要处理的事项：$(if ($needWake) { ($script:Reasons -join '；') } else { '无' })")
    $sumText = $sum -join "`n"
    Write-Section '夜巡小结（北京时间）' $sumText

    # ───── 唤醒 ─────
    if ($needWake) {
        $payloadSummary = $sumText
        if ($payloadSummary.Length -gt 4000) { $payloadSummary = $payloadSummary.Substring(0, 3980) + '…（已截断）' }
        $payload = [ordered]@{ date = $Today; reasons = @($script:Reasons); summary = $payloadSummary; log_path = $LogPath }
        Write-Log ''
        Write-Log "**需要唤醒 bot**：$($script:Reasons -join '；')"
        $wakeResult = Send-Wake $payload
    }
    else {
        Write-Log ''
        Write-Log '无需唤醒 bot。'
        $wakeResult = 'none'
    }

    $running = if ($SimulateFailure) { '模拟运行：未执行任何真实操作' } else { '本轮没有停止任何进程' }
    Write-Log ''
    Write-Log "$running；没有安装新软件（只更新已安装软件）；没有删除用户数据（只删 scoop 旧版本目录、下载缓存和自建测试链接/临时目录）。"
    Write-Log ''
    Write-Log "本轮完成。（耗时 $([int]((Get-Bj) - $Start).TotalSeconds) 秒；唤醒结果：$wakeResult）"
    Write-Host "本轮完成。reasons=$($script:Reasons.Count) wake=$wakeResult"
}
catch {
    $msg = "脚本自身异常：$($_.Exception.Message) @ $($_.InvocationInfo.ScriptLineNumber)"
    try {
        if (-not $script:Reasons) { $script:Reasons = [System.Collections.Generic.List[string]]::new() }
        Add-Reason $msg
        Write-Log ''
        Write-Log "## 异常"
        Write-Log "$msg`n``````text`n$($_.ScriptStackTrace)`n``````"
        $sm = "脚本自身异常终止。`n$msg`n" + ($script:Reasons -join "`n")
        if ($sm.Length -gt 4000) { $sm = $sm.Substring(0, 3980) + '…（已截断）' }
        $payload = [ordered]@{ date = $Today; reasons = @($script:Reasons); summary = $sm; log_path = $LogPath }
        $wakeResult = Send-Wake $payload
        Write-Log ''
        Write-Log "本轮完成（异常终止，唤醒结果：$wakeResult）。"
    }
    catch { Write-Host "异常处理本身失败：$($_.Exception.Message)" }
    exit 1
}
finally {
    if ($hasMutex) { try { $mutex.ReleaseMutex() } catch { } }
    $mutex.Dispose()
}
