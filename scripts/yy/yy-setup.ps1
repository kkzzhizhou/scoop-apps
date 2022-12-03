param(
    $app_dir,
    $app_version
)

$app = "$app_dir\$app_version"
$data = "$env:APPDATA\duowan\yy\"

$components =
"com.yy.cefdev2",
"com.yy.gameproxy",
"com.yy.processservice",
"com.yy.videoservice",
"com.yy.vip"

$junks =
"BugReport.exe",
"crashreport.dll",
"dwupdate.dll",
"installstat.exe",
"p2ppunch.dll",
"preloadexternalproxy.dll",
"RoVee.dll",
"udbreportsdk.dll",
"videotools.dll",
"widgetchannel.dll",
"YY.exe",
"yyacc.dll",
"yyaccessiblehelper.dll",
"yyadhelper.dll",
"yybrowser.exe",
"yychappplatform.dll",
"yyiecontainer.dll",
"yyp2pproxy.dll",
"yyp2psrv.exe",
"yyp2pvideohandler.dll",
"yypersonalfont.dll",
"yyplugin.dll",
"yyrun.exe",
"yysdkcontainer.dll",
"yystatistics.dll",
"yyversion.dll",
"yyvoicechanger.dll"

foreach ($junk in $junks) {
    Remove-Item "$app\$junk" -Force
}

foreach ($component in $components) {
    Remove-Item "$app\components\$component" -Force -Recurse
    New-Item "$app\components\$component" -Force | Out-Null
    (Get-Item "$app\components\$component").Attributes = "Readonly"
}

if (Test-Path $data) {
    $t = Get-ChildItem -Path $data | Where-Object { $_.Name -ne "mainframe" }
    if ($t) {
        Remove-Item $t.FullName -Force -Recurse
    }
}

$data_re =
"log",
"update"

foreach ($i in $data_re) {
    New-Item "$data\$i" -Force | Out-Null
    (Get-Item "$data\$i").Attributes = "Readonly"
}
