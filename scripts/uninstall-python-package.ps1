# Usage: uninstall-python-package <name> [options]
# Summary: Uninstalls a Python package installed using install-python-package
# Help: For example, to uninstall a Python package installed globally using install-python-package:
#       uninstall-python-package --global --dir keyring
#
# Options:
#   -h, --help                Show this help message
#   -g, --global              Uninstall a global package
#   -d, --dir <dir>           The setup directory
#   -m, --match <pattern>     Pattern that specifies which files to remove

$scoop_lib = "$(Split-Path (Split-Path (scoop which scoop)))\lib"
. "$scoop_lib\getopt.ps1"
. "$scoop_lib\help.ps1"

$opt, $name, $err = getopt $args 'hgd:r:b:c:m:' 'help', 'global', 'dir=', 'match='

if ($err) {
    Write-Host "$err`n$(my_usage)`nuninstall-python-package --help for for more information" -ForegroundColor Red
    exit 1
}

if ($opt.h -or $opt.help) {
    # scoop_help removes the '#' character at the start of each line along with the whitespace
    # character that follows, but if that whitespace character is a newline because it's just
    # an empty line, then that empty line is completely removed.
    # To combat that, we add a space to all lines that are just a '#'.
    $content = (Get-Content $PSCommandPath -Raw) -replace '(?ms)^#$', '# '
    $usage = usage $content
    $help = scoop_help $content
    return "$usage`n`n$help"
}

$global = $opt.g -or $opt.global

if ($opt.d) { $directory = $opt.d }
elseif ($opt.dir) { $directory = $opt.dir }
else { $directory = '.' }

$name = $name.TrimEnd('-py')

if ($opt.m) { $match = $opt.m }
elseif ($opt.match) { $match = $opt.match }
else { $match = ".*$name.*" }

(Get-Content -ErrorAction Ignore "$directory\installed_files.txt") -match $match | Remove-Item -ErrorAction Ignore -Force

if (Get-Command -ErrorAction Ignore python) {
    if ($global) { $site_packages = "$(Split-Path (scoop which python))\lib\site-packages" }
    else { $site_packages = python -m site --user-site }
    Get-ChildItem -ErrorAction Ignore "$site_packages\$name-*-py*.egg" | ForEach-Object { Remove-Item -ErrorAction Ignore -Force -Recurse $_ }
}
