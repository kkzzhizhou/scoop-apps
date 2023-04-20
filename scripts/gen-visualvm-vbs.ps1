$scoopDir = (scoop which scoop).split("scoop\apps")[0] + "\scoop"
$appDir = $scoopDir + "\apps\visualvm"
$dir = Convert-Path ($appDir + "\current")
$exe = "$dir\bin\visualvm.exe"

$vbs = @"
Option Explicit
dim shell
set shell = WScript.createobject("wscript.shell")

shell.run "$exe --jdkhome %JAVA_HOME%", 0
"@

$vbs | Out-File -Encoding ASCII "$dir\bin\visualvm.vbs"
