param(
    [Parameter(Mandatory)]
    $Path,
    [Parameter(Mandatory=$false)]
    $Depth = 20
    )

$colItems = (Get-ChildItem $Path | Measure-Object -property length -sum)
"{0} -- {1:N2} MB" -f $Path, ($colItems.sum / 1MB)

$colItems = (Get-ChildItem $Path -recurse -Depth $Depth | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object)
foreach ($i in $colItems)
{
    $subFolderItems = (Get-ChildItem $i.FullName | Measure-Object -property length -sum)
    "{0} -- {1:N2} MB" -f $i.FullName, ($subFolderItems.sum / 1MB)
}