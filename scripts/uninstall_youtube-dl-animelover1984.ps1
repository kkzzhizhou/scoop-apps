pip uninstall youtube-dl -y

Get-Command -Name "pip.exe" |
Select-Object -ExpandProperty Source |
Split-Path -Parent |
Get-ChildItem -LiteralPath { $_ } -File |
Where-Object { $_.Name -in "youtube-dl-animelover1984.exe", "youtube-dl-animelover1984-script.py" } |
Remove-Item -LiteralPath { $_.FullName }
