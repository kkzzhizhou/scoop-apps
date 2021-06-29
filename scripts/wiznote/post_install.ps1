$dir = "."
$file = "$dir\Wiz.ini"
$content = Get-Content $file
$content = $content.Replace("Portable=0", "Portable=1")
Set-Content $file -Value $content
