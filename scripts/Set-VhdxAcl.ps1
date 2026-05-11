# Grant the NTFS DACL required for WSL to mount a kernelModules VHDX.
# WSL 2.7.1+ rejects vhdx files lacking these ACEs with
# Wsl/Service/CreateInstance/CreateVm/HCS/E_ACCESSDENIED.
#
# SIDs are used directly to avoid locale-dependent name lookups:
#   S-1-5-32-545   BUILTIN\Users                             (RX)
#   S-1-15-2-1     APPLICATION PACKAGE AUTHORITY\
#                  ALL APPLICATION PACKAGES                  (RX)
#   S-1-15-2-2     APPLICATION PACKAGE AUTHORITY\
#                  ALL RESTRICTED APPLICATION PACKAGES       (RX)

function Set-VhdxAcl {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    & icacls.exe $Path /grant `
        '*S-1-5-32-545:(RX)' `
        '*S-1-15-2-1:(RX)' `
        '*S-1-15-2-2:(RX)' | Out-Null
}

# Usage:
# . $bucketsdir\$bucket\scripts\Set-VhdxAcl.ps1
# Set-VhdxAcl -Path $vhdx_file
