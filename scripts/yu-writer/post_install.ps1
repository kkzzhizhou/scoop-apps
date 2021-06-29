$dir = "."
$file = "$dir\Yu Writer\bootstrap.config"
$content = Get-Content $file
$content = $content.Replace("`"portableMode`": false", "`"portableMode`": true")
Set-Content $file -Value $content
