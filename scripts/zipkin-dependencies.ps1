$scoopDir = (scoop which scoop).split("scoop\apps")[0] + "/scoop"
$dir = Convert-Path ($scoopDir + "/apps/zipkin-dependencies/current/")
(Get-ChildItem -Path $dir -Filter *.jar)[0].name -match "\d[\d.]+\d" | Out-Null
$version = $Matches[0]
$jarPath = $dir + "zipkin-dependencies-$version.jar"
if (!$env:STORAGE_TYPE) {
    $env:STORAGE_TYPEE = 'elasticsearch'
}
if (!$env:ES_HOSTS) {
    $env:ES_HOSTS = '127.0.0.1:9200'
}
java -jar $jarPath
