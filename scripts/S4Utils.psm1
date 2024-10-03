#Requires -Version 5.1

function New-ProfileModifier {
    <#
    .SYNOPSIS
        Generate scripts which modifies PowerShell profile.

    .PARAMETER Behavior
        Type of scripts to generate.

    .PARAMETER PSModuleName
        Name of PowerShell module, should be $manifest.psmodule.name in most situations.

    .PARAMETER AppDir
        Path of the app directory, should be $dir in most situations.

    .PARAMETER BucketDir
        Path of Scoop4kariiin bucket root directory.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("Type")]
        [string] $Behavior,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $PSModuleName,
        [Parameter(Mandatory = $true, Position = 2)]
        [string] $AppDir,
        [Parameter(Mandatory = $true, Position = 3)]
        [string] $BucketDir
    )

    $SupportedBehavior = @("ImportModule", "RemoveModule")

    if ($SupportedBehavior -notcontains $Behavior) {
        Write-Host "[ERROR] Unsupported behavior." -ForegroundColor Red
        Return
    }

    $S4UtilsPath = $BucketDir | Join-Path -ChildPath "\scripts\S4Utils.psm1"

    $ImportUtilsCommand = ("Import-Module ", $S4UtilsPath) -Join ("")
    $RemoveUtilsCommand = "Remove-Module -Name S4Utils -ErrorAction SilentlyContinue"

    $ImportModuleCommand = ("Add-ProfileContent 'Import-Module ", $PSModuleName, "'") -Join ("")
    $RemoveModuleCommand = ("Remove-ProfileContent 'Import-Module ", $PSModuleName, "'") -Join ("")

    switch ($Behavior) {
        { 'ImportModule' -eq $_ } {
            $GenerateContent = ($ImportUtilsCommand, $RemoveModuleCommand, $ImportModuleCommand, $RemoveUtilsCommand) -Join ("`r`n")
            $GenerateContent | Set-Content -Path "$AppDir\add-profile-content.ps1"
        }
        { 'RemoveModule' -eq $_ } {
            $GenerateContent = ($ImportUtilsCommand, $RemoveModuleCommand, $RemoveUtilsCommand) -Join ("`r`n")
            $GenerateContent | Set-Content -Path "$AppDir\remove-profile-content.ps1"
        }
    }
}

function Add-ProfileContent {
    <#
    .SYNOPSIS
        Add certain content to PowerShell profile.

    .PARAMETER Content
        Content to be added.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Content
    )

    if (-not(Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -Value "$Content" -ItemType File -Force | Out-Null
    } else {
        Add-Content -Path $PROFILE -Value "`r`n$Content" -NoNewLine
    }
}

function Remove-ProfileContent {
    <#
    .SYNOPSIS
        Remove certain content from PowerShell profile.

    .PARAMETER Content
        Content to be removed.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Content
    )

    if (-not(Test-Path $PROFILE)) {
        Return
    }

    $RawProfile = Get-Content -Path $PROFILE -raw

    if ($null -eq $RawProfile) {
        Return
    }

    ($RawProfile -replace "[\r\n]*$Content", '').trim() | Set-Content $PROFILE -NoNewLine
}

function Mount-ExternalRuntimeData {
    <#
    .SYNOPSIS
        Mount external runtime data.

    .PARAMETER Source
        Path of source folder in scoop persist directory.

    .PARAMETER Target
        The actual path which app uses to access the runtime data.

    .PARAMETER AppData
        Mount in $env:APPDATA by the name of source folder. Value of $Target will be overwritten.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("SourcePath", "Persist")]
        [string] $Source,
        [Parameter(Mandatory = $false, Position = 1)]
        [Alias("TargetPath", "Runtime")]
        [string] $Target,
        [Parameter(Mandatory = $false, Position = 2)]
        [switch] $AppData
    )

    if (-not($Target -or $AppData)) {
        Write-Host "[ERROR] Specify a mount point." -ForegroundColor Red
        Return
    }

    if ($AppData) {
        $FolderName = Split-Path -Path $Source -Leaf
        if ($Target) {
            Write-Host "[WARN] Overwriting `$Target value..." -ForegroundColor DarkYellow
        }
        $Target = Join-Path -Path $env:APPDATA -ChildPath $FolderName
    }

    if (-not(Test-Path $Source)) {
        Write-Host "Initializing persist folder..."
        New-Item -ItemType Directory $Source -Force | Out-Null
        if (Test-Path $Target) {
            Write-Host "Found existing runtime cache, moving to persist folder..."
            Get-ChildItem $Target | Copy-Item -Destination $Source -Force -Recurse
        }
    }

    if (Test-Path $Target) {
        Remove-Item $Target -Force -Recurse
    }

    Write-Host "Mounting runtime cache..."

    New-Item -ItemType Junction -Path $Target -Target $Source -Force | Out-Null
}

function Dismount-ExternalRuntimeData {
    <#
    .SYNOPSIS
        Unmount external runtime data.

    .PARAMETER Target
        Path or name of runtime folder mounted by scoop.

    .PARAMETER AppData
        Dismount folder in $env:APPDATA with folder name in Target parameter. Value of $Target will be overwritten.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("TargetPath", "Path", "Name")]
        [string] $Target,
        [Parameter(Mandatory = $false, Position = 1)]
        [switch] $AppData
    )

    if ($AppData) {
        $FolderName = Split-Path -Path $Target -Leaf
        $Target = Join-Path -Path $env:APPDATA -ChildPath $FolderName
    }

    Write-Host "Dismounting runtime cache..."

    if (Test-Path $Target) {
        Remove-Item $Target -Force -Recurse
    } else {
        Write-Host "[ERROR] Invalid target, continue without dismounting." -ForegroundColor Red
    }
}

function Import-PersistItem {
    <#
    .SYNOPSIS
        Import files persisted by other app.

    .PARAMETER Path
        Path of destination to Import into.

    .PARAMETER SourceApp
        Name of source app to import from.

    .PARAMETER Force
        Force overwrite if target exists.

    .PARAMETER Sync
        Create junction instead of copying files.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Path,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $SourceApp,
        [Parameter(Mandatory = $false, Position = 2)]
        [switch] $Force,
        [Parameter(Mandatory = $false, Position = 3)]
        [switch] $Sync
    )

    $ScoopPersistDir = Split-Path $Path -Parent
    $SourcePath = Join-Path -Path $ScoopPersistDir -ChildPath $SourceApp
    $TargetPath = $Path

    if (-not(Test-Path $SourcePath)) {
        Return
    }

    if (Test-Path $TargetPath) {
        if ($Force) {
            Write-Host "`nPersist directory exists, start force importing..." -ForegroundColor Yellow
            Remove-Item $TargetPath -Force -Recurse
        } else {
            Return
        }
    }

    if ($Sync) {
        Write-Host "`nImporting profiles from `'$SourceApp`' in synced mode..." -ForegroundColor Yellow
        New-Item -Path $TargetPath -ItemType Junction -Target $SourcePath | Out-Null
        Write-Host "Succeeded! DO NOT permanently uninstall `'$SourceApp`'." -ForegroundColor Green
    } else {
        Write-Host "`nImporting profiles from `'$SourceApp`'..." -ForegroundColor Yellow
        New-Item -Path $TargetPath -ItemType Directory | Out-Null
        Get-ChildItem $SourcePath | Copy-Item -Destination $TargetPath -Force -Recurse
        Write-Host "Succeeded! You can uninstall `'$SourceApp`' now." -ForegroundColor Green
    }
}

Export-ModuleMember `
    -Function `
    New-ProfileModifier, `
    Add-ProfileContent, `
    Remove-ProfileContent, `
    Mount-ExternalRuntimeData, `
    Dismount-ExternalRuntimeData, `
    Import-PersistItem
