# microsoftedge-beta

记录 `bucket/microsoftedge-beta.json` 为什么这么写，以及 dorado 失效后的自实现预案。

## 1. 结论

- 官方企业版 MSI (`MicrosoftEdgeBetaEnterpriseX64.msi`) **不能**用来做便携版，它里面根本没有可提取的浏览器文件。
- 便携版只能走 **Edge CDP API**：取签名直链 → 下载 207 MB 的 `MicrosoftEdge_X64_<版本>.exe` → 7-Zip 两层解压出 `msedge.exe`。
- 清单 `url` 指向 **dorado** 的 `?dl`，它在下载瞬间 302 到微软 CDN，并现签一个 7 天有效的令牌，所以清单链接本身不会过期。

## 2. 为什么不能走 MSI

- 该 MSI **没有 `File` 表**（`Media` 表只有 `DiskId=1, LastSequence=0`，无 `Cabinet`），整个负载就是一条 214 MB 的 Binary 流 `MicrosoftEdgeBetaInstaller`。
- 所以 `Expand-MsiArchive`（lessmsi）输出空目录，`msiexec /a` 也只复制出一份 MSI 本身。CustomAction 是 `DoInstall`：直接执行 Binary 里的 EXE 做 `/silent /install`。
- 那条 Binary 是 PE（`MicrosoftEdgeUpdateSetup.exe`），其中资源 `#102 / #0`（213,887,589 字节，文件偏移 `0x26110`）是一段裸 LZMA。7-Zip 能解（`7z x` 支持 `.lzma`），解出 **20 字节前缀 + GNU tar**（105 个成员），其中 `MicrosoftEdge_X64_<版本>.exe.{GUID}` 才是浏览器包。
- 但 MSI 里那份副本与微软 CDN 上的真包 **SHA256 不同**（内副本 `f395e9749055609f81651669bf67abedc2bfe24d110812ed62db3576851394dd`，真包 `12bc677c0a24bfac2e0d4c7b7acf8d4e0b490c618fc6a26463b6aee5118b833b`），照它解会拿到坏数据。**不要走 MSI 这条路。**

## 3. 正确取链（三步）

```powershell
$body = '{"targetingAttributes":{"Updater":"MicrosoftEdgeUpdate"}}'
$base = 'https://msedge.api.cdp.microsoft.com/api/v1.1/contents/Browser/namespaces/Default/names/msedge-beta-win-x64/versions'

# 1) 版本
$ver = (Invoke-RestMethod -Method Post -Uri "$base/latest?action=select" `
        -Body $body -ContentType 'application/json').ContentId.Version

# 2) 下载信息
$all = Invoke-RestMethod -Method Post -Uri "$base/$ver/files?action=GenerateDownloadInfo" `
       -Body $body -ContentType 'application/json'

# 3) 完整包 = FileId 用 _ 分割成 3 段的那条；4 段的是增量包
$pkg = $all | Where-Object { ($_.FileId -split '_').Count -eq 3 }
$pkg.Url
[Convert]::ToHexString([Convert]::FromBase64String($pkg.Hashes.Sha256)).ToLower()
```

- 通道名：`msedge-beta-win-x64` / `msedge-beta-win-arm64`（stable / dev / canary 同理）。
- 接口**只接受 POST**，且必须带该请求体（`targetingAttributes`）。
- 直链里的 `P4` 是服务端 HMAC 签名，**无法自行构造**；`P1` 是过期时间戳（签发时刻 +7 天）。

## 4. 解压链（已实测）

```text
MicrosoftEdge_X64_<版本>.exe        207,689,040 字节
  └─ 7z x  →  MSEDGE.7z             732,738,014 字节
               （7-Zip 会自动钻进 PE 资源 .rsrc\B7\MSEDGE.PACKED.7Z）
      └─ 7z x -ExtractDir "Chrome-bin\<版本>"
             →  msedge.exe 等 492 个文件 / 27 个目录
```

清单里的 `installer.script` 就是第二层。

## 5. dorado 到底做了什么

```text
清单 url → dorado ?dl → 302 → msedge.b.tlu.dl.delivery.mp.microsoft.com/filestreamingservice/files/<GUID>?P1=…&P2=404&P3=2&P4=…
```

- 纯 302，**不托管、不重打包**（所以清单里的 hash 与 CDP API 返回的 hex 完全一致）。
- 它只是替 Scoop 做了两件 Scoop 自己做不到的事：
    1. 向 CDP API 发 **POST** —— Scoop 的 `lib/autoupdate.ps1` 里 `find_hash_in_json` 用的是 `WebClient.DownloadData`，只能 GET；
    2. 把 **base64** 的 `Hashes.Sha256` 转成 **hex** —— Scoop 的 `format_hash` 只认 hex。
- `P1` 每次请求现签，所以清单里的 dorado URL **永不“过期”**，不存在需要定时刷新清单的问题。

## 6. checkver 用 dorado（与下载同源）

清单的 `checkver` 直接用 dorado 的 JSON 接口：

```json
"checkver": {
    "url": "https://dorado-api.chawyehsu.deno.net/edge?arch=64&channel=beta",
    "jsonpath": "$.Version"
}
```

理由：**下载 URL 已经基于 dorado**，checkver 复用同一个依赖即可，不必再额外引入一条对 CDP 内部协议的直连。而且两边拿到的本来就是同一个版本值 —— dorado 的 `Version` 就是 CDP `?action=select` 返回的 `ContentId.Version`，它只做转发。

实测：

```text
GET https://dorado-api.chawyehsu.deno.net/edge?arch=64&channel=beta
→ {"Namespace":"Default","Name":"msedge-beta-win-X64","Version":"155.0.4283.24"}
```

- 字段是 **`$.Version`**，不是 `$.ContentId.Version` —— dorado 把 ContentId 平铺在顶层，写成 `$.ContentId.Version` 会报 `Property 'ContentId' does not exist on JObject`。
- arm64 是同一版本号，checkver 用哪条通道都一样（`arch=arm64` → `"Name":"msedge-beta-win-ARM64"`）。

### 备选：`checkver.script` 直连 CDP API

```json
"checkver": {
    "script": [
        "$body = '{\"targetingAttributes\":{\"Updater\":\"MicrosoftEdgeUpdate\"}}'",
        "$api = 'https://msedge.api.cdp.microsoft.com/api/v1.1/contents/Browser/namespaces/Default/names/msedge-beta-win-x64/versions/latest?action=select'",
        "(Invoke-RestMethod -Method Post -Uri $api -Body $body -ContentType 'application/json').ContentId.Version"
    ],
    "regex": "([\\d.]+)"
}
```

理由：**与下载源同源**。`autoupdate` 是拿 `$version` 去调 dorado 取浏览器包的，如果 checkver 从别的源取版本，两者不一致时那一轮 autoupdate 会失败。

### 企业版 feed 的写法（可用，但不同源）

```json
"checkver": {
    "url": "https://edgeupdates.microsoft.com/api/products?view=enterprise",
    "jsonpath": "$.[?(@.Product=='Beta')].Releases[0].ProductVersion"
}
```

实测通过（返回 `155.0.4283.24`），但有两点必须记住：

- Beta 频道返回 **15 条 = 3 个版本 × 5 个平台/架构**，按“新版本在前”排序：

    | 顺序 | Platform | Architecture | ProductVersion |
    | ---- | -------- | ------------ | -------------- |
    | 0    | Windows  | arm64        | 155.0.4283.24  |
    | 1    | Linux    | x64          | 155.0.4283.24  |
    | 2    | MacOS    | universal    | 155.0.4283.24  |
    | 3    | Windows  | x64          | 155.0.4283.24  |
    | 4    | Windows  | x86          | 155.0.4283.24  |
    | …    | …        | …            | .18 / .13      |

    所以 `Releases[0]` 拿的是最新版；索引 0 今天是 arm64，但同一版本内所有架构版本号相同，取哪条都一样。

- ⚠️ **不要**改成按平台过滤：

    ```text
    $.[?(@.Product=='Beta')].Releases[?(@.Platform=='Windows' && @.Architecture=='x64')].ProductVersion
    → ["155.0.4283.24","155.0.4283.18","155.0.4283.13"]    ← 3 个值
    ```

    Scoop 会把多值结果序列化成 JSON 字符串，checkver 直接失效。

### 验证 jsonpath 的正确姿势

不要靠猜，直接用 Scoop 自己的实现（`lib/json.ps1` 里走 Newtonsoft `SelectTokens` 的 `json_path`，checkver 用的就是它）：

```powershell
. 'D:\App\Scoop\apps\scoop\current\lib\json.ps1'
$raw = (New-Object Net.WebClient).DownloadString('https://edgeupdates.microsoft.com/api/products?view=enterprise')
json_path $raw "$.[?(@.Product=='Beta')].Releases[0].ProductVersion"
```

## 7. dorado 失效预案

按优先级：

1. 先确认是不是域名迁移。dorado 已从 `dorado-api.deno.dev` 迁到 `dorado-api.chawyehsu.deno.net`；旧域名返回 404（Deno Deploy Classic 已于 2026-07-20 停服）。
2. 自实现一个 302 转发器（Cloudflare Workers / Deno Deploy / 自有服务器都行），逻辑就是第 3 节 + `Response.redirect(url, 302)`。
3. 临时兜底：本地脚本现取直链，直接写进 `bucket/microsoftedge-beta.json`。
    - 缺点：签名只有 **7 天**，清单超过 7 天没刷新，**新装**会 403（已安装的不受影响）。
    - ⚠️ 走这条时要把清单里的 `checkver` / `autoupdate` **整段删掉**。Scoop 的 `bin/checkver.ps1` 只处理带 `checkver` 字段的清单（`if ($json.checkver) { $Queue += … }`），删掉后 Excavator 会完全跳过它，不会覆盖手写的直链。

## 8. 快速排查

```powershell
# dorado 是否活着（应返回 JSON，含 Version）
Invoke-RestMethod 'https://dorado-api.chawyehsu.deno.net/edge?arch=64&channel=beta'

# 看 302 落到哪个 CDN 地址
curl.exe -sI "https://dorado-api.chawyehsu.deno.net/edge?arch=64&channel=beta&version=155.0.4283.24&dl"

# 校验下载到的文件
(Get-FileHash .\MicrosoftEdge-155.0.4283.24-x64.7z -Algorithm SHA256).Hash.ToLower()
```

## 9. 已知坑

- `#/MicrosoftEdge-$version-x64.7z` 这个片段**不能省**。Scoop 靠扩展名判断要不要自动解压，少了它 `$dir\MSEDGE.7z` 不会出现。
- 不要用 `Expand-MsiArchive`（见第 2 节）。
- `P1` 与 `P4` 必须**同批**使用；混搭不同批次的 P1/P4 会返回 403。
- `Hashes.Sha256` 是 base64，写进清单前必须转成 hex。
- jsonpath 只要可能返回多个值就会废掉 checkver（见第 6 节）。
- 155.0.4283.24 的参考值：x64 `12bc677c0a24bfac2e0d4c7b7acf8d4e0b490c618fc6a26463b6aee5118b833b`，arm64 `09942e687ea629bda7ea5fa9c467a825450170a924df1812c0a3107ec89aac7d`。
