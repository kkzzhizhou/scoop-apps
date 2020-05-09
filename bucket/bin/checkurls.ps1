if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }
$checkurls = "$env:SCOOP_HOME/bin/checkurls.ps1"
$bucket = "$psscriptroot/.." # checks the parent dir
Invoke-Expression -command "& '$checkurls' -dir '$bucket' $($args | ForEach-Object { "$_ " })"
