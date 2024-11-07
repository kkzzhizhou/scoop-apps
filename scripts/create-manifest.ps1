$name = $args[0]
if ($args.Count -eq 2) {
    Write-Host 'Please use only one argument'; Break
}
Copy-Item "$PSScriptRoot\..\template.json" "$PSScriptRoot\..\bucket\$name.json" -Force
