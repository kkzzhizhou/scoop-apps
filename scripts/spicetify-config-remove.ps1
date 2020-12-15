$spicetify_config = "$env:USERPROFILE\.spicetify\config.ini"

if (Test-Path "$spicetify_config") {
    $regex = '('
    $regex += $args[0]
    $regex += '.*)\|?'
    $regex += $args[1] -replace '\.', '\.'
    $regex += '\|?(.*)'

    $content = (Get-Content "$spicetify_config") -replace $regex, '$1$2'
    [System.IO.File]::WriteAllLines($spicetify_config, $content) # UTF-8 no BOM is required
}
