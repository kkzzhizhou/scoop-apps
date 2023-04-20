$output = & "${env:SCOOP_HOME}\bin\checkver.ps1" -Dir bucket 6>&1
$app    = $null
$newver = $null
$curver = $null

$updatables = @("__NONE__")

foreach ($line in $output) {
    if ($curver -ne $null) {
        if ($line -match '^ autoupdate available$') {
            $updatables += "$app"
            $app    = $null
            $newver = $null
            $curver = $null
        } else {
            Write-Host "Unexpected output: $line"
            exit 1
        }
        continue
    }
    if ($newver -ne $null) {
        if ($line -match '\(scoop version is ([-\w\d.]+)\)') {
            $curver = $Matches.1

        } elseif ($line -match '^([\w-]+): $') {
            $app    = $Matches.1
            $newver = $null
        } else {
            Write-Host "Unexpected output: $line"
            exit 1
        }
        continue
    }
    if ($app -ne $null) {
        $newver = $line
        continue
    }
    if ($line -match '^([\w-]+): $') {
        $app = $Matches.1
        continue
    }
    Write-Host "Unexpected output: $line"
    exit 1
}

$json = (ConvertTo-JSON -Compress $updatables)

"apps<<EOF`n$json`nEOF`n" | Out-File -NoNewline -Encoding utf8 -Append $env:GITHUB_OUTPUT
