BeforeAll {
    . (Join-Path $PSScriptRoot 'persist-external.ps1')
}

Describe 'persist_external reconcile' {
    BeforeEach {
        $root = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        $persistDir = Join-Path $root 'persist'
        $dir = Join-Path $root 'apps/demo/1.0'
        New-Item -ItemType Directory -Path $persistDir, $dir -Force | Out-Null

        $srcA = Join-Path $TestDrive 'src-a'
        $srcB = Join-Path $TestDrive 'src-b'
        $srcC = Join-Path $TestDrive 'src-c'

        $manifest = [pscustomobject]@{
            persist_external = @(
                @($srcA, 'a', 'directory'),
                @($srcB, 'b', 'file')
            )
        }

        $recordPath = Join-Path $persistDir '.scoop-persist-external.json'
        $legacyPath = Join-Path $dir '.scoop-persist-external.json'

        Mock New-ExternalPersistLink { 'Junction' }
        Mock Remove-ReparsePointSafe { $true }
        Mock Write-Warning { }
    }

    It 'writes the record into the persist dir, not the version dir' {
        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir

        $recordPath | Should -Exist
        $legacyPath | Should -Not -Exist

        $records = [array](Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json)
        $records.Count | Should -Be 2
        $records.Source | Should -Contain $srcA
        $records.Target | Should -Contain (Join-Path $persistDir 'a')
    }

    It 'keeps the record at the declared set on repeat runs' {
        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir
        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir

        $records = [array](Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json)
        $records.Count | Should -Be 2
        Should -Invoke Remove-ReparsePointSafe -Times 0
    }

    It 'migrates a legacy record from the version dir and unlinks dropped entries' {
        @(
            @{ Source = $srcA; Target = Join-Path $persistDir 'a'; LinkType = 'Junction' },
            @{ Source = $srcC; Target = Join-Path $persistDir 'c'; LinkType = 'Junction' }
        ) | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $legacyPath

        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir

        $legacyPath | Should -Not -Exist
        $records = [array](Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json)
        $records.Count | Should -Be 2
        $records.Source | Should -Not -Contain $srcC
        Should -Invoke Remove-ReparsePointSafe -Times 1 -ParameterFilter { $Path -eq $srcC }
    }

    It 'unlinks recorded links and deletes the record in remove mode' {
        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir
        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir -Remove

        Should -Invoke Remove-ReparsePointSafe -Times 2
        $recordPath | Should -Not -Exist
    }

    It 'falls back to the manifest when no record exists' {
        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir -Remove

        Should -Invoke Remove-ReparsePointSafe -Times 2
        Should -Invoke Write-Warning -ParameterFilter { $Message -like '*record*' }
    }

    It 'keeps linking the remaining entries when one link fails' {
        Mock New-ExternalPersistLink {
            if ($Source -eq $srcB) { throw 'boom' }
            'Junction'
        }

        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir -ErrorAction SilentlyContinue

        Should -Invoke New-ExternalPersistLink -Times 2
        $records = [array](Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json)
        $records.Count | Should -Be 1
        $records.Source | Should -Contain $srcA
    }

    It 'removes both records when the manifest stops declaring persist_external' {
        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir
        Copy-Item -LiteralPath $recordPath -Destination $legacyPath
        $empty = [pscustomobject]@{ persist_external = @() }

        Invoke-PersistExternalReconcile -Manifest $empty -PersistDir $persistDir -Dir $dir

        Should -Invoke Remove-ReparsePointSafe -Times 2
        $recordPath | Should -Not -Exist
        $legacyPath | Should -Not -Exist
    }

    It 'drops the stale record but keeps the legacy one when every link fails' {
        $ErrorActionPreference = 'Stop'
        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir
        Copy-Item -LiteralPath $recordPath -Destination $legacyPath
        Mock New-ExternalPersistLink { throw 'boom' }

        { Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir } | Should -Not -Throw

        $recordPath | Should -Not -Exist
        $legacyPath | Should -Exist
    }

    It 'records only the links it applied when one link fails' {
        $ErrorActionPreference = 'Stop'
        Mock New-ExternalPersistLink {
            if ($Source -eq $srcA) { throw 'boom' }
            'Junction'
        }

        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir

        $records = [array](Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json)
        $records.Count | Should -Be 1
        $records.Source | Should -Be $srcB
    }

    It 'falls back to the legacy record when the persist record is corrupt' {
        Set-Content -LiteralPath $recordPath -Value '{not json'
        @(
            @{ Source = $srcA; Target = Join-Path $persistDir 'a'; LinkType = 'Junction' }
        ) | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $legacyPath

        Invoke-PersistExternalUninstall -Manifest $manifest -Dir $dir -PersistDir $persistDir

        Should -Invoke Remove-ReparsePointSafe -Times 1 -ParameterFilter { $Path -eq $srcA }
    }

    It 'warns about unmapped persist items but not about the record file' {
        New-Item -ItemType Directory -Path (Join-Path $persistDir 'stray') -Force | Out-Null

        Invoke-PersistExternalReconcile -Manifest $manifest -PersistDir $persistDir -Dir $dir

        Should -Invoke Write-Warning -Times 1 -ParameterFilter { $Message -like '*unmapped*' }
    }

    It 'writes the record through the install entry point' {
        Mock Initialize-PersistExternalAlias { }

        Invoke-PersistExternalInstall -Manifest $manifest -PersistDir $persistDir -Dir $dir

        $recordPath | Should -Exist
    }

    It 'uninstall without -PersistDir resolves the persist dir from -Dir' {
        @(
            @{ Source = $srcA; Target = Join-Path $persistDir 'a'; LinkType = 'Junction' }
        ) | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $legacyPath

        Invoke-PersistExternalUninstall -Manifest $manifest -Dir $dir

        Should -Invoke Remove-ReparsePointSafe -Times 1 -ParameterFilter { $Path -eq $srcA }
    }
}

Describe 'Remove-ReparsePointSafe' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'persist-external.ps1')
    }

    It 'leaves real data untouched' {
        $real = Join-Path $TestDrive 'real.txt'
        Set-Content -LiteralPath $real -Value 'data'

        Remove-ReparsePointSafe -Path $real | Should -BeFalse
        $real | Should -Exist
    }
}
