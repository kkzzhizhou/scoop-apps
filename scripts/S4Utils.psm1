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

    try {
        $S4UtilsPath = Join-Path -Path $BucketDir -ChildPath "\scripts\S4Utils.psm1" | Resolve-Path -ErrorAction Stop

        $ImportUtilsCommand = ("Import-Module ", $S4UtilsPath, " -ErrorAction Stop") -Join ("")
        $RemoveUtilsCommand = "Remove-Module -Name S4Utils -ErrorAction SilentlyContinue"

        $ImportModuleCommand = ("Add-ProfileContent 'Import-Module ", $PSModuleName, "'") -Join ("")
        $RemoveModuleCommand = ("Remove-ProfileContent 'Import-Module ", $PSModuleName, "'") -Join ("")

        $NewLine = [Environment]::NewLine
        switch ($Behavior) {
            "ImportModule" {
                $GenerateContent = ($ImportUtilsCommand, $RemoveModuleCommand, $ImportModuleCommand, $RemoveUtilsCommand) -Join ($NewLine)
                $GenerateContent | Set-Content -Path "$AppDir\add-profile-content.ps1" -Encoding UTF8
            }
            "RemoveModule" {
                $GenerateContent = ($ImportUtilsCommand, $RemoveModuleCommand, $RemoveUtilsCommand) -Join ($NewLine)
                $GenerateContent | Set-Content -Path "$AppDir\remove-profile-content.ps1" -Encoding UTF8
            }
        }
    } catch {
        Write-Host "[ERROR] Failed to generate script: $_" -ForegroundColor Red
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

    try {
        if (Test-Path $PROFILE) {
            $NewLine = [Environment]::NewLine
            Add-Content -Path $PROFILE -Value "$NewLine$Content" -Encoding UTF8 -NoNewLine
        } else {
            $Content | Out-File -FilePath $PROFILE -Encoding UTF8 -Force
        }
    } catch {
        Write-Host "[ERROR] Failed to add PowerShell profile content: $_" -ForegroundColor Red
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

    if (-not (Test-Path $PROFILE)) { return }

    try {
        $RawProfile = Get-Content -Path $PROFILE -raw

        if ($null -eq $RawProfile) { return }

        $escapedContent = [Regex]::Escape($Content)

        if ($RawProfile -match $escapedContent) {
            $modifiedProfile = ($RawProfile -replace "[\r\n]*$escapedContent", '').trim()
            $modifiedProfile | Set-Content $PROFILE -Encoding UTF8 -NoNewLine
        }
    } catch {
        Write-Host "[ERROR] Failed to remove PowerShell profile content: $_" -ForegroundColor Red
    }
}

function Mount-ExternalRuntimeData {
    <#
    .SYNOPSIS
        Mount external runtime data.

    .PARAMETER Source
        Path of source folder in scoop persist directory.

    .PARAMETER Target
        The actual path which app uses to access the runtime data. Conflicts with parameter AppData and LocalAppData.

    .PARAMETER AppData
        Mount in $env:APPDATA by the name of source folder. Conflicts with parameter Target and LocalAppData.

    .PARAMETER LocalAppData
        Mount in $env:LOCALAPPDATA by the name of source folder. Conflicts with parameter Target and AppData.
    #>
    [CmdletBinding(DefaultParameterSetName = "Target")]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("SourcePath", "Persist")]
        [string] $Source,
        [Parameter(Mandatory = $true, ParameterSetName = "Target", Position = 1)]
        [Alias("TargetPath", "Runtime")]
        [string] $Target,
        [Parameter(Mandatory = $true, ParameterSetName = "AppData")]
        [switch] $AppData,
        [Parameter(Mandatory = $true, ParameterSetName = "LocalAppData")]
        [switch] $LocalAppData
    )

    if (-not ($Target -or $AppData -or $LocalAppData)) {
        Write-Host "`n[ERROR] Specify a mount point." -ForegroundColor Red
        return
    }

    try {
        if ($AppData) {
            $RuntimeParent = $env:APPDATA
        }

        if ($LocalAppData) {
            $RuntimeParent = $env:LOCALAPPDATA
        }

        if ($RuntimeParent) {
            $FolderName = Split-Path -Path $Source -Leaf
            $Target = Join-Path -Path $RuntimeParent -ChildPath $FolderName
        }

        if (-not (Test-Path $Source)) {
            Write-Host "`nInitializing persist folder..." -ForegroundColor Yellow
            New-Item -Path $Source -ItemType Directory -Force | Out-Null
            if (Test-Path $Target) {
                Write-Host "Found existing runtime cache, moving to persist folder..." -ForegroundColor Yellow
                Get-ChildItem $Target | Copy-Item -Destination $Source -Force -Recurse -ErrorAction Stop
            }
        }

        if (Test-Path $Target) {
            Remove-Item $Target -Force -Recurse -ErrorAction Stop
        }

        Write-Host "`nMounting runtime cache..." -ForegroundColor Yellow

        New-Item -Path $Target -ItemType Junction -Target $Source -Force | Out-Null
    } catch {
        Write-Host "[ERROR] Failed to mount runtime cache: $_" -ForegroundColor Red
    }
}

function Dismount-ExternalRuntimeData {
    <#
    .SYNOPSIS
        Unmount external runtime data.

    .PARAMETER Target
        Path or name of runtime folder mounted by scoop.

    .PARAMETER AppData
        Dismount folder in $env:APPDATA with folder name in Target parameter. Parent path in $Target will be overwritten. Conflicts with parameter LocalAppData.

    .PARAMETER LocalAppData
        Dismount folder in $env:LOCALAPPDATA with folder name in Target parameter. Parent path in $Target will be overwritten. Conflicts with parameter AppData.
    #>
    [CmdletBinding(DefaultParameterSetName = "Target")]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Target", Position = 0)]
        [Parameter(Mandatory = $true, ParameterSetName = "AppData", Position = 0)]
        [Parameter(Mandatory = $true, ParameterSetName = "LocalAppData", Position = 0)]
        [Alias("TargetPath", "Path", "Name")]
        [string] $Target,
        [Parameter(Mandatory = $true, ParameterSetName = "AppData")]
        [switch] $AppData,
        [Parameter(Mandatory = $true, ParameterSetName = "LocalAppData")]
        [switch] $LocalAppData
    )

    try {
        if ($AppData) {
            $RuntimeParent = $env:APPDATA
        }

        if ($LocalAppData) {
            $RuntimeParent = $env:LOCALAPPDATA
        }

        if ($RuntimeParent) {
            $FolderName = Split-Path -Path $Target -Leaf
            $Target = Join-Path -Path $RuntimeParent -ChildPath $FolderName
        }

        Write-Host "`nDismounting runtime cache..." -ForegroundColor Yellow

        if (Test-Path $Target) {
            Remove-Item $Target -Force -Recurse -ErrorAction Stop
        } else {
            Write-Host "[ERROR] Invalid target, continue without dismounting." -ForegroundColor Red
        }
    } catch {
        Write-Host "[ERROR] Failed to dismount runtime cache: $_" -ForegroundColor Red
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
        [Parameter(Mandatory = $false)]
        [string] $ConflictAction = "Skip",
        [Parameter(Mandatory = $false)]
        [string[]] $Select,
        [Parameter(Mandatory = $false)]
        [switch] $Sync,
        [Parameter(Mandatory = $false)]
        [switch] $Backup
    )

    $SupportedConfAct = @("ReplaceDir", "Overwrite", "Mix", "Skip")

    if ($SupportedConfAct -notcontains $ConflictAction) {
        Write-Host "`n[ERROR] Unsupported conflict action." -ForegroundColor Red
        return
    }

    try {
        $ScoopPersistDir = Split-Path -Path $PersistDir -Parent
        $SourcePath = Join-Path -Path $ScoopPersistDir -ChildPath $SourceApp
        $TargetPath = $PersistDir

        if (-not (Test-Path $SourcePath)) { return }

        if (Test-Path $TargetPath) {
            switch ($ConflictAction) {
                "ReplaceDir" {
                    if ($Backup) {
                        Backup-SelectItem -Path $TargetPath
                    } else {
                        Remove-Item -Path $TargetPath -Force -Recurse -ErrorAction Stop
                    }
                }
                "Skip" { return }
                default {
                    if ($Sync) { return }
                }
            }
        }

        if ($Sync) {
            Write-Host "`nImporting profiles from `'$SourceApp`' in synced mode..." -ForegroundColor Yellow
            Mount-ExternalRuntimeData -Source $SourcePath -Target $TargetPath
            if ($?) {
                Write-Host "Succeeded!" -ForegroundColor Green
                Write-Host "DO NOT permanently uninstall `'$SourceApp`'!" -ForegroundColor Yellow
            }
            return
        }

        Write-Host "`nImporting profiles from `'$SourceApp`'..." -ForegroundColor Yellow

        if (-not (Test-Path $TargetPath)) {
            New-Item -Path $TargetPath -ItemType Directory -Force | Out-Null
        }

        if ($Select) {
            $SelectArray = $Select
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
    } catch {
        Write-Host "[ERROR] Failed to import persist data from `'$SourceApp`': $_" -ForegroundColor Red
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
        [Parameter(Mandatory = $false)]
        [Alias("Value")]
        [string] $Content = $null,
        [Parameter(Mandatory = $false)]
        [switch] $Force,
        [Parameter(Mandatory = $false)]
        [switch] $Backup
    )

    $SupportedType = @("Directory", "File")

    if ($SupportedType -notcontains $Type) {
        Write-Host "[ERROR] Unsupported type." -ForegroundColor Red
        return
    }

    try {
        $ItemArray = $Name.Split(",").Trim()

        foreach ($Item in $ItemArray) {
            $PersistItemPath = Join-Path -Path $PersistDir -ChildPath $Item

            if (Test-Path $PersistItemPath) {
                if ($Force) {
                    if ($Backup) {
                        Backup-SelectItem -Path $PersistItemPath
                    } else {
                        Remove-Item -Path $PersistItemPath -Force -Recurse -ErrorAction Stop
                    }
                } else { continue }
            }

            switch ($Type) {
                "Directory" { New-Item -Path $PersistItemPath -ItemType $Type -Force | Out-Null }
                "File" { New-Item -Path $PersistItemPath -ItemType $Type -Value $Content -Force | Out-Null }
            }
        }
    } catch {
        Write-Host "[ERROR] Failed to create persist item: $_" -ForegroundColor Red
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

    try {
        $ItemArray = $Name.Split(",").Trim()

        foreach ($Item in $ItemArray) {
            $ItemPath = Join-Path -Path $AppDir -ChildPath $Item
            $PersistItemPath = Join-Path -Path $PersistDir -ChildPath $Item

            if (-not (Test-Path $ItemPath)) { continue }

            if (Test-Path $PersistItemPath) {
                Remove-Item -Path $PersistItemPath -Force -Recurse -ErrorAction Stop
            }

            Copy-Item -Path $ItemPath -Destination $PersistDir -Force -Recurse -ErrorAction Stop
        }
    } catch {
        Write-Host "[ERROR] Failed to backup persist item: $_" -ForegroundColor Red
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
        [Parameter(Mandatory = $false)]
        [switch] $Overwrite,
        [Parameter(Mandatory = $false)]
        [switch] $Backup
    )

    try {
        $SourceItem = Join-Path -Path $SourceLocation -ChildPath $Name
        $TargetItem = Join-Path -Path $TargetLocation -ChildPath $Name

        if (-not (Test-Path $SourceItem)) { return }

        if (Test-Path $TargetItem) {
            if ($Overwrite) {
                if ($Backup) {
                    Backup-SelectItem -Path $TargetItem
                } else {
                    Remove-Item $TargetItem -Force -Recurse -ErrorAction Stop
                }
            } else { return }
        }

        Copy-Item -Path $SourceItem -Destination $TargetLocation -Force -Recurse -ErrorAction Stop
    } catch {
        Write-Host "[ERROR] Failed to import item: $_" -ForegroundColor Red
    }
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

    if (-not (Test-Path $Path)) { return }

    try {
        $ItemName = Split-Path -Path $Path -Leaf
        $ItemLocation = Split-Path -Path $Path -Parent
        $BackupItemName = ($ItemName, "backup") -Join (".")
        $BackupItemPath = Join-Path -Path $ItemLocation -ChildPath $BackupItemName

        if (Test-Path $BackupItemPath) {
            Remove-Item -Path $BackupItemPath -Force -Recurse -ErrorAction Stop
        }

        Rename-Item -Path $Path -NewName $BackupItemName -Force -ErrorAction Stop
    } catch {
        Write-Host "[ERROR] Failed to backup item: $_" -ForegroundColor Red
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
