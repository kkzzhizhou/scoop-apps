param (
    [string]$extras
)

Write-Host "Installing virtual environment... " -NoNewline

function Get-Python {
    if (Get-Command "py" -ErrorAction Ignore) {
        return "py"
    } elseif (Get-Command "python" -ErrorAction Ignore) {
        return "python"
    } elseif (Get-Command "python3" -ErrorAction Ignore) {
        return "python3"
    } else {
        Write-Host "Unable to find python distribution, try running 'scoop install python310-np'"
        exit 1
    }
}

& (Get-Python) -m venv "$dir\venv"

Write-Host "done." -Foreground Green

Write-Host "Installing dependencies... " -NoNewline

& "$dir\venv\Scripts\pip.exe" install "$dir$extras" -qq

Write-Host "done." -Foreground Green

