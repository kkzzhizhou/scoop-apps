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
        return
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
        return
    }

    $RawProfile = Get-Content -Path $PROFILE -raw

    if ($null -eq $RawProfile) {
        return
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
        return
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

    .PARAMETER PersistDir
        Path of persist directory.

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
        [string] $PersistDir,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $SourceApp,
        [Parameter(Mandatory = $false, Position = 2)]
        [switch] $Force,
        [Parameter(Mandatory = $false, Position = 3)]
        [switch] $Sync
    )

    $ScoopPersistDir = Split-Path $PersistDir -Parent
    $SourcePath = Join-Path -Path $ScoopPersistDir -ChildPath $SourceApp
    $TargetPath = $PersistDir

    if (-not(Test-Path $SourcePath)) {
        return
    }

    if (Test-Path $TargetPath) {
        if ($Force) {
            Write-Host "`nPersist directory exists, start force importing..." -ForegroundColor Yellow
            Remove-Item $TargetPath -Force -Recurse
        } else {
            return
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

function New-PersistItem {
    <#
    .SYNOPSIS
        Create items in persist directory.

    .PARAMETER PersistDir
        Path of persist directory.

    .PARAMETER Name
        Name of item to create.

    .PARAMETER Type
        Type of item to create.

    .PARAMETER Content
        Initial content of file, use with parameter "-Type File".

    .PARAMETER Force
        Force overwrite if item exists.

    .PARAMETER Backup
        Rename original item instead of removing it, use with parameter "-Force".
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $PersistDir,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $Name,
        [Parameter(Mandatory = $true, Position = 2)]
        [string] $Type,
        [Parameter(Mandatory = $false, Position = 3)]
        [string] $Content,
        [Parameter(Mandatory = $false, Position = 4)]
        [switch] $Force,
        [Parameter(Mandatory = $false, Position = 5)]
        [switch] $Backup
    )

    $SupportedType = @("Directory", "File")

    if ($SupportedType -notcontains $Type) {
        Write-Host "[ERROR] Unsupported type." -ForegroundColor Red
        return
    }

    if (-not($Content)) {
        $Content = $null
    }

    $ItemArray = $Name.Split(",").Trim()

    foreach ($Item in $ItemArray) {
        $PersistItemPath = Join-Path -Path $PersistDir -ChildPath $Item

        if (Test-Path $PersistItemPath) {
            if ($Force) {
                if ($Backup) {
                    $BackupItem = ($Item, "backup") -Join(".")
                    $BackupItemPath = Join-Path -Path $PersistDir -ChildPath $BackupItem

                    if (Test-Path $BackupItemPath) {
                        Remove-Item -Path $BackupItemPath -Force -Recurse
                    }

                    Rename-Item -Path $PersistItemPath -NewName $BackupItem -Force
                } else {
                    Remove-Item -Path $PersistItemPath -Force -Recurse
                }
            } else {
                continue
            }
        }

        switch ($Type) {
            { 'Directory' -eq $Type } { New-Item -Path $PersistItemPath -ItemType $Type | Out-Null }
            { 'File' -eq $Type } { New-Item -Path $PersistItemPath -ItemType $Type -Value $Content | Out-Null }
        }
    }
}

function Backup-PersistItem {
    <#
    .SYNOPSIS
        Backup items to persist directory.

    .PARAMETER AppDir
        Path of app directory.

    .PARAMETER PersistDir
        Path of persist directory.

    .PARAMETER Name
        Name of item to backup.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $AppDir,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $PersistDir,
        [Parameter(Mandatory = $true, Position = 2)]
        [string] $Name
    )

    $ItemArray = $Name.Split(",").Trim()

    foreach ($Item in $ItemArray) {
        $ItemPath = Join-Path -Path $AppDir -ChildPath $Item
        $PersistItemPath = Join-Path -Path $PersistDir -ChildPath $Item

        if (-not(Test-Path $ItemPath)) {
            continue
        }

        if (Test-Path $PersistItemPath) {
            Remove-Item -Path $PersistItemPath -Force -Recurse
        }

        Copy-Item -Path $ItemPath -Destination $PersistDir -Force -Recurse -ErrorAction SilentlyContinue
    }
}

Export-ModuleMember `
    -Function `
    New-ProfileModifier, `
    Add-ProfileContent, `
    Remove-ProfileContent, `
    Mount-ExternalRuntimeData, `
    Dismount-ExternalRuntimeData, `
    Import-PersistItem, `
    New-PersistItem, `
    Backup-PersistItem
