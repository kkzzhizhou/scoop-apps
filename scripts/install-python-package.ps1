# Usage: install-python-package [options]
# Summary: Installs a Python package using setup.py
# Help: For example, to globally install a Python package from Git:
#       install-python-package --global --dir keyring --repo https://github.com/jaraco/keyring.git --clone-dir keyring
#
# Installed files are recorded in "installed_files.txt" in the setup directory.
#
# Options:
#   -h, --help                Show this help message
#   -g, --global              Install globally
#   -q, --quiet               Minimise output
#   -d, --dir <dir>           The setup directory
#   -r, --repo <url>          Git repository URL
#   -b, --branch <branch>     Git repository branch
#   -c, --clone-dir <name>    Git clone directory name

$scoop_lib = "$(Split-Path (Split-Path (scoop which scoop)))\lib"
. "$scoop_lib\getopt.ps1"
. "$scoop_lib\help.ps1"

$opt, $null, $err = getopt $args 'hgqd:r:b:c:' 'help', 'global', 'quiet', 'dir=', 'repo=', 'branch=', 'clone-dir='

if ($err) {
    Write-Host "$err`n$(my_usage)`ninstall-python-package --help for for more information" -ForegroundColor Red
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
$quiet = $opt.q -or $opt.quiet

if ($opt.d) { $directory = $opt.d }
elseif ($opt.dir) { $directory = $opt.dir }
else { $directory = '.' }

if ($opt.r) { $repository = $opt.r }
else { $repository = $opt.repo }

if ($opt.b) { $branch = $opt.b }
elseif ($opt.branch) { $branch = $opt.branch }
else { $branch = 'master' }

if ($opt.c) { $clone_directory = $opt.c }
elseif ($opt.'clone-dir') { $clone_directory = $opt.'clone-dir' }
else { $clone_directory = 'package' }

if (-not (Get-Command -ErrorAction Ignore python)) {
    Write-Host "Python is not installed" -ForegroundColor Red
    exit 1
}

if ($repository) {
    if (-not (Get-Command -ErrorAction Ignore git)) {
        Write-Host "Git is not installed"
        exit 1
    }

    if ($quiet) { git clone --quiet -c advice.detachedHead=false --branch $branch $repository "$directory\$clone_directory" }
    else { git clone -c advice.detachedHead=false --branch $branch $repository "$directory\$clone_directory" }

    Push-Location "$directory\$clone_directory"
} else {
    Push-Location $directory
}

if (-not (Test-Path 'setup.py')) {
    Write-Host "setup.py not found" -ForegroundColor Red
    exit 1
}

if (Test-Path 'bootstrap.py') { python bootstrap.py }

if ($global) {
    if ($quiet) { python setup.py --quiet install --record "$directory\installed_files.txt" }
    else { python setup.py install --record "$directory\installed_files.txt" }
} else {
    if ($quiet) { python setup.py --quiet install --user --record "$directory\installed_files.txt" }
    else { python setup.py install --user --record "$directory\installed_files.txt" }
}

Pop-Location
