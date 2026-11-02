# Contract tests for the persist_external hooks as written into bucket manifests.
# The manifest is the interface users install with; a hook string that names a
# missing function or parameter fails at scoop install time, so the contract is
# pinned here, in CI. Runs offline: reads only bucket/*.json and the script AST.
#
# Facts are resolved at discovery time and handed to each It as plain values:
# Pester 5 does not expose file-scope variables inside It bodies.

$repoRoot = Split-Path $PSScriptRoot -Parent

function Get-PersistExternalFunctions {
    param([string]$FilePath)
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$tokens, [ref]$errors)
    if ($errors.Count -gt 0) { throw "Failed to parse $FilePath" }
    $map = @{}
    foreach ($fn in $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)) {
        if ($fn.Name -notlike 'Invoke-PersistExternal*') { continue }
        $map[$fn.Name] = @($fn.Body.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })
    }
    return $map
}

function Get-ManifestStageText {
    param($Manifest)
    $all = @($Manifest.pre_install) + @($Manifest.installer) + @($Manifest.post_install) +
        @($Manifest.pre_uninstall) + @($Manifest.uninstaller) + @($Manifest.post_uninstall)
    return ([string]::Join("`n", @($all | Where-Object { $_ -is [string] })))
}

$fnMap = Get-PersistExternalFunctions -FilePath (Join-Path $PSScriptRoot 'persist-external.ps1')

$dotSourceCases = @()
$functionCases = @()
$declaredCases = @()

foreach ($file in Get-ChildItem -LiteralPath (Join-Path $repoRoot 'bucket') -Filter '*.json') {
    $manifest = [System.IO.File]::ReadAllText($file.FullName) | ConvertFrom-Json
    $stageText = Get-ManifestStageText -Manifest $manifest
    $hooks = @([regex]::Matches($stageText, 'Invoke-PersistExternal\w+[^\n"]*') | ForEach-Object { $_.Value })

    if ($hooks.Count -gt 0) {
        $dotSourceCases += @{
            Name         = $file.Name
            HasDotSource = [bool]($stageText -match 'scripts[\\/]+persist-external\.ps1')
        }
    }

    foreach ($hook in $hooks) {
        $fnName = [regex]::Match($hook, 'Invoke-PersistExternal\w+').Value
        $declaredParams = if ($fnMap.ContainsKey($fnName)) { $fnMap[$fnName] } else { @() }
        $badParams = @(
            foreach ($m in [regex]::Matches($hook, '(?<=\s)-(?<param>\w+)')) {
                if ($m.Groups['param'].Value -notin $declaredParams) { $m.Groups['param'].Value }
            }
        )
        $functionCases += @{
            Name      = $file.Name
            Hook      = $hook
            FnExists  = $fnMap.ContainsKey($fnName)
            BadParams = $badParams
        }
    }

    if ($null -ne $manifest.persist_external) {
        $declaredCases += @{
            Name        = $file.Name
            HasInstall  = [bool]($stageText -match 'Invoke-PersistExternalInstall')
            HasUninstall = [bool]($stageText -match 'Invoke-PersistExternalUninstall')
        }
    }
}

$coverageCases = @(@{ HookManifests = $dotSourceCases.Count; DeclaredManifests = $declaredCases.Count })

Describe 'persist_external hook contract' {

    It 'finds hooks to check (<HookManifests> manifests, <DeclaredManifests> declaring persist_external)' -TestCases $coverageCases {
        param($HookManifests, $DeclaredManifests)
        $HookManifests | Should -BeGreaterThan 0
        $DeclaredManifests | Should -BeGreaterThan 0
    }

    Context 'hook strings resolve to the script' {

        It '<Name>: dot-sources persist-external.ps1' -TestCases $dotSourceCases {
            param($Name, $HasDotSource)
            $HasDotSource | Should -BeTrue
        }

        It '<Name>: <Hook> calls a function the script defines' -TestCases $functionCases {
            param($Name, $Hook, $FnExists)
            $FnExists | Should -BeTrue
        }

        It '<Name>: <Hook> passes only declared parameters' -TestCases $functionCases {
            param($Name, $Hook, $BadParams)
            $BadParams | Should -BeNullOrEmpty -Because "undeclared: $($BadParams -join ', ')"
        }
    }

    Context 'persist_external manifests carry both hooks' {

        It '<Name>: declares Install and Uninstall hooks' -TestCases $declaredCases {
            param($Name, $HasInstall, $HasUninstall)
            $HasInstall | Should -BeTrue
            $HasUninstall | Should -BeTrue
        }
    }
}
