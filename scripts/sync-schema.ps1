<#
    sync-schema.ps1
    ---------------
    Builds the manifest schema used by Scoop-Bucket.Tests.ps1.

    Fetches the official Scoop schema (master) at test time and injects the
    bucket-specific `persist_external` property, so the bucket no longer holds
    a static schema copy that drifts from upstream. See docs/adr/0001.

    Usage:
        .\scripts\sync-schema.ps1 -TargetPath <path>

    Behaviour:
      - Fetch OK            -> write injected schema to TargetPath
      - Fetch fail + cache  -> reuse the previously written injected schema, warn
      - Fetch fail, no cache-> throw (test chain fails loudly)
#>

param(
    [Parameter(Mandatory = $true)][string]$TargetPath,
    [string]$OfficialUrl = 'https://raw.githubusercontent.com/ScoopInstaller/Scoop/master/schema.json'
)

$ErrorActionPreference = 'Stop'

function Get-InjectedSchemaText {
    param([string]$JsonUrl)

    $tmp = Join-Path $env:TEMP "official-schema-$([guid]::NewGuid().ToString('N')).json"
    try {
        & curl.exe -fsSL --retry 3 $JsonUrl -o $tmp
        if ($LASTEXITCODE -ne 0) { throw "curl exited with code $LASTEXITCODE" }

        $schema = Get-Content -LiteralPath $tmp -Raw | ConvertFrom-Json
        $properties = $schema.properties
        if (-not ($properties.PSObject.Properties.Name -contains 'persist_external')) {
            $properties | Add-Member -NotePropertyName 'persist_external' `
                -NotePropertyValue @{ '$ref' = '#/definitions/stringOrArrayOfStringsOrAnArrayOfArrayOfStrings' } `
                -Force
        }
        return ($schema | ConvertTo-Json -Depth 20)
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

$targetDir = Split-Path $TargetPath -Parent
if ($targetDir -and -not (Test-Path -LiteralPath $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

try {
    $json = Get-InjectedSchemaText -JsonUrl $OfficialUrl
    [System.IO.File]::WriteAllText($TargetPath, $json, [System.Text.Encoding]::UTF8)
    Write-Host "sync-schema: wrote injected schema to '$TargetPath'"
} catch {
    if ((Test-Path -LiteralPath $TargetPath) -and
        ([System.IO.File]::ReadAllText($TargetPath).Contains('persist_external'))) {
        Write-Warning "sync-schema: fetch failed ($($_.Exception.Message)); reusing cached injected schema at '$TargetPath'"
        exit 0
    } else {
        throw "sync-schema: failed to fetch '$OfficialUrl' and no usable injected cache at '$TargetPath': $($_.Exception.Message)"
    }
}
