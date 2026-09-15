# qq-nt 安装包签名下载器
# 背景：腾讯 2026-09 起将 QQ NT 安装包迁至 qqfile/QQNTV2 路径，裸链接对一切脚本下载器 403（Lego 网关），
# 必须带 sign 参数（打到 tencent-cos 才放行）。签名由官网同源免登录接口 GetSign 签发，
# 本脚本复刻官网点击下载时的完整流程：GetSign 换签名 URL -> 下载 -> 输出 sha256。
# 用法：pwsh -NoProfile -File qqnt-fetch.ps1 -Url <裸安装包URL> [-OutFile <保存路径>]
# 输出：stdout = 文件 sha256（小写）；失败时非零退出并写错误。

param(
    [Parameter(Mandatory = $true)][string]$Url,
    [string]$OutFile
)

$ErrorActionPreference = 'Stop'

$signResp = Invoke-RestMethod -Uri "https://im.qq.com/http2rpc/gotrpc/noauth/trpc.qqntv2.urlsign.UrlSign/GetSign" `
    -Method Post -ContentType "application/json" `
    -Headers @{ "x-oidb" = '{"uint32_command":"0x9b8e","uint32_service_type":1}' } `
    -Body (@{ url = $Url } | ConvertTo-Json -Compress)

if ($signResp.retcode -ne 0 -or -not $signResp.data.url) {
    Write-Error "GetSign 签发失败: $($signResp | ConvertTo-Json -Compress)"
    exit 1
}

$signedUrl = $signResp.data.url
if (-not $OutFile) {
    $OutFile = Join-Path $env:TEMP ([IO.Path]::GetFileName(($Url -split '#')[0]))
}

Invoke-WebRequest -Uri $signedUrl -OutFile $OutFile -UseBasicParsing

$hash = (Get-FileHash $OutFile -Algorithm SHA256).Hash.ToLower()
Write-Output $hash
Write-Host "已下载: $OutFile" -ForegroundColor Green
