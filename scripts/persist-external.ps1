<#
    persist-external.ps1
    --------------------
    Scoop 'persist_external' core implementation.
    Links external paths (outside $dir, e.g. %AppData%\Code) to $persist_dir
    via Junction/Symlink for real-time persistence. Runs in parallel with native 'persist'.

    Public entry points:
      - Invoke-PersistExternalInstall
      - Invoke-PersistExternalUninstall
#>

Set-StrictMode -Version Latest

# ---------------------------------------------------------------------------
# 0. Compatibility layer: prefer Scoop native warn/error functions;
#    fallback to Write-Warning/Error if running standalone (e.g. Pester tests).
# ---------------------------------------------------------------------------
if (-not (Get-Command 'warn' -ErrorAction SilentlyContinue)) {
    function warn($msg) { Write-Warning $msg }
}
if (-not (Get-Command 'error' -ErrorAction SilentlyContinue)) {
    function error($msg) { Write-Error $msg }
}

# Normalize trailing path separators (preserve root paths like "C:\")
function ConvertTo-TrimmedPath {
    param([Parameter(Mandatory)][string]$Path)
    if ($Path.Length -gt 3) { return $Path.TrimEnd('\', '/') }
    return $Path
}

# ---------------------------------------------------------------------------
# 1. Path resolution: expand $env:VAR / %VAR% / $home / ~
# ---------------------------------------------------------------------------
function Convert-ExternalPath {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$RawPath)

    $p = $RawPath.Trim()

    if ($p -eq '$home' -or $p -eq '~') {
        $p = $HOME
    } elseif ($p -match '^(\$home|~)[/\\](?<rest>.*)$') {
        $p = Join-Path $HOME $Matches['rest']
    }

    # Expand $env:VAR format
    $p = [regex]::Replace($p, '\$env:(?<name>[\w()]+)', {
            param($m)
            $varName = $m.Groups['name'].Value
            $val = [Environment]::GetEnvironmentVariable($varName)
            if ([string]::IsNullOrEmpty($val)) {
                throw "persist_external: Unknown environment variable `$env:$($varName) (Source path: $RawPath)"
            }
            $val
        }, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    # Expand %VAR% format
    $p = [regex]::Replace($p, '%(?<name>[\w()]+)%', {
            param($m)
            $varName = $m.Groups['name'].Value
            $val = [Environment]::GetEnvironmentVariable($varName)
            if ([string]::IsNullOrEmpty($val)) {
                throw "persist_external: Unknown environment variable %$varName% (Source path: $RawPath)"
            }
            $val
        }, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    # Verify absolute path
    if (-not [System.IO.Path]::IsPathRooted($p)) {
        throw "persist_external: Path '$RawPath' expanded to non-absolute path '$p'. Please check if `$env:, `$home, or %VAR% prefix is missing."
    }

    return [System.IO.Path]::GetFullPath($p)
}

# ---------------------------------------------------------------------------
# 2. Parse Manifest definitions
#    Supports [source, target] or [source, target, 'file'|'directory']
# ---------------------------------------------------------------------------
function Get-PersistExternalDefinition {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Manifest)

    $raw = $Manifest.persist_external
    if (-not $raw) { return @() }
    if ($raw -isnot [array]) { $raw = @($raw) }

    $result = @()
    foreach ($item in $raw) {
        $typeHint = $null
        if ($item -is [array]) {
            $sourceRaw = $item[0]
            $targetName = $item[1]
            if ($item.Count -ge 3 -and $item[2]) {
                $typeHint = switch -Regex ($item[2]) {
                    '^(file)$' { 'File'; break }
                    '^(dir|directory)$' { 'Directory'; break }
                    default { throw "persist_external: Unknown type hint '$($item[2])', must be 'file' or 'directory'" }
                }
            }
        } else {
            $sourceRaw = $item
            $targetName = $null
        }

        $source = Convert-ExternalPath -RawPath $sourceRaw
        if (-not $targetName) {
            $targetName = Split-Path $source -Leaf
        }

        $result += [PSCustomObject]@{
            Source     = $source
            TargetName = $targetName
            TypeHint   = $typeHint
        }
    }
    return $result
}

# Resolve item type when creating placeholders (e.g. .gitconfig vs .vscode)
function Resolve-ExternalItemType {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Source,
        [string]$TypeHint,
        [string]$PersistTarget
    )

    if ($TypeHint) { return $TypeHint }

    # Check physical paths if either exists on disk
    if (Test-Path -LiteralPath $Source) {
        $item = Get-Item -LiteralPath $Source -Force -ErrorAction SilentlyContinue
        if ($null -ne $item) {
            if ($item.PSIsContainer) { return 'Directory' } else { return 'File' }
        }
    }

    if ($PersistTarget -and (Test-Path -LiteralPath $PersistTarget)) {
        $item = Get-Item -LiteralPath $PersistTarget -Force -ErrorAction SilentlyContinue
        if ($null -ne $item) {
            if ($item.PSIsContainer) { return 'Directory' } else { return 'File' }
        }
    }

    $leaf = Split-Path $Source -Leaf
    $ext = [System.IO.Path]::GetExtension($leaf)

    if ($leaf.StartsWith('.') -and $leaf -eq $ext) {
        throw "persist_external: Cannot infer placeholder type for '$leaf'. Please specify explicit type hint in manifest, e.g. ['$Source', '$leaf', 'file']"
    }

    # Standard file extension heuristic:
    # 1. $ext matches .ext format with 1-5 alphanumeric chars (no hyphens)
    # 2. $leaf is not a multi-dot name (e.g. reverse-DNS names like com.company.app)
    $isStandardExt = ($ext -match '^\.[a-zA-Z0-9]{1,5}$') -and (($leaf -split '\.').Count -le 2)

    if ($isStandardExt) { return 'File' }
    return 'Directory'
}

# Check privilege: file-level SymbolicLink requires Administrator or Developer Mode
function Test-CanCreateSymlink {
    [CmdletBinding()]
    param()

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) { return $true }

    try {
        $devMode = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' `
            -Name 'AllowDevelopmentWithoutDevLicense' -ErrorAction Stop
        return ($devMode -eq 1)
    } catch {
        return $false
    }
}

# ---------------------------------------------------------------------------
# 3. Persistence record (.scoop-persist-external.json)
# ---------------------------------------------------------------------------
function Get-ExternalLinkRecordPath {
    param([Parameter(Mandatory)][string]$Dir)
    Join-Path $Dir '.scoop-persist-external.json'
}

function Save-ExternalLinkRecord {
    param(
        [Parameter(Mandatory)][string]$Dir,
        [Parameter(Mandatory)][array]$Records
    )
    $path = Get-ExternalLinkRecordPath -Dir $Dir
    $Records | ConvertTo-Json -Depth 5 | Out-File -FilePath $path -Force -Encoding utf8
}

function Read-ExternalLinkRecord {
    param([Parameter(Mandatory)][string]$Dir)
    $path = Get-ExternalLinkRecordPath -Dir $Dir
    if (-not (Test-Path -LiteralPath $path)) { return $null }
    try {
        $content = Get-Content -LiteralPath $path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        if ($content -isnot [array]) { $content = @($content) }
        return $content
    } catch {
        warn "persist_external: Failed to read link record '$path', falling back to manifest parsing: $_"
        return $null
    }
}

# ---------------------------------------------------------------------------
# 4. Safe link removal
#    Remove ReadOnly attribute and call .NET API to prevent Remove-Item recursion risk
# ---------------------------------------------------------------------------
function Remove-ReparsePointSafe {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    $CleanPath = ConvertTo-TrimmedPath -Path $Path
    # Use Get-Item -Force to get physical node, preventing Test-Path $false on dangling links
    $item = Get-Item -LiteralPath $CleanPath -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $false }

    # Safety check: never delete non-link items
    if (-not $item.LinkType) { return $false }

    # Remove ReadOnly attribute to prevent UnauthorizedAccessException
    if ($item.Attributes -band [System.IO.FileAttributes]::ReadOnly) {
        $item.Attributes = $item.Attributes -band -bnot [System.IO.FileAttributes]::ReadOnly
    }

    if ($item.PSIsContainer) {
        # .NET Directory.Delete on Junction only removes the reparse point itself
        [System.IO.Directory]::Delete($CleanPath)
    } else {
        [System.IO.File]::Delete($CleanPath)
    }
    return $true
}

# ---------------------------------------------------------------------------
# 5. Core linking logic (handles migration, conflicts, and dangling links)
# ---------------------------------------------------------------------------
function New-ExternalPersistLink {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$PersistTarget,
        [string]$TypeHint
    )

    $Source = ConvertTo-TrimmedPath -Path $Source
    $PersistTarget = ConvertTo-TrimmedPath -Path $PersistTarget

    $sourceItem = Get-Item -LiteralPath $Source -Force -ErrorAction SilentlyContinue
    $targetItem = Get-Item -LiteralPath $PersistTarget -Force -ErrorAction SilentlyContinue

    $sourceIsLink = ($null -ne $sourceItem) -and [bool]$sourceItem.LinkType
    $sourceIsRealData = ($null -ne $sourceItem) -and (-not $sourceItem.LinkType)

    # 1. Idempotency check: skip if already linked to target
    if ($sourceIsLink) {
        # Take @()[0] for PS 5.1 compatibility when Junction Target returns List[string]
        $currentTarget = @($sourceItem.Target)[0]
        if ($currentTarget) {
            $normCurrent = [System.IO.Path]::GetFullPath(($currentTarget -replace '^\\\\\?\\', ''))
            $normPersist = [System.IO.Path]::GetFullPath($PersistTarget)
            if ($normCurrent -eq $normPersist -and ($null -ne $targetItem)) {
                Write-Verbose "persist_external: '$Source' is already linked to '$PersistTarget'"
                return $sourceItem.LinkType
            }
        }
    }

    # 2. Target in persist directory does not exist
    if ($null -eq $targetItem) {
        $targetParent = Split-Path $PersistTarget -Parent
        if (-not (Test-Path -LiteralPath $targetParent)) {
            New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
        }

        if ($sourceIsRealData) {
            # Only migrate real data, never run Move-Item on dangling links
            Move-Item -LiteralPath $Source -Destination $PersistTarget -Force
            $sourceItem = $null
            $sourceIsRealData = $false
        } else {
            if ($sourceIsLink) {
                Remove-ReparsePointSafe -Path $Source | Out-Null
                $sourceItem = $null
                $sourceIsLink = $false
            }
            # Create empty file/directory placeholder
            $itemType = Resolve-ExternalItemType -Source $Source -TypeHint $TypeHint -PersistTarget $PersistTarget
            if ($itemType -eq 'File') {
                New-Item -ItemType File -Path $PersistTarget -Force | Out-Null
            } else {
                New-Item -ItemType Directory -Path $PersistTarget -Force | Out-Null
            }
        }
        $targetItem = Get-Item -LiteralPath $PersistTarget -Force -ErrorAction Stop
    }

    # 3. Handle conflict: real data exists in both source and persist dir
    if ($sourceIsRealData) {
        $backup = "$Source.pre-persist-backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
        warn "persist_external: '$Source' conflicts with existing persist data, backed up to '$backup'"
        Move-Item -LiteralPath $Source -Destination $backup -Force
        $sourceItem = $null
        $sourceIsRealData = $false
    }

    # 4. Clean dangling or old links in source
    if ($null -ne (Get-Item -LiteralPath $Source -Force -ErrorAction SilentlyContinue)) {
        Remove-ReparsePointSafe -Path $Source | Out-Null
    }

    # 5. Ensure source parent directory exists
    $sourceParent = Split-Path $Source -Parent
    if (-not (Test-Path -LiteralPath $sourceParent)) {
        New-Item -ItemType Directory -Path $sourceParent -Force | Out-Null
    }

    # 6. Create link (Junction for directories, SymbolicLink for files)
    $isDirTarget = $targetItem.PSIsContainer
    $linkType = if ($isDirTarget) { 'Junction' } else { 'SymbolicLink' }

    if ($isDirTarget) {
        New-Item -ItemType Junction -Path $Source -Target $PersistTarget -Force | Out-Null
    } else {
        if (-not (Test-CanCreateSymlink)) {
            throw "persist_external: Symlink creation requires Administrator privilege or Developer Mode (Target: $Source)"
        }
        New-Item -ItemType SymbolicLink -Path $Source -Target $PersistTarget -Force | Out-Null
    }

    return $linkType
}

# ---------------------------------------------------------------------------
# 6. Public entry points
# ---------------------------------------------------------------------------
function Invoke-PersistExternalInstall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Manifest,
        [Parameter(Mandatory)][string]$PersistDir,
        [Parameter(Mandatory)][string]$Dir
    )

    $defs = Get-PersistExternalDefinition -Manifest $Manifest
    if (-not $defs) { return }

    # 1. Collect all target paths defined in the new Manifest
    $newTargets = @($defs | ForEach-Object { ConvertTo-TrimmedPath -Path (Join-Path $PersistDir $_.TargetName) })

    # 2. Detect orphaned/unmapped persist data from previous versions
    if (Test-Path -LiteralPath $PersistDir) {
        $existingItems = Get-ChildItem -LiteralPath $PersistDir -Force -ErrorAction SilentlyContinue
        foreach ($item in $existingItems) {
            # Skip internal record file
            if ($item.Name -eq '.scoop-persist-external.json') { continue }

            $itemPath = ConvertTo-TrimmedPath -Path $item.FullName
            if ($newTargets -notcontains $itemPath) {
                warn "persist_external: Found unmapped/orphaned persist item '$($item.Name)' in '$PersistDir'. If this item contains previous data, you may need to manually migrate it."
            }
        }
    }

    # 3. Process external persist links
    $records = @()
    foreach ($d in $defs) {
        $target = Join-Path $PersistDir $d.TargetName
        try {
            $linkType = New-ExternalPersistLink -Source $d.Source -PersistTarget $target -TypeHint $d.TypeHint
            $records += @{ Source = $d.Source; Target = $target; LinkType = $linkType }
        } catch {
            # Log error on individual failure and continue processing remaining items
            error "persist_external: Failed to process '$($d.Source)': $_"
        }
    }

    if ($records) {
        Save-ExternalLinkRecord -Dir $Dir -Records $records
    }
}

function Invoke-PersistExternalUninstall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Manifest,
        [Parameter(Mandatory)][string]$Dir
    )

    # Prefer recorded links for accurate unlinking
    $records = Read-ExternalLinkRecord -Dir $Dir

    if ($null -eq $records) {
        warn "persist_external: Installation record not found, falling back to manifest parsing"
        $defs = Get-PersistExternalDefinition -Manifest $Manifest
        $records = $defs | ForEach-Object { @{ Source = $_.Source } }
    }

    foreach ($r in $records) {
        $removed = Remove-ReparsePointSafe -Path $r.Source
        if ($removed) {
            Write-Verbose "persist_external: Removed external link '$($r.Source)'"
        } elseif ($null -ne (Get-Item -LiteralPath $r.Source -Force -ErrorAction SilentlyContinue)) {
            warn "persist_external: '$($r.Source)' is not expected link, skipped to protect real data"
        }
    }
}
