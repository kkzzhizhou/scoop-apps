param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('Mount', 'Dismount')]
    [string]$Action,

    [Parameter(Mandatory = $false)]
    [string]$PersistDir,

    [Parameter(Mandatory = $false)]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [string]$Target
)

# 导入同目录下的 DoradoUtils 模块
Import-Module "$PSScriptRoot/DoradoUtils.psm1" -ErrorAction Stop

try {
    if ($Action -eq 'Mount') {
        # 如果传了 Source 则直接使用完整源路径；否则使用 PersistDir 自动拼接 /data
        $finalSource = if ($Source) { $Source } else { "$PersistDir/data" }
        if ([string]::IsNullOrEmpty($finalSource)) {
            Write-Error "Either Source or PersistDir is required for Mount action."
            exit 1
        }
        Mount-ExternalRuntimeData -Source $finalSource -Target $Target
    } elseif ($Action -eq 'Dismount') {
        Dismount-ExternalRuntimeData -Target $Target
    }
} finally {
    Remove-Module -Name DoradoUtils -ErrorAction SilentlyContinue
}
