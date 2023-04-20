$scoopDir = (scoop which scoop).split("scoop\apps")[0] + "/scoop"
$appDir = $scoopDir + "/apps/activemq-classic"
$dir = $appDir + "/current"
$i = 10
while (!(Test-Path $dir) -and ($i -gt 0)) {
    Start-Sleep 1
    $i--
}
$manifestPath = $dir + "/manifest.json"
$manifest = Get-Content -Path $manifestPath -Encoding UTF8 | ConvertFrom-Json
$originalDir = $appDir + "/" + $manifest.version
if ((Get-Item $dir).LinkType -eq "Junction") {
    Remove-Item $dir -Force -Recurse
    Copy-Item $originalDir $dir -Recurse
}
