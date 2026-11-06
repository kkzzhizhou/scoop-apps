# Facts are resolved at discovery time and handed to each It as plain values:
# Pester 5 does not expose file-scope variables inside It bodies.
#
# References whose path contains a runtime value (e.g. scripts/${app}/$_) are skipped.

$repoRoot = Split-Path $PSScriptRoot -Parent
$deprecatedDir = 'deprecated'
$manifestDirs = 'bucket', $deprecatedDir
$referencePattern = "(?<path>(?:$deprecatedDir[\\/]+)?scripts[\\/]+[A-Za-z0-9._\\/-]+)"
$hookKeys = 'pre_install', 'post_install', 'pre_uninstall', 'post_uninstall'
$scriptKeys = 'installer', 'uninstaller'

$manifestFiles = @(foreach ($dir in $manifestDirs) {
    Get-ChildItem -LiteralPath (Join-Path $repoRoot $dir) -Filter '*.json'
})
$referenceCases = @()
$seen = [System.Collections.Generic.HashSet[string]]::new()

foreach ($file in $manifestFiles) {
    $manifestLabel = "$(Split-Path $file.DirectoryName -Leaf)/$($file.Name)"
    $manifest = [System.IO.File]::ReadAllText($file.FullName) | ConvertFrom-Json
    $scopes = @($manifest)
    foreach ($arch in $manifest.architecture.PSObject.Properties) { $scopes += $arch.Value }

    foreach ($scope in $scopes) {
        $texts = @()
        foreach ($key in $hookKeys) {
            $texts += @($scope.$key | Where-Object { $_ -is [string] })
        }
        foreach ($key in $scriptKeys) {
            $texts += @($scope.$key.script | Where-Object { $_ -is [string] })
        }

        foreach ($text in $texts) {
            foreach ($match in [regex]::Matches($text, $referencePattern)) {
                $reference = $match.Groups['path'].Value.TrimEnd('\', '/') -replace '[\\/]+', '/'
                if (-not $seen.Add("$manifestLabel|$reference")) { continue }
                $referenceCases += @{
                    Name      = $manifestLabel
                    Reference = $reference
                    Exists    = Test-Path -LiteralPath (Join-Path $repoRoot $reference)
                }
            }
        }
    }
}

$deprecatedManifests = @($manifestFiles | Where-Object { $_.Directory.Name -eq $deprecatedDir }).Count
$coverageCases = @(@{ Manifests = $manifestFiles.Count; Deprecated = $deprecatedManifests; References = $referenceCases.Count })

Describe 'manifest script references' {

    It 'finds literal script references to check (<Manifests> manifests, <Deprecated> deprecated, <References> references)' -TestCases $coverageCases {
        param($Manifests, $Deprecated, $References)
        $Manifests | Should -BeGreaterThan 0
        $Deprecated | Should -BeGreaterThan 0
        $References | Should -BeGreaterThan 0
    }

    It '<Name>: <Reference> exists in this bucket' -TestCases $referenceCases {
        param($Name, $Reference, $Exists)
        $Exists | Should -BeTrue
    }
}
