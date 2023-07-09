#Requires -Version 5.1

function New-ProfileModifier {
    <#
    .SYNOPSIS
        Generate scripts which modifies PowerShell profile.

    .PARAMETER Behavior
        Type of scripts to generate.

    .PARAMETER Name
        Name of manifest.

    .PARAMETER BucketDir
        Path of Scoop4kariiin bucket root directory.

    .PARAMETER ModuleName
        Use this parameter if module name differs from manifest name.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("Type")]
        [string] $Behavior,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $Name,
        [Parameter(Mandatory = $true, Position = 2)]
        [string] $BucketDir,
        [Parameter(Mandatory = $false, Position = 3)]
        [string] $ModuleName
    )

    $SupportedBehavior = @("ImportModule", "RemoveModule")

    if ($SupportedBehavior -notcontains $Behavior) {
        Write-Host "[ERROR] Unsupported behavior." -ForegroundColor Red
        Return
    }

    if (-not($ModuleName)) {
        $ModuleName = $Name
    }

    $S4UtilsPath = $BucketDir | Join-Path -ChildPath "\scripts\S4Utils.psm1"
    $ScoopDir = Split-Path $BucketDir | Split-Path
    $AppDir = $ScoopDir | Join-Path -ChildPath "\apps\$Name\current\"

    $ImportUtilsCommand = ("Import-Module ", $S4UtilsPath) -Join ("")
    $RemoveUtilsCommand = "Remove-Module -Name S4Utils -ErrorAction SilentlyContinue"

    $ImportModuleCommand = ("Add-ProfileContent 'Import-Module ", $ModuleName, "'") -Join ("")
    $RemoveModuleCommand = ("Remove-ProfileContent 'Import-Module ", $ModuleName, "'") -Join ("")

    switch ($Behavior) {
        { $_ -eq "ImportModule" } {
            $GenerateContent = ($ImportUtilsCommand, $RemoveModuleCommand, $ImportModuleCommand, $RemoveUtilsCommand) -Join ("`r`n")
            $GenerateContent | Set-Content -Path "$AppDir\add-profile-content.ps1"
        }
        { $_ -eq "RemoveModule" } {
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
    }
    else {
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
    }
    else {
        Write-Host "[ERROR] Invalid target, continue without dismounting." -ForegroundColor Red
    }
}

Export-ModuleMember `
    -Function `
    New-ProfileModifier, `
    Add-ProfileContent, `
    Remove-ProfileContent, `
    Mount-ExternalRuntimeData, `
    Dismount-ExternalRuntimeData
