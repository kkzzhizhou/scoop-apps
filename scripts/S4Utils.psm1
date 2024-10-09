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
        "ImportModule" {
            $GenerateContent = ($ImportUtilsCommand, $RemoveModuleCommand, $ImportModuleCommand, $RemoveUtilsCommand) -Join ("`r`n")
            $GenerateContent | Set-Content -Path "$AppDir\add-profile-content.ps1"
        }
        "RemoveModule" {
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
        [Alias("Value")]
        [string] $Content
    )

    if (-not(Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -ItemType File -Value "$Content" -Force | Out-Null
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
        New-Item -Path $Source -ItemType Directory -Force | Out-Null
        if (Test-Path $Target) {
            Write-Host "Found existing runtime cache, moving to persist folder..."
            Get-ChildItem $Target | Copy-Item -Destination $Source -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    if (Test-Path $Target) {
        Remove-Item $Target -Force -Recurse
    }

    Write-Host "Mounting runtime cache..."

    New-Item -Path $Target -ItemType Junction -Target $Source -Force | Out-Null
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

    .PARAMETER ConflictAction
        Actions when item conflicts.

    .PARAMETER Select
        Specific items to import.

    .PARAMETER Sync
        Create junction instead of copying files.

    .PARAMETER Backup
        Rename original item instead of removing it.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $PersistDir,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $SourceApp,
        [Parameter(Mandatory = $false, Position = 2)]
        [string] $ConflictAction = "Skip",
        [Parameter(Mandatory = $false, Position = 3)]
        [string] $Select,
        [Parameter(Mandatory = $false, Position = 4)]
        [switch] $Sync,
        [Parameter(Mandatory = $false, Position = 5)]
        [switch] $Backup
    )

    $SupportedConfAct = @("ReplaceDir", "Overwrite", "Mix", "Skip")

    if ($SupportedConfAct -notcontains $ConflictAction) {
        Write-Host "`n[ERROR] Unsupported conflict action." -ForegroundColor Red
        return
    }

    $ScoopPersistDir = Split-Path -Path $PersistDir -Parent
    $SourcePath = Join-Path -Path $ScoopPersistDir -ChildPath $SourceApp
    $TargetPath = $PersistDir

    if (-not(Test-Path $SourcePath)) {
        return
    }

    if (Test-Path $TargetPath) {
        switch ($ConflictAction) {
            "ReplaceDir" {
                if ($Backup) {
                    Backup-SelectItem -Path $TargetPath
                } else {
                    Remove-Item -Path $TargetPath -Force -Recurse
                }
            }
            "Skip" { return }
            default {
                if ($Sync) {
                    return
                }
            }
        }
    }

    if ($Sync) {
        Write-Host "`nImporting profiles from `'$SourceApp`' in synced mode..." -ForegroundColor Yellow
        New-Item -Path $TargetPath -ItemType Junction -Target $SourcePath -Force | Out-Null
        if ($?) {
            Write-Host "Succeeded! DO NOT permanently uninstall `'$SourceApp`'." -ForegroundColor Green
        }
        return
    }

    Write-Host "`nImporting profiles from `'$SourceApp`'..." -ForegroundColor Yellow

    if (-not(Test-Path $TargetPath)) {
        New-Item -Path $TargetPath -ItemType Directory -Force | Out-Null
    }

    if ($Select) {
        $SelectArray = $Select.Split(",").Trim()
    } else {
        $SelectArray = Get-ChildItem -Path $SourcePath | Select-Object -ExpandProperty Name
    }

    switch ($ConflictAction) {
        "Overwrite" {
            if ($Backup) {
                foreach ($SelectItem in $SelectArray) {
                    Import-SelectItem -SourceLocation $SourcePath -TargetLocation $TargetPath -Name $SelectItem -Overwrite -Backup
                }
            } else {
                foreach ($SelectItem in $SelectArray) {
                    Import-SelectItem -SourceLocation $SourcePath -TargetLocation $TargetPath -Name $SelectItem -Overwrite
                }
            }
        }
        default {
            if ($Backup) {
                foreach ($SelectItem in $SelectArray) {
                    Import-SelectItem -SourceLocation $SourcePath -TargetLocation $TargetPath -Name $SelectItem -Backup
                }
            } else {
                foreach ($SelectItem in $SelectArray) {
                    Import-SelectItem -SourceLocation $SourcePath -TargetLocation $TargetPath -Name $SelectItem
                }
            }
        }
    }

    Write-Host "Succeeded! You can uninstall `'$SourceApp`' now." -ForegroundColor Green
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
        [Alias("Value")]
        [string] $Content = $null,
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

    $ItemArray = $Name.Split(",").Trim()

    foreach ($Item in $ItemArray) {
        $PersistItemPath = Join-Path -Path $PersistDir -ChildPath $Item

        if (Test-Path $PersistItemPath) {
            if ($Force) {
                if ($Backup) {
                    Backup-SelectItem -Path $PersistItemPath
                } else {
                    Remove-Item -Path $PersistItemPath -Force -Recurse
                }
            } else {
                continue
            }
        }

        switch ($Type) {
            "Directory" { New-Item -Path $PersistItemPath -ItemType $Type -Force | Out-Null }
            "File" { New-Item -Path $PersistItemPath -ItemType $Type -Value $Content -Force | Out-Null }
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

function Import-SelectItem {
    <#
    .SYNOPSIS
        Import item to specific location.

    .PARAMETER SourceLocation
        Location of source item.

    .PARAMETER TargetLocation
        Location of target.

    .PARAMETER Name
        Name of selected item.

    .PARAMETER Overwrite
        Overwrite target item when conflict.

    .PARAMETER Backup
        Backup file before overwriting.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $SourceLocation,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $TargetLocation,
        [Parameter(Mandatory = $true, Position = 2)]
        [string] $Name,
        [Parameter(Mandatory = $false, Position = 3)]
        [switch] $Overwrite,
        [Parameter(Mandatory = $false, Position = 4)]
        [switch] $Backup
    )

    $SourceItem = Join-Path -Path $SourceLocation -ChildPath $Name
    $TargetItem = Join-Path -Path $TargetLocation -ChildPath $Name

    if (-not(Test-Path $SourceItem)) {
        return
    }

    if (Test-Path $TargetItem) {
        if ($Overwrite) {
            if ($Backup) {
                Backup-SelectItem -Path $TargetItem
            } else {
                Remove-Item $TargetItem -Force -Recurse
            }
        } else {
            return
        }
    }

    Copy-Item -Path $SourceItem -Destination $TargetLocation -Force -Recurse -ErrorAction SilentlyContinue
}

function Backup-SelectItem {
    <#
    .SYNOPSIS
        Backup specific item by renaming with suffix '.backup'.

    .PARAMETER Path
        Path of item to backup.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Path
    )

    if (-not(Test-Path $Path)) {
        return
    }

    $ItemName = Split-Path -Path $Path -Leaf
    $ItemLocation = Split-Path -Path $Path -Parent
    $BackupItemName = ($ItemName, "backup") -Join (".")
    $BackupItemPath = Join-Path -Path $ItemLocation -ChildPath $BackupItemName

    if (Test-Path $BackupItemPath) {
        Remove-Item -Path $BackupItemPath -Force -Recurse
    }

    Rename-Item -Path $Path -NewName $BackupItemName -Force
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
