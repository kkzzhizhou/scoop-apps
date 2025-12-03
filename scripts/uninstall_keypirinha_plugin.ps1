$packageName = '{0}.keypirinha-package' -f ($app -replace '^keypirinha-', '')
$packageDir = '{0}/../portable/Profile/Packages' -f (PSWinUtil\Find-Path -Name 'keypirinha.exe' -Program -Strict)
Remove-Item -LiteralPath ('{0}/{1}' -f $packageDir, $packageName)
