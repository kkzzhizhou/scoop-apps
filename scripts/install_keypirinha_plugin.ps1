$packageName = '{0}.keypirinha-package' -f ($app -replace '^keypirinha-', '')
$packageDir = '{0}/../portable/Profile/Packages' -f (PSWinUtil\Find-Path -Name 'keypirinha.exe' -Program -Strict)
Move-Item -LiteralPath ('{0}/{1}' -f $dir, $packageName) -Destination $packageDir
