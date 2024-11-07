. "$bucketsdir\$bucket\setup.ps1"

Get-ChildItem -Path "$dir\$component" | ForEach-Object {
    $source = "$target_dir\$($_.Name)"

    if ($_.PSIsContainer) {
        New-Item -Path $source -ItemType Junction -Value $_ -Force
        attrib +r $source /l
    } else {
        New-Item -Path $source -ItemType HardLink -Value $_ -Force
    }
}
