#Requires -Version 5.1

function New-ProfileModifier {
    <#
    .SYNOPSIS
        Generate scripts which modifies PowerShell profile.

    .PARAMETER Type
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
        [string] $Type,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $Name,
        [Parameter(Mandatory = $true, Position = 2)]
        [string] $BucketDir,
        [Parameter(Mandatory = $false, Position = 3)]
        [string] $ModuleName
    )

    $SupportedType = @("ImportModule", "RemoveModule")

    if ($SupportedType -notcontains $Type) {
        Write-Host "[ERROR] Unsupported type." -ForegroundColor Red
        Return
    }

    if (-not($ModuleName)) {
        $ModuleName = $Name
    }

    $S4UtilsPath = $BucketDir | Join-Path -ChildPath "\scripts\S4Utils.psm1"
    $ScoopDir = Split-Path $BucketDir | Split-Path
    $AppDir = $ScoopDir | Join-Path -ChildPath "\apps\$Name\current\"

    $ImportUtilsCommand = ("Import-Module ", $S4UtilsPath) -Join("")
    $RemoveUtilsCommand = "Remove-Module -Name S4Utils -ErrorAction SilentlyContinue"

    $ImportModuleCommand = ("Add-ProfileContent 'Import-Module ", $ModuleName, "'") -Join("")
    $RemoveModuleCommand = ("Remove-ProfileContent 'Import-Module ", $ModuleName, "'") -Join("")

    switch ($Type) {
        {$_ -eq "ImportModule"} {
            $GenerateContent = ($ImportUtilsCommand, $RemoveModuleCommand, $ImportModuleCommand, $RemoveUtilsCommand) -Join("`r`n")
            $GenerateContent | Set-Content -Path "$AppDir\add-profile-content.ps1"
        }
        {$_ -eq "RemoveModule"} {
            $GenerateContent = ($ImportUtilsCommand, $RemoveModuleCommand, $RemoveUtilsCommand) -Join("`r`n")
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

    ($RawProfile -replace "[\r\n]*$Content",'').trim() | Set-Content $PROFILE -NoNewLine
}

function Mount-ExternalRuntimeData {
    <#
    .SYNOPSIS
        Mount external runtime data.

    .PARAMETER Source
        The source path, which is the persist_dir.

    .PARAMETER Target
        The target path, which is the actual path app uses to access the runtime data.

    .PARAMETER AppData
        Use this parameter if target folder locates in $env:APPDATA using the name of persisted folder.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("Persist")]
        [string] $Source,
        [Parameter(Mandatory = $false, Position = 1)]
        [string] $Target,
        [Parameter(Mandatory = $false, Position = 2)]
        [switch] $AppData
    )

    if (-not($Target -or $AppData)) {
        Write-Host "[ERROR] Specify a mount point." -ForegroundColor Red
        Return
    }

    if($AppData) {
        $Name = Split-Path -Path $Source -Leaf
        if ($Target) {
            Write-Host "[WARN] Overwriting `$Target value..." -ForegroundColor DarkYellow
        }
        $Target = Join-Path -Path $env:APPDATA -ChildPath $Name
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

    .PARAMETER Path
        Name or path of runtime folder, which is the actual path app uses to access the runtime data.

    .PARAMETER AppData
        Use this parameter if target folder locates in $env:APPDATA using the name of persisted folder.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("Name","Target")]
        [string] $Path,
        [Parameter(Mandatory = $false, Position = 1)]
        [switch] $AppData
    )

    if ($AppData) {
        $Name = Split-Path -Path $Path -Leaf
        $Path = Join-Path -Path $env:APPDATA -ChildPath $Name
    }

    Write-Host "Dismounting runtime cache..."

    if (Test-Path $Path) {
        Remove-Item $Path -Force -Recurse
    }
    else {
        Write-Host "[ERROR] Invalid path, continue without dismounting." -ForegroundColor Red
    }
}

Export-ModuleMember `
    -Function `
        New-ProfileModifier, `
        Add-ProfileContent, `
        Remove-ProfileContent, `
        Mount-ExternalRuntimeData, `
        Dismount-ExternalRuntimeData
