$scoopDir = (scoop which scoop).split("scoop\apps")[0] + "/scoop"
$dir = Convert-Path ($scoopDir + "/apps/sentinel-dashboard/current/")
(Get-ChildItem -Path $dir -Filter *.jar)[0].name -match "\d[\d.]+\d" | Out-Null
$version = $Matches[0]
$customArgs = $args
if (!"$args".Contains("-Dserver.port=")) {
    $port = 8718
    $customArgs = "-Dserver.port=$port $args"
}
$jarPath = $dir + "sentinel-dashboard-$version.jar"
java $customArgs -jar $jarPath
