# Runtime tests for the persist_external hook scope contract.
# Canonical hooks dot-source the script and call the functions bare; the functions must
# resolve $dir, $persist_dir and $manifest from the calling hook scope. Manifests saved by
# older installs still pass the same values as -Manifest/-Dir/-PersistDir and must work.
# Runs offline: uses temp folders and junctions only.
#
# Helpers live in BeforeAll: Pester 5 does not expose file-scope functions inside It bodies.


Describe 'persist_external hook scope contract' {

    BeforeAll {

        function New-PersistExternalFixture {
            $root = Join-Path ([System.IO.Path]::GetTempPath()) ('pe-runtime-' + [guid]::NewGuid().ToString('N'))
            $fixture = [pscustomobject]@{
                Root       = $root
                Dir        = Join-Path $root 'apps\pe-test-app\1.0.0'
                PersistDir = Join-Path $root 'persist'
                Source     = Join-Path $root 'external\pe-test-app'
                Target     = Join-Path (Join-Path $root 'persist') 'pe-test-app'
                Manifest   = $null
            }
            New-Item -ItemType Directory -Path $fixture.Dir -Force | Out-Null
            New-Item -ItemType Directory -Path $fixture.Source -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $fixture.Source 'data.txt') -Value 'payload'
            $fixture.Manifest = [pscustomobject]@{
                description      = 'pe-test-app'
                persist_external = $fixture.Source
            }
            $fixture
        }

        function Remove-PersistExternalFixture {
            param($Fixture)
            $link = Get-Item -LiteralPath $Fixture.Source -Force -ErrorAction SilentlyContinue
            if ($link -and $link.LinkType) {
                if ($link.PSIsContainer) { [System.IO.Directory]::Delete($Fixture.Source) }
                else { [System.IO.File]::Delete($Fixture.Source) }
            }
            Remove-Item -LiteralPath $Fixture.Root -Recurse -Force -ErrorAction SilentlyContinue
        }

        function Get-FixtureLinkTarget {
            param($Fixture)
            $item = Get-Item -LiteralPath $Fixture.Source -Force
            $target = @($item.Target)[0] -replace '^\\\\\?\\', ''
            [System.IO.Path]::GetFullPath($target)
        }

        function Invoke-FixtureHook {
            param(
                [Parameter(Mandatory)]$Fixture,
                [Parameter(Mandatory)][string]$Call,
                [bool]$IncludeScope = $true,
                [hashtable]$Arguments = @{},
                [string[]]$OmitScope = @()
            )
            & {
                param($Fixture, $Call, $IncludeScope, $Arguments, $OmitScope)
                function Select-CurrentVersion { }
                function add_alias { }
                function shimdir { Join-Path $Fixture.Root 'shims' }
                if ($IncludeScope) {
                    if ($OmitScope -notcontains 'dir') { $dir = $Fixture.Dir }
                    if ($OmitScope -notcontains 'persist_dir') { $persist_dir = $Fixture.PersistDir }
                    if ($OmitScope -notcontains 'manifest') { $manifest = $Fixture.Manifest }
                }
                . (Join-Path $PSScriptRoot 'persist-external.ps1')
                if ($Call -eq 'Install') {
                    Invoke-PersistExternalInstall @Arguments
                } else {
                    Invoke-PersistExternalUninstall @Arguments
                }
            } $Fixture $Call $IncludeScope $Arguments $OmitScope
        }
    }

    Context 'canonical bare calls' {

        It 'Install reads $dir/$persist_dir/$manifest from the hook scope' {
            $fx = New-PersistExternalFixture
            try {
                Invoke-FixtureHook -Fixture $fx -Call 'Install'
                (Get-Item -LiteralPath $fx.Source -Force).LinkType | Should -Be 'Junction'
                Get-FixtureLinkTarget -Fixture $fx |
                    Should -Be ([System.IO.Path]::GetFullPath($fx.Target))
                Test-Path -LiteralPath (Join-Path $fx.Target 'data.txt') | Should -BeTrue
                Test-Path -LiteralPath (Join-Path $fx.PersistDir '.scoop-persist-external.json') | Should -BeTrue
            } finally {
                Remove-PersistExternalFixture -Fixture $fx
            }
        }

        It 'Uninstall reads the same variables and removes the link only' {
            $fx = New-PersistExternalFixture
            try {
                Invoke-FixtureHook -Fixture $fx -Call 'Install'
                Invoke-FixtureHook -Fixture $fx -Call 'Uninstall'
                Test-Path -LiteralPath $fx.Source | Should -BeFalse
                Test-Path -LiteralPath (Join-Path $fx.Target 'data.txt') | Should -BeTrue
                Test-Path -LiteralPath (Join-Path $fx.PersistDir '.scoop-persist-external.json') | Should -BeFalse
            } finally {
                Remove-PersistExternalFixture -Fixture $fx
            }
        }
    }

    Context 'legacy calls from manifests saved by older installs' {

        It 'Install accepts -Manifest/-PersistDir/-Dir' {
            $fx = New-PersistExternalFixture
            try {
                Invoke-FixtureHook -Fixture $fx -Call 'Install' -IncludeScope $false -Arguments @{
                    Manifest   = $fx.Manifest
                    PersistDir = $fx.PersistDir
                    Dir        = $fx.Dir
                }
                Get-FixtureLinkTarget -Fixture $fx |
                    Should -Be ([System.IO.Path]::GetFullPath($fx.Target))
            } finally {
                Remove-PersistExternalFixture -Fixture $fx
            }
        }

        It 'Uninstall accepts -Manifest/-Dir with $persist_dir from the hook scope' {
            $fx = New-PersistExternalFixture
            try {
                Invoke-FixtureHook -Fixture $fx -Call 'Install'
                Invoke-FixtureHook -Fixture $fx -Call 'Uninstall' -Arguments @{
                    Manifest = $fx.Manifest
                    Dir      = $fx.Dir
                }
                Test-Path -LiteralPath $fx.Source | Should -BeFalse
            } finally {
                Remove-PersistExternalFixture -Fixture $fx
            }
        }
        It 'Uninstall accepts -Manifest/-Dir/-PersistDir' {
            $fx = New-PersistExternalFixture
            try {
                Invoke-FixtureHook -Fixture $fx -Call 'Install'
                Invoke-FixtureHook -Fixture $fx -Call 'Uninstall' -IncludeScope $false -Arguments @{
                    Manifest   = $fx.Manifest
                    Dir        = $fx.Dir
                    PersistDir = $fx.PersistDir
                }
                Test-Path -LiteralPath $fx.Source | Should -BeFalse
            } finally {
                Remove-PersistExternalFixture -Fixture $fx
            }
        }

    }

    Context 'degraded hook scope' {

        It 'Uninstall resolves $persist_dir from -Dir when neither the caller nor the scope provides it' {
            $fx = New-PersistExternalFixture
            try {
                Invoke-FixtureHook -Fixture $fx -Call 'Install'
                $resolved = Join-Path (Join-Path $fx.Root 'persist') 'pe-test-app'
                New-Item -ItemType Directory -Path $resolved -Force | Out-Null
                Move-Item -LiteralPath (Join-Path $fx.PersistDir '.scoop-persist-external.json') `
                    -Destination (Join-Path $resolved '.scoop-persist-external.json')
                Invoke-FixtureHook -Fixture $fx -Call 'Uninstall' -OmitScope 'persist_dir'
                Test-Path -LiteralPath $fx.Source | Should -BeFalse
            } finally {
                Remove-PersistExternalFixture -Fixture $fx
            }
        }

        It 'Install fails when the hook scope lacks $persist_dir' {
            $fx = New-PersistExternalFixture
            try {
                { Invoke-FixtureHook -Fixture $fx -Call 'Install' -OmitScope 'persist_dir' } |
                    Should -Throw '*$persist_dir is not defined*'
            } finally {
                Remove-PersistExternalFixture -Fixture $fx
            }
        }

        It 'Uninstall fails when the hook scope lacks $dir' {
            $fx = New-PersistExternalFixture
            try {
                { Invoke-FixtureHook -Fixture $fx -Call 'Uninstall' -OmitScope 'dir' } |
                    Should -Throw '*$dir is not defined*'
            } finally {
                Remove-PersistExternalFixture -Fixture $fx
            }
        }
    }

    Context 'missing hook scope' {

        It 'Install fails with a message naming the missing variable' {
            $fx = New-PersistExternalFixture
            try {
                { Invoke-FixtureHook -Fixture $fx -Call 'Install' -IncludeScope $false } |
                    Should -Throw '*$manifest is not defined*'
            } finally {
                Remove-PersistExternalFixture -Fixture $fx
            }
        }
    }
}
