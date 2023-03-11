$component = ([string]$app).Substring(12)
$target_dir = "$(persistdir android-sdk-base $global)\$component"

Get-ChildItem "$target_dir\*" | ForEach-Object {
    attrib -r $_.FullName /l
    Remove-Item -Path $_.FullName -Recurse -Force
}
