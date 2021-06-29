Write-Output "Disabling built-in auto update since it's managed by scoop"

$configFileName = 'SimpleDnsCrypt.exe.config'
$configFile = "$dir\$configFileName"
[xml]$configFileContent = Get-Content "$configFile"

foreach ($item in $configFileContent.configuration.userSettings.'SimpleDnsCrypt.Properties.Settings'.setting) {
  if ($item.name -eq 'AutoUpdate') {
    $item.value = 'False'
  }
}

Copy-Item "$configFile" "$configFile.backup"
$configFileContent.Save("$configFile")
