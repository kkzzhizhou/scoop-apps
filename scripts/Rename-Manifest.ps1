<#
.SYNOPSIS
    Renames Scoop manifests and updates Scoop installation state, persisted data, and references.

.DESCRIPTION
    Rename-Manifest.ps1 renames one or more Scoop app manifests within a Scoop bucket.
    It optionally uninstalls the old app, renames the manifest file, updates references
    in depend/suggest fields across other manifests in the bucket, renames persisted data,
    and reinstalls the renamed app under its new name.

.PARAMETER OldName
    The current manifest name (without .json extension).

.PARAMETER NewName
    The new manifest name (without .json extension).

.PARAMETER RenameMap
    A hashtable or ordered dictionary mapping old manifest names to new manifest names.

.PARAMETER Bucket
    The name of the Scoop bucket. Defaults to 'turbo'.

.PARAMETER BucketDir
    The root path of the Scoop bucket directory. Defaults to '$env:SCOOP\buckets\$Bucket' or '$HOME\scoop\buckets\$Bucket'.

.PARAMETER UpdateManifestReferences
    Whether to update exact references in 'depends' and 'suggest' fields across bucket manifests. Defaults to $true.

.EXAMPLE
    .\scripts\Rename-Manifest.ps1 -OldName "imageglass-beta" -NewName "imageglass-edge"

.EXAMPLE
    .\scripts\Rename-Manifest.ps1 -RenameMap @{ 'app-beta' = 'app-edge'; 'tool-preview' = 'tool-edge' }
#>

[CmdletBinding(DefaultParameterSetName = 'Single')]
param(
    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Single')]
    [ValidateNotNullOrEmpty()]
    [string] $OldName,

    [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Single')]
    [ValidateNotNullOrEmpty()]
    [string] $NewName,

    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Batch')]
    [Alias('Rename', 'Map')]
    [System.Collections.IDictionary] $RenameMap,

    [string] $Bucket = 'turbo',

    [string] $BucketDir,

    [bool] $UpdateManifestReferences = $true
)

$ErrorActionPreference = 'Stop'

if ($PSCmdlet.ParameterSetName -eq 'Single') {
    $Rename = [ordered]@{ $OldName = $NewName }
} else {
    $Rename = $RenameMap
}

# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------

$ScoopRoot = if ($env:SCOOP) {
    $env:SCOOP
} else {
    Join-Path $HOME 'scoop'
}

if ([string]::IsNullOrWhiteSpace($BucketDir)) {
    $BucketDir = Join-Path $ScoopRoot "buckets\$Bucket"
}

$AppsDir    = Join-Path $ScoopRoot 'apps'
$PersistDir = Join-Path $ScoopRoot 'persist'

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupDir = Join-Path $ScoopRoot "manifest-rename-backup-$Timestamp"

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# ------------------------------------------------------------
# HELPERS
# ------------------------------------------------------------

function Invoke-Scoop {
    param(
        [Parameter(Mandatory)]
        [string[]] $Arguments
    )

    $global:LASTEXITCODE = 0
    & scoop @Arguments

    if (-not $? -or $LASTEXITCODE -ne 0) {
        throw "Scoop command failed: scoop $($Arguments -join ' ')"
    }
}

function Test-ScoopAppInstalled {
    param(
        [Parameter(Mandatory)]
        [string] $Name
    )

    $global:LASTEXITCODE = 0
    & scoop prefix $Name *> $null

    return ($? -and $LASTEXITCODE -eq 0)
}

function Find-Manifest {
    param(
        [Parameter(Mandatory)]
        [string] $Name
    )

    $Candidates = @(
        (Join-Path $BucketDir "bucket\$Name.json"),
        (Join-Path $BucketDir "$Name.json")
    ).Where({ Test-Path -LiteralPath $_ })

    if ($Candidates.Count -eq 0) {
        throw "Cannot find manifest for '$Name' in '$BucketDir'."
    }

    if ($Candidates.Count -gt 1) {
        throw "Multiple manifests found for '$Name': $($Candidates -join ', ')"
    }

    return (Convert-Path -LiteralPath $Candidates[0])
}

function Move-ManifestFile {
    param(
        [Parameter(Mandatory)]
        [string] $Source,

        [Parameter(Mandatory)]
        [string] $Destination
    )

    # Handle case-only renames on case-insensitive filesystems.
    if ($Source -ieq $Destination) {
        $Temporary = "$Source.rename-temporary"
        Move-Item -LiteralPath $Source -Destination $Temporary
        Move-Item -LiteralPath $Temporary -Destination $Destination
    } else {
        Move-Item -LiteralPath $Source -Destination $Destination
    }
}

function Resolve-RenamedAppReference {
    param(
        [AllowNull()]
        [object] $Value
    )

    if ($Value -isnot [string]) {
        return $Value
    }

    foreach ($OldName in $Rename.Keys) {
        $NewName = [string] $Rename[$OldName]

        if ($Value -ceq $OldName) {
            return $NewName
        }

        if ($Value -ceq "$Bucket/$OldName") {
            return "$Bucket/$NewName"
        }

        if ($Value -ceq "$Bucket\$OldName") {
            return "$Bucket\$NewName"
        }
    }

    return $Value
}

# ------------------------------------------------------------
# PREFLIGHT
# ------------------------------------------------------------

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    throw 'The scoop command was not found.'
}

if (-not (Test-Path -LiteralPath $BucketDir)) {
    throw "Bucket directory not found: $BucketDir"
}

if ($Rename.Count -eq 0) {
    throw 'The rename mapping is empty.'
}

$DuplicateDestinations = $Rename.Values |
    Group-Object |
    Where-Object Count -gt 1

if ($DuplicateDestinations) {
    throw "Duplicate destination names: $($DuplicateDestinations.Name -join ', ')"
}

$Pairs = foreach ($OldName in $Rename.Keys) {
    $NewName = [string] $Rename[$OldName]

    if ([string]::IsNullOrWhiteSpace($OldName) -or
        [string]::IsNullOrWhiteSpace($NewName)) {
        throw 'Manifest names cannot be empty.'
    }

    if ($OldName -ceq $NewName) {
        throw "'$OldName' maps to itself."
    }

    $OldManifest = Find-Manifest -Name $OldName
    $NewManifest = Join-Path (
        Split-Path -Parent $OldManifest
    ) "$NewName.json"

    $SamePathIgnoringCase =
        [IO.Path]::GetFullPath($OldManifest) -ieq
        [IO.Path]::GetFullPath($NewManifest)

    if ((Test-Path -LiteralPath $NewManifest) -and
        -not $SamePathIgnoringCase) {
        throw "Destination manifest already exists: $NewManifest"
    }

    if (Test-ScoopAppInstalled -Name $NewName) {
        throw "Destination app '$NewName' is already installed."
    }

    $OldPersist = Join-Path $PersistDir $OldName
    $NewPersist = Join-Path $PersistDir $NewName

    if ((Test-Path -LiteralPath $OldPersist) -and
        (Test-Path -LiteralPath $NewPersist)) {
        throw "Both persist directories exist: '$OldPersist' and '$NewPersist'."
    }

    [pscustomobject]@{
        OldName      = $OldName
        NewName      = $NewName
        OldManifest  = $OldManifest
        NewManifest  = $NewManifest
        WasInstalled = Test-ScoopAppInstalled -Name $OldName
        OldPersist   = $OldPersist
        NewPersist   = $NewPersist
    }
}

# ------------------------------------------------------------
# PREPARE REFERENCE CHANGES
# ------------------------------------------------------------

$PlannedEdits = @()

if ($UpdateManifestReferences) {
    foreach ($File in Get-ChildItem -LiteralPath $BucketDir -Recurse -File -Filter '*.json') {
        $OriginalText = [IO.File]::ReadAllText($File.FullName)
        $Manifest = $OriginalText | ConvertFrom-Json
        $Changed = $false

        if ($Manifest.PSObject.Properties.Name -contains 'depends') {
            $OriginalValue = $Manifest.depends
            $OriginalWasArray = $OriginalValue -is [array]

            $NewValues = @(
                foreach ($Value in @($OriginalValue)) {
                    $NewValue = Resolve-RenamedAppReference -Value $Value

                    if ($NewValue -cne $Value) {
                        $Changed = $true
                    }

                    $NewValue
                }
            )

            $Manifest.depends = if ($OriginalWasArray) {
                $NewValues
            } else {
                $NewValues[0]
            }
        }

        if (($Manifest.PSObject.Properties.Name -contains 'suggest') -and
            $null -ne $Manifest.suggest) {
            foreach ($Property in @($Manifest.suggest.PSObject.Properties)) {
                $OriginalValue = $Property.Value
                $OriginalWasArray = $OriginalValue -is [array]

                $NewValues = @(
                    foreach ($Value in @($OriginalValue)) {
                        $NewValue = Resolve-RenamedAppReference -Value $Value

                        if ($NewValue -cne $Value) {
                            $Changed = $true
                        }

                        $NewValue
                    }
                )

                $Property.Value = if ($OriginalWasArray) {
                    $NewValues
                } else {
                    $NewValues[0]
                }
            }
        }

        if ($Changed) {
            $NewText = (
                $Manifest | ConvertTo-Json -Depth 100
            ) + [Environment]::NewLine

            $PlannedEdits += [pscustomobject]@{
                Path         = $File.FullName
                OriginalText = $OriginalText
                NewText      = $NewText
            }
        }
    }
}

# ------------------------------------------------------------
# BACKUP
# ------------------------------------------------------------

New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

$MappingText = $Rename.GetEnumerator() |
    ForEach-Object { "$($_.Key) -> $($_.Value)" }

[IO.File]::WriteAllLines(
    (Join-Path $BackupDir 'mapping.txt'),
    [string[]] $MappingText,
    $Utf8NoBom
)

$global:LASTEXITCODE = 0
$ScoopExport = & scoop export

if ($? -and $LASTEXITCODE -eq 0) {
    [IO.File]::WriteAllLines(
        (Join-Path $BackupDir 'scoop-export.json'),
        [string[]] $ScoopExport,
        $Utf8NoBom
    )
}

# Back up every JSON manifest without copying the bucket's .git directory.
$ManifestBackupDir = Join-Path $BackupDir 'bucket-json'

foreach ($File in Get-ChildItem -LiteralPath $BucketDir -Recurse -File -Filter '*.json') {
    $RelativePath = $File.FullName.
        Substring($BucketDir.Length).
        TrimStart([char] '\', [char] '/')

    $Destination = Join-Path $ManifestBackupDir $RelativePath
    $DestinationParent = Split-Path -Parent $Destination

    New-Item -ItemType Directory -Path $DestinationParent -Force |
        Out-Null

    Copy-Item -LiteralPath $File.FullName -Destination $Destination
}

Write-Host ''
Write-Host "Backup created: $BackupDir"
Write-Host ''

# ------------------------------------------------------------
# MIGRATION
# ------------------------------------------------------------

$UninstalledOld = @()
$MovedPersist   = @()
$RenamedFiles   = @()

try {
    # Uninstall only apps that were installed before the rename.
    foreach ($Pair in $Pairs | Where-Object WasInstalled) {
        Write-Host "Uninstalling $($Pair.OldName)..."
        Invoke-Scoop -Arguments @('uninstall', $Pair.OldName)
        $UninstalledOld += $Pair
    }

    # Update exact depends/suggest references.
    foreach ($Edit in $PlannedEdits) {
        Write-Host "Updating references in $($Edit.Path)..."
        [IO.File]::WriteAllText(
            $Edit.Path,
            $Edit.NewText,
            $Utf8NoBom
        )
    }

    # Rename all manifests before reinstalling anything.
    foreach ($Pair in $Pairs) {
        Write-Host "Renaming $($Pair.OldName) -> $($Pair.NewName)..."

        Move-ManifestFile `
            -Source $Pair.OldManifest `
            -Destination $Pair.NewManifest

        $RenamedFiles += $Pair
    }

    # Rename persisted data directories.
    foreach ($Pair in $Pairs | Where-Object WasInstalled) {
        if (Test-Path -LiteralPath $Pair.OldPersist) {
            Write-Host "Moving persist data: $($Pair.OldName) -> $($Pair.NewName)..."

            Move-Item `
                -LiteralPath $Pair.OldPersist `
                -Destination $Pair.NewPersist

            $MovedPersist += $Pair
        }
    }

    # Reinstall the apps that were installed originally.
    foreach ($Pair in $Pairs | Where-Object WasInstalled) {
        Write-Host "Installing $Bucket/$($Pair.NewName)..."
        Invoke-Scoop -Arguments @(
            'install',
            "$Bucket/$($Pair.NewName)"
        )
    }

    Write-Host ''
    Write-Host 'Migration completed successfully.' -ForegroundColor Green
    Write-Host ''
    Write-Host 'Installed-name changes:'

    foreach ($Pair in $Pairs) {
        $State = if ($Pair.WasInstalled) {
            'reinstalled'
        } else {
            'manifest only'
        }

        Write-Host "  $($Pair.OldName) -> $($Pair.NewName) [$State]"
    }

    Write-Host ''
    Write-Host 'Review remaining references with:'
    Write-Host '$Rename.Keys | ForEach-Object {'
    Write-Host '    Get-ChildItem $BucketDir -Recurse -File |'
    Write-Host '        Select-String -SimpleMatch $_'
    Write-Host '}'
    Write-Host ''
    Write-Host 'Then review Git changes with:'
    Write-Host "git -C `"$BucketDir`" status --short"
}
catch {
    $OriginalFailure = $_

    Write-Warning "Migration failed: $($OriginalFailure.Exception.Message)"
    Write-Warning 'Attempting a best-effort rollback...'

    # Remove any newly installed destination apps.
    foreach ($Pair in $Pairs) {
        try {
            if (Test-ScoopAppInstalled -Name $Pair.NewName) {
                & scoop uninstall $Pair.NewName
            }
        } catch {
            Write-Warning "Could not uninstall '$($Pair.NewName)' during rollback."
        }
    }

    # Move persisted data back.
    for ($Index = $MovedPersist.Count - 1; $Index -ge 0; $Index--) {
        $Pair = $MovedPersist[$Index]

        try {
            if ((Test-Path -LiteralPath $Pair.NewPersist) -and
                -not (Test-Path -LiteralPath $Pair.OldPersist)) {
                Move-Item `
                    -LiteralPath $Pair.NewPersist `
                    -Destination $Pair.OldPersist
            }
        } catch {
            Write-Warning "Could not restore persist data for '$($Pair.OldName)'."
        }
    }

    # Restore old manifest filenames.
    for ($Index = $RenamedFiles.Count - 1; $Index -ge 0; $Index--) {
        $Pair = $RenamedFiles[$Index]

        try {
            if ((Test-Path -LiteralPath $Pair.NewManifest) -and
                -not (Test-Path -LiteralPath $Pair.OldManifest)) {
                Move-ManifestFile `
                    -Source $Pair.NewManifest `
                    -Destination $Pair.OldManifest
            }
        } catch {
            Write-Warning "Could not restore manifest '$($Pair.OldName)'."
        }
    }

    # Restore original dependency/suggestion contents.
    foreach ($Edit in $PlannedEdits) {
        try {
            [IO.File]::WriteAllText(
                $Edit.Path,
                $Edit.OriginalText,
                $Utf8NoBom
            )
        } catch {
            Write-Warning "Could not restore '$($Edit.Path)'."
        }
    }

    # Reinstall old app names.
    foreach ($Pair in $UninstalledOld) {
        try {
            if (-not (Test-ScoopAppInstalled -Name $Pair.OldName)) {
                & scoop install "$Bucket/$($Pair.OldName)"
            }
        } catch {
            Write-Warning "Could not reinstall '$($Pair.OldName)' during rollback."
        }
    }

    throw $OriginalFailure
}