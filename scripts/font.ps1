# ============================================================
# Scoop Font Helper
# ============================================================

if (-not ('ScoopFontApi' -as [type])) {

    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class ScoopFontApi
{
    [DllImport("gdi32.dll",
        CharSet = CharSet.Unicode,
        SetLastError = true)]
    public static extern int AddFontResourceW(
        string fileName);

    [DllImport("gdi32.dll",
        CharSet = CharSet.Unicode,
        SetLastError = true)]
    public static extern bool RemoveFontResourceW(
        string fileName);

    [DllImport("user32.dll",
        CharSet = CharSet.Unicode)]
    public static extern IntPtr SendMessageW(
        IntPtr hWnd,
        uint msg,
        IntPtr wParam,
        IntPtr lParam);

    public static readonly IntPtr HWND_BROADCAST =
        new IntPtr(0xffff);

    public const uint WM_FONTCHANGE = 0x001D;
}
'@ -ErrorAction Stop
}


# ============================================================
# Registry name
# ============================================================

function Get-ScoopFontRegistryName {

    param(
        [Parameter(Mandatory)]
        [string]$FileName
    )

    $baseName = [IO.Path]::GetFileNameWithoutExtension($FileName)
    $extension = [IO.Path]::GetExtension($FileName).ToLowerInvariant()

    switch ($extension) {

        '.ttf' {
            "$baseName (TrueType)"
        }

        '.otf' {
            "$baseName (OpenType)"
        }

        default {
            throw "Unsupported font format: $FileName"
        }
    }
}


# ============================================================
# Install one font
# ============================================================

function Install-ScoopFont {

    param(
        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$FontDirectory,

        [Parameter(Mandatory)]
        [string]$RegistryKey,

        [Parameter(Mandatory)]
        [bool]$Global
    )

    $fileName = [IO.Path]::GetFileName($Source)

    $destination = Join-Path `
        $FontDirectory `
        $fileName

    $registryName = Get-ScoopFontRegistryName `
        $fileName

    Write-Host "Installing '$fileName'..."

    if (-not (Test-Path -LiteralPath $FontDirectory)) {

        New-Item `
            -Path $FontDirectory `
            -ItemType Directory `
            -Force `
            -ErrorAction Stop |
            Out-Null
    }

    Copy-Item `
        -LiteralPath $Source `
        -Destination $destination `
        -Force `
        -ErrorAction Stop


    # Per-user registry values contain the complete path.
    # HKLM font values normally contain only the filename.
    $registryValue = if ($Global) {
        $fileName
    }
    else {
        $destination
    }


    New-ItemProperty `
        -Path $RegistryKey `
        -Name $registryName `
        -Value $registryValue `
        -PropertyType String `
        -Force `
        -ErrorAction Stop |
        Out-Null


    # Load into current Windows session
    $result = [ScoopFontApi]::AddFontResourceW(
        $destination
    )

    if ($result -eq 0) {

        Remove-ItemProperty `
            -Path $RegistryKey `
            -Name $registryName `
            -Force `
            -ErrorAction SilentlyContinue

        Remove-Item `
            -LiteralPath $destination `
            -Force `
            -ErrorAction SilentlyContinue

        throw "AddFontResourceW failed for '$fileName'."
    }

    Write-Host `
        "  Loaded $result font resource(s)." `
        -ForegroundColor DarkGray
}


# ============================================================
# Find installed font
#
# IMPORTANT:
# We check BOTH HKCU and HKLM.
#
# We do NOT use $global here.
# ============================================================

function Find-ScoopInstalledFont {

    param(
        [Parameter(Mandatory)]
        [string]$FileName
    )

    $registryName = Get-ScoopFontRegistryName `
        $FileName


    # --------------------------------------------------------
    # HKCU - per-user installation
    # --------------------------------------------------------

    $hkcu = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'

    $property = Get-ItemProperty `
        -Path $hkcu `
        -Name $registryName `
        -ErrorAction SilentlyContinue

    if ($null -ne $property) {

        $value = $property.$registryName

        if ([string]::IsNullOrWhiteSpace($value)) {
            $value = Join-Path `
                "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" `
                $FileName
        }

        return [PSCustomObject]@{
            RegistryKey = $hkcu
            RegistryName = $registryName
            Path = $value
            Scope = 'User'
        }
    }


    # --------------------------------------------------------
    # HKLM - global installation
    # --------------------------------------------------------

    $hklm = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'

    $property = Get-ItemProperty `
        -Path $hklm `
        -Name $registryName `
        -ErrorAction SilentlyContinue

    if ($null -ne $property) {

        $value = $property.$registryName

        if ([string]::IsNullOrWhiteSpace($value)) {
            $value = $FileName
        }

        if (-not [IO.Path]::IsPathRooted($value)) {

            $value = Join-Path `
                "$env:windir\Fonts" `
                $value
        }

        return [PSCustomObject]@{
            RegistryKey = $hklm
            RegistryName = $registryName
            Path = $value
            Scope = 'Global'
        }
    }


    return $null
}


# ============================================================
# Uninstall one font
# ============================================================

function Uninstall-ScoopFont {

    param(
        [Parameter(Mandatory)]
        [string]$FileName
    )

    Write-Host "Removing '$FileName'..."


    # --------------------------------------------------------
    # Find actual installation
    # --------------------------------------------------------

    $font = Find-ScoopInstalledFont `
        -FileName $FileName


    if ($null -eq $font) {

        Write-Host `
            "  Registry entry not found." `
            -ForegroundColor DarkYellow

        # Last-resort search in both normal font directories.

        $possiblePaths = @(
            (Join-Path `
                "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" `
                $FileName),

            (Join-Path `
                "$env:windir\Fonts" `
                $FileName)
        )

        foreach ($path in $possiblePaths) {

            if (Test-Path -LiteralPath $path) {

                Write-Host `
                    "  Found orphaned font file: $path" `
                    -ForegroundColor Yellow

                try {

                    [ScoopFontApi]::RemoveFontResourceW(
                        $path
                    ) | Out-Null

                    Remove-Item `
                        -LiteralPath $path `
                        -Force `
                        -ErrorAction Stop

                    Write-Host `
                        "  Font file removed." `
                        -ForegroundColor DarkGray
                }
                catch {

                    Write-Host `
                        "  Could not remove '$path'." `
                        -ForegroundColor Red

                    throw
                }
            }
        }

        return
    }


    Write-Host `
        "  Found $($font.Scope) installation." `
        -ForegroundColor DarkGray

    Write-Host `
        "  Path: $($font.Path)" `
        -ForegroundColor DarkGray


    # --------------------------------------------------------
    # Remove font from current font session
    # --------------------------------------------------------

    if (Test-Path -LiteralPath $font.Path) {

        $removeCount = 0

        while (
            [ScoopFontApi]::RemoveFontResourceW(
                $font.Path
            )
        ) {
            $removeCount++
        }

        Write-Host `
            "  RemoveFontResourceW calls: $removeCount" `
            -ForegroundColor DarkGray
    }


    # --------------------------------------------------------
    # Remove registry entry
    # --------------------------------------------------------

    Remove-ItemProperty `
        -Path $font.RegistryKey `
        -Name $font.RegistryName `
        -Force `
        -ErrorAction Stop

    Write-Host `
        "  Registry entry removed from $($font.Scope)." `
        -ForegroundColor DarkGray


    # --------------------------------------------------------
    # Notify Windows
    # --------------------------------------------------------

    [ScoopFontApi]::SendMessageW(
        [ScoopFontApi]::HWND_BROADCAST,
        [ScoopFontApi]::WM_FONTCHANGE,
        [IntPtr]::Zero,
        [IntPtr]::Zero
    ) | Out-Null


    # --------------------------------------------------------
    # Delete physical file
    # --------------------------------------------------------

    if (-not (Test-Path -LiteralPath $font.Path)) {

        Write-Host `
            "  Font file already absent." `
            -ForegroundColor DarkGray

        return
    }


    try {

        Remove-Item `
            -LiteralPath $font.Path `
            -Force `
            -ErrorAction Stop

        Write-Host `
            "  Font file removed." `
            -ForegroundColor DarkGray
    }
    catch {

        Write-Host `
            "  Cannot remove font file:" `
            -ForegroundColor Red

        Write-Host `
            "  $($font.Path)" `
            -ForegroundColor Yellow

        throw
    }
}


# ============================================================
# Install all fonts
# ============================================================

function Install-ScoopFonts {

    param(
        [Parameter(Mandatory)]
        [string]$SourceDirectory,

        [Parameter(Mandatory)]
        [string]$FontDirectory,

        [Parameter(Mandatory)]
        [string]$RegistryKey,

        [Parameter(Mandatory)]
        [bool]$Global
    )

    Get-ChildItem `
        -LiteralPath $SourceDirectory `
        -File `
        -Recurse |
        Where-Object {
            $_.Extension -in '.ttf', '.otf'
        } |
        ForEach-Object {

            Install-ScoopFont `
                -Source $_.FullName `
                -FontDirectory $FontDirectory `
                -RegistryKey $RegistryKey `
                -Global $Global
        }
}


# ============================================================
# Uninstall all fonts
# ============================================================

function Uninstall-ScoopFonts {

    param(
        [Parameter(Mandatory)]
        [string]$SourceDirectory
    )

    Get-ChildItem `
        -LiteralPath $SourceDirectory `
        -File `
        -Recurse |
        Where-Object {
            $_.Extension -in '.ttf', '.otf'
        } |
        ForEach-Object {

            Uninstall-ScoopFont `
                -FileName $_.Name
        }
}


# ============================================================
# Notify Windows
# ============================================================

function Update-ScoopFontCache {

    [ScoopFontApi]::SendMessageW(
        [ScoopFontApi]::HWND_BROADCAST,
        [ScoopFontApi]::WM_FONTCHANGE,
        [IntPtr]::Zero,
        [IntPtr]::Zero
    ) | Out-Null
}