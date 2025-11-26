param(
    [string]$Folder = ".",
    [switch]$Backup,
    [switch]$WhatIf
)

# 设置控制台编码为UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Get-FileEncoding {
    param([string]$FilePath)

    try {
        $bytes = [byte[]](Get-Content $FilePath -Encoding Byte -ReadCount 4 -TotalCount 4)

        # 检测BOM
        if ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
            return "Unicode"  # UTF-16 LE
        }
        elseif ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
            return "BigEndianUnicode"  # UTF-16 BE
        }
        elseif ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            return "UTF8"  # UTF-8 with BOM
        }
        else {
            # 无BOM，尝试检测编码
            return "Default"  # 使用系统默认编码（通常是ANSI）
        }
    }
    catch {
        return "Default"
    }
}

function Read-TextWithEncoding {
    param([string]$FilePath)

    $encodingName = Get-FileEncoding -FilePath $FilePath
    $encoding = [System.Text.Encoding]::Default  # 默认ANSI

    switch ($encodingName) {
        "Unicode" { $encoding = [System.Text.Encoding]::Unicode }
        "BigEndianUnicode" { $encoding = [System.Text.Encoding]::BigEndianUnicode }
        "UTF8" { $encoding = [System.Text.Encoding]::UTF8 }
        "Default" {
            # 对于中文系统，通常需要GB2312或GBK
            try {
                $encoding = [System.Text.Encoding]::GetEncoding("GB2312")
            }
            catch {
                try {
                    $encoding = [System.Text.Encoding]::GetEncoding("GBK")
                }
                catch {
                    $encoding = [System.Text.Encoding]::Default
                }
            }
        }
    }

    Write-Host "  检测编码: $encodingName -> $($encoding.EncodingName)" -ForegroundColor Gray
    return [System.IO.File]::ReadAllText($FilePath, $encoding)
}

# 查找所有reg文件
$files = Get-ChildItem -Path $Folder -Filter "*.reg" -Recurse -File

if ($files.Count -eq 0) {
    Write-Host "未找到 .reg 文件" -ForegroundColor Yellow
    exit
}

Write-Host "找到 $($files.Count) 个文件，开始转换..." -ForegroundColor Green
Write-Host ""

$successCount = 0
$errorCount = 0

foreach ($file in $files) {
    Write-Host "处理: $($file.Name)" -ForegroundColor Cyan

    try {
        # 使用正确的编码读取文件
        $content = Read-TextWithEncoding -FilePath $file.FullName

        # 检查文件内容是否包含中文字符（简单检测）
        if ($content -match "[一-鿿]") {
            Write-Host "  检测到中文字符" -ForegroundColor Green
        }

        # 标准化文件头
        $originalHeader = $content.Substring(0, [Math]::Min(50, $content.Length))
        if ($content -match '^REGEDIT4') {
            $content = $content -replace '^REGEDIT4', 'Windows Registry Editor Version 5.00'
            Write-Host "  → 转换REGEDIT4头为标准头" -ForegroundColor Yellow
        }
        elseif (-not $content.StartsWith("Windows Registry Editor Version 5.00")) {
            # 处理可能的BOM情况
            if ($content.Length -gt 0 -and [int]$content[0] -eq 0xFEFF) {
                # 有BOM字符，在其后添加标准头
                $content = $content[0] + "Windows Registry Editor Version 5.00`r`n" + $content.Substring(1)
            } else {
                $content = "Windows Registry Editor Version 5.00`r`n" + $content
            }
            Write-Host "  → 添加标准文件头" -ForegroundColor Yellow
        }

        if ($WhatIf) {
            Write-Host "  [预览] 将转换为标准UTF-16 LE格式" -ForegroundColor Magenta
            $successCount++
            continue
        }

        # 创建备份
        if ($Backup) {
            $backupPath = $file.FullName + ".backup"
            Copy-Item $file.FullName $backupPath -Force
            Write-Host "  → 创建备份: $(Split-Path $backupPath -Leaf)" -ForegroundColor Gray
        }

        # 标准化换行符
        $content = $content -replace "`r?`n", "`r`n"

        # 使用UTF-16 LE编码保存（带BOM）
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::Unicode)

        # 验证转换结果
        $verifyContent = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::Unicode)
        if ($verifyContent -match "[一-鿿]") {
            Write-Host "  ✅ 转换成功，中文字符保存正常" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ 转换完成，但未检测到中文字符" -ForegroundColor Yellow
        }

        $successCount++
    }
    catch {
        Write-Host "  ❌ 错误: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }

    Write-Host ""
}

# 显示总结
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host "转换完成总结:" -ForegroundColor Cyan
Write-Host "成功: $successCount" -ForegroundColor Green
Write-Host "失败: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { "Green" } else { "Red" })
Write-Host "=" * 50 -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "注意: 本次为预览模式，未实际修改文件" -ForegroundColor Yellow
    Write-Host "使用去掉 -WhatIf 参数来实际执行转换" -ForegroundColor Yellow
}
