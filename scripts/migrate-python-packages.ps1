# Usage: migrate-python-packages [apps] [options]
# Summary: Migrate packages installed from the python bucket to newer versions of Python
# Help: For example, to migrate grip-py and httpie-py globally:
#       migrate-python-packages grip-py httpie-py --global
#
# To migrate all packages installed locally from the python bucket:
#       migrate-python-packages
#
# Packages installed globally from the python bucket will need to be migrated for any Python update.
# Locally installed packages will need to be migrated for any minor or major Python update.
#
# Options:
#   -h, --help                Show this help message
#   -g, --global              Migrate globally installed packages
#   -q, --quiet               Do not write package names to console
#   -v, --verbose             Display all output

$scoop_lib = "$(Split-Path (Split-Path (scoop which scoop)))\lib"
. "$scoop_lib\buckets.ps1"
. "$scoop_lib\getopt.ps1"
. "$scoop_lib\help.ps1"

$opt, $apps, $err = getopt $args 'hgqv' 'help', 'global', 'quiet', 'verbose'

if ($err) {
    Write-Host "$err`n$(my_usage)`nmigrate-python-packages --help for for more information" -ForegroundColor Red
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
$verbose = $opt.v -or $opt.verbose

if (-not (Get-Command -ErrorAction Ignore python)) {
    Write-Host "Python is not installed" -ForegroundColor Red
    exit 1
}

$current_version = (python --version) -replace 'Python ', ''
$local_lib = Split-Path (python -m site --user-site)

function migrate_global($app, $directory) {
    if (-not $quiet) { Write-Host "Migrating $app (global)" -ForegroundColor Cyan }

    if (-not (Test-Path "$directory\setup.py")) { Push-Location "$directory\$app" }
    else { Push-Location $directory }

    if (Test-Path 'bootstrap.py') { python bootstrap.py }
    if ($verbose) { python setup.py install --record "$directory\installed_files.txt" }
    else { python setup.py --quiet install --record "$directory\installed_files.txt" }

    Pop-Location
}

function migrate_global_if_necessary($app, $directory, $lib) {
    $installed_version = Split-Path (Split-Path $lib) -Leaf
    if ($installed_version -ne $current_version) { migrate_global $app $directory }
    elseif (-not $quiet) { Write-Host "$app (global) does not need to be migrated" -ForegroundColor Magenta }
}

function migrate_local($app, $directory) {
    if (-not $quiet) { Write-Host "Migrating $app" -ForegroundColor Cyan }

    if (-not (Test-Path "$directory\setup.py")) { Push-Location "$directory\$app" }
    else { Push-Location $directory }

    if (Test-Path 'bootstrap.py') { python bootstrap.py }
    if ($verbose) { python setup.py install --user --record "$directory\installed_files.txt" }
    else { python setup.py --quiet install --user --record "$directory\installed_files.txt" }

    Pop-Location
}

function migrate_local_if_necessary($app, $directory, $lib) {
    if ($lib -ne $local_lib) { migrate_local $app $directory }
    elseif (-not $quiet) { Write-Host "$app does not need to be migrated" -ForegroundColor Magenta }
}

function migrate_if_necessary($app, $directory) {
    $site_packages = Get-Content "$directory\installed_files.txt" -First 1

    if ($site_packages -and (Test-Path $site_packages)) {
        $lib = $site_packages -replace '\\site-packages.*', ''
        if ($global) { migrate_global_if_necessary $app $directory $lib }
        else { migrate_local_if_necessary $app $directory $lib }
        return
    }

    if ($global) { migrate_global $app $directory }
    else { migrate_local $app $directory }
}

if (-not $apps) { $apps = apps_in_bucket (Find-BucketDirectory python) }

foreach ($app in $apps) {
    $directory = appdir $app $true
    if ((Test-Path "$directory\current\setup.py") -or (Test-Path "$directory\current\$app\setup.py")) { migrate_if_necessary $app "$directory\current" }
}
