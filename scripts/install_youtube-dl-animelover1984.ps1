python3.exe -m pip install requests mutagen websockets git+https://github.com/animelover1984/youtube-dl

Get-Command -Name "pip.exe" |
Select-Object -ExpandProperty Source |
Split-Path -Parent |
Get-ChildItem -LiteralPath { $_ } -File |
Where-Object { $_.Name -in "youtube-dl.exe", "youtube-dl-script.py" } |
ForEach-Object {
    $aRenameFile = $_
    $aNewName = $aRenameFile.Name -replace 'youtube-dl', 'youtube-dl-animelover1984'

    Rename-Item -LiteralPath $aRenameFile.FullName -NewName $aNewName
}

Write-Host "The exe file name is youtube-dl-animelover1984.exe."
