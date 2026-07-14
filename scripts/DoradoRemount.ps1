# Summary: 一键重新挂载所有使用 DoradoHelper.ps1 的应用的运行数据
# Description: 扫描所有已安装的 Scoop 应用，自动安全执行包含了 DoradoHelper.ps1 的 Mount 挂载逻辑。
# Usage: scoop remount [app1 app2 ...]

# 1. 自动定位 Scoop 安装目录并加载核心库
$scoop_dir = $env:SCOOP, "$env:USERPROFILE\scoop" | Where-Object { $_ } | Select-Object -First 1
if (!(Test-Path "$scoop_dir/apps/scoop/current/lib/core.ps1")) {
    Write-Error "Scoop installation directory not found!"
    exit 1
}

# 2. 导入 Scoop 原生依赖模块
. "$scoop_dir/apps/scoop/current/lib/core.ps1"
. "$scoop_dir/apps/scoop/current/lib/manifest.ps1"
. "$scoop_dir/apps/scoop/current/lib/buckets.ps1"

# 3. 确定要处理的 App 列表（支持参数指定，默认扫描全部已安装应用）
$target_apps = $args
if ($target_apps.Count -eq 0) {
    # 合并扫描用户本地和全局安装的应用
    $target_apps = (installed_apps $false) + (installed_apps $true) | Select-Object -Unique
}

Write-Host "Scanning installed applications for DoradoHelper mounts..." -ForegroundColor Cyan

foreach ($app in $target_apps) {
    # 获取当前应用的安装状态和版本
    $global = installed $app $true
    $version = Select-CurrentVersion -AppName $app -Global:$global
    if (!$version) { continue }

    $app_dir = versiondir $app $version $global
    $current_dir = "$(appdir $app $global)\current"
    $manifest_path = "$current_dir/manifest.json"
    $install_json_path = "$current_dir/install.json"

    if (!(Test-Path $manifest_path)) { continue }

    # 读取 local manifest.json
    $manifest = parse_json $manifest_path

    # 4. 搜寻所有可能包含挂载逻辑的脚本生命周期块（防漏掉 pre_install 或 installer）
    $scripts = @()
    if ($manifest.pre_install) { $scripts += @($manifest.pre_install) }
    if ($manifest.post_install) { $scripts += @($manifest.post_install) }
    if ($manifest.installer) {
        if ($manifest.installer.script) { $scripts += @($manifest.installer.script) }
        else { $scripts += @($manifest.installer) }
    }

    # 精确筛选出含有 DoradoHelper.ps1 且动作是 Mount 的命令行
    $mount_commands = $scripts | Where-Object { $_ -like "*DoradoHelper.ps1*" -and $_ -like "*-Action Mount*" }
    if ($mount_commands.Count -eq 0) { continue }

    Write-Host "Found helper in '$app' (v$version). Remounting..." -ForegroundColor Yellow

    # 从 install.json 中安全提取该应用在安装时关联的原始 bucket 名称
    $bucket = $null
    if (Test-Path $install_json_path) {
        $install_info = parse_json $install_json_path
        $bucket = $install_info.bucket
    }

    # 5. 准备挂载脚本执行时所需的完整上下文变量（Scoop 钩子原生变量）
    $dir = $current_dir
    $original_dir = $app_dir
    $persist_dir = persistdir $app $global

    # 6. 安全执行提取出来的具体挂载指令（绝对不触发安装包等其他无关逻辑）
    $script_block_text = $mount_commands -join "`r`n"
    try {
        # 传入当前的变量上下文，使得 $bucket, $dir, $persist_dir 正确解析
        $execution_block = [scriptblock]::Create($script_block_text)
        Invoke-Command -ScriptBlock $execution_block -ArgumentList @()
        Write-Host "Successfully remounted '$app'!" -ForegroundColor Green
    } catch {
        Write-Error "Failed to remount '$app': $_"
    }
}
