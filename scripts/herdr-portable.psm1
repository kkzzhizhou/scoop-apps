# Herdr 的映射只能创建链接，禁止复制或删除既有数据。
function Get-HerdrPathEntry([string]$Path) {
    [void][System.IO.Path]::GetFullPath($Path)
    try { return Get-Item -LiteralPath $Path -Force -ErrorAction Stop }
    catch {
        if ($_.CategoryInfo.Category -ne 'ObjectNotFound') { throw }
        $parent = Split-Path -Parent $Path
        $name = Split-Path -Leaf $Path
        if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $Path) { throw }
        $parentEntry = Get-HerdrPathEntry $parent
        if ($null -eq $parentEntry) { return $null }
        if (-not $parentEntry.PSIsContainer) { throw "Herdr path parent is not a directory: $parent" }
        $entries = @(Get-ChildItem -LiteralPath $parent -Force -ErrorAction Stop | Where-Object Name -EQ $name)
        if ($entries.Count -gt 0) { throw "Cannot inspect existing Herdr path: $Path" }
        return $null
    }
}

function Resolve-HerdrMappingPath([string]$Path, [hashtable]$Context) {
    if ($Path -match '^AppData/(.+)$') { return Join-Path $env:APPDATA $matches[1] }
    if ($Path -match '^LocalAppData/(.+)$') { return Join-Path $env:LOCALAPPDATA $matches[1] }
    if ($Path -match '^\$persist_dir[/\\](.+)$') { return Join-Path $Context.PersistDir $matches[1] }
    # 构建器会在调用处展开 $persist_dir，目标因此也可为绝对路径。
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    throw "Unsupported Herdr mapping path: $Path"
}

function Test-HerdrOwnedLink($Item, [string]$Source, [string]$Target) {
    if ($null -eq $Item -or $Item.LinkType -ne 'SymbolicLink' -or @($Item.Target).Count -ne 1) { return $false }
    $actualPath = [string]$Item.Target
    if (-not [System.IO.Path]::IsPathRooted($actualPath)) { $actualPath = Join-Path (Split-Path -Parent $Source) $actualPath }
    $actual = [System.IO.Path]::GetFullPath($actualPath).TrimEnd('\', '/')
    $expected = [System.IO.Path]::GetFullPath($Target).TrimEnd('\', '/')
    return $actual.Equals($expected, [System.StringComparison]::OrdinalIgnoreCase)
}

function Assert-HerdrMapping([hashtable]$Pair) {
    $item = Get-HerdrPathEntry $Pair.Source
    $target = Get-HerdrPathEntry $Pair.Target
    if ($null -ne $target -and (-not $target.PSIsContainer -or $target.LinkType)) {
        throw "Herdr persist target must be a real directory: $($Pair.Target)"
    }
    if ($null -ne $item -and (-not (Test-HerdrOwnedLink $item $Pair.Source $Pair.Target) -or $null -eq $target)) {
        throw "Herdr path must be preserved: $($Pair.Source). Resolve existing data or foreign/broken links before installing or uninstalling; Scoop will not migrate or delete them."
    }
}

function Ensure-HerdrDirectory([string]$Path) {
    $entry = Get-HerdrPathEntry $Path
    if ($null -eq $entry) { New-Item -ItemType Directory -Path $Path -ErrorAction Stop | Out-Null }
    $entry = Get-HerdrPathEntry $Path
    if ($null -eq $entry -or -not $entry.PSIsContainer -or $entry.LinkType) { throw "Herdr requires a real directory: $Path" }
}

function Invoke-PortableMappings {
    param(
        [ValidateSet('Install', 'Uninstall')] [string]$Action,
        [hashtable]$Context,
        [array]$Mappings,
        [switch]$Log
    )
    $ErrorActionPreference = 'Stop'
    $pairs = @($Mappings | ForEach-Object {
        if ($_.Strategy -ne 'symlink' -or $_.TargetType -ne 'directory') { throw 'Herdr only supports directory symlink mappings.' }
        @{ Source = (Resolve-HerdrMappingPath $_.Source $Context); Target = (Resolve-HerdrMappingPath $_.Target $Context); Label = $_.Label }
    })
    # 全部入口检查结束后才能创建目录或链接。
    foreach ($pair in $pairs) { Assert-HerdrMapping $pair }
    foreach ($pair in $pairs) {
        Assert-HerdrMapping $pair
        if ($Action -eq 'Install') {
            Ensure-HerdrDirectory $pair.Target
            $item = Get-HerdrPathEntry $pair.Source
            if ($null -eq $item) {
                Ensure-HerdrDirectory (Split-Path -Parent $pair.Source)
                # 不使用 Force；检查后出现的新路径必须导致失败，不能覆盖。
                New-Item -ItemType SymbolicLink -Path $pair.Source -Target $pair.Target -ErrorAction Stop | Out-Null
            }
            Assert-HerdrMapping $pair
            if (-not (Test-HerdrOwnedLink (Get-HerdrPathEntry $pair.Source) $pair.Source $pair.Target)) { throw "Herdr mapping was not created: $($pair.Source)" }
            if ($Log) { info "[Portable Mode] Linked $($pair.Label) -> $($pair.Target)" }
        } else {
            if ($null -ne (Get-HerdrPathEntry $pair.Source)) {
                Remove-Item -LiteralPath $pair.Source -Force -ErrorAction Stop
                if ($null -ne (Get-HerdrPathEntry $pair.Source)) { throw "Herdr link was not removed: $($pair.Source)" }
                if ($Log) { info "[Portable Mode] Removed symbolic link: $($pair.Source)" }
            }
        }
    }
}
