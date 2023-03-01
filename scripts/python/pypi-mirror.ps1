#!/usr/bin/env pwsh -c

<#
.DESCRIPTION
    Pypi mirror.

.PARAMETER mirror
    The mirror to use.
    * tuna (default)
    * ustc
    * ali
    * tencent
    * huawei
    * 163
    * douban

.PARAMETER clear
    Clear the mirror.

.PARAMETER help
    Show help.

.Example
    > pypi-mirror.ps1 -mirror tuna
    > pypi-mirror.ps1 -clear
#>

param(
    [Alias('m')]
    [ValidateSet('tuna', 'ustc', 'ali', 'tencent', 'huawei', '163', 'douban')]
    [string]$mirror = 'tuna',

    [Alias('c')]
    [switch]$clear,

    [Alias('h')]
    [switch]$help
)

if ($help) {
    Write-Host @'
Usage: pypi-mirror.ps1 [OPTION]

Optional options:
    -m, --mirror <mirror>
        The mirror to use.
        * tuna (default)
        * ustc
        * ali
        * tencent
        * huawei
        * 163
        * douban
    -c, --clear
        Clear the mirror.
    -h, --help
        Show help.

.Example
    > pypi-mirror.ps1 -mirror tuna
    > pypi-mirror.ps1 -clear
'@
    exit 0
}

if ($mirror) {
    if ($mirror -eq 'tuna') {
        $mirror_url = 'https://pypi.tuna.tsinghua.edu.cn/simple'
        $index_url = 'pypi.tuna.tsinghua.edu.cn'
    } elseif ($mirror -eq 'ustc') {
        $mirror_url = 'https://mirrors.ustc.edu.cn/pypi/web/simple'
        $index_url = 'mirrors.ustc.edu.cn'
    } elseif ($mirror -eq 'ali') {
        $mirror_url = 'https://mirrors.aliyun.com/pypi/simple/'
        $index_url = 'mirrors.aliyun.com'
    } elseif ($mirror -eq 'tencent') {
        $mirror_url = 'https://mirrors.cloud.tencent.com/pypi/simple'
        $index_url = 'mirrors.cloud.tencent.com'
    } elseif ($mirror -eq 'huawei') {
        $mirror_url = 'https://repo.huaweicloud.com/repository/pypi/simple'
        $index_url = 'repo.huaweicloud.com'
    } elseif ($mirror -eq '163') {
        $mirror_url = 'https://mirrors.163.com/pypi/simple/'
        $index_url = 'mirrors.163.com'
    } elseif ($mirror -eq 'douban') {
        $mirror_url = 'http://pypi.douban.com/simple/'
        $index_url = 'pypi.douban.com'
    } else {
        Write-Host 'Unknown mirror.'
        exit 1
    }

    python -m pip install --trusted-host https://${index_url} -i ${mirror_url} --upgrade pip
    pip config set global.index-url ${mirror_url}
    pip config set global.trusted-host ${index_url}
    pip config set global.timeout 120
}

if ($clear) {
    pip config set global.index-url https://pypi.org/simple
    pip config set global.trusted-host pypi.org
    pip config set global.timeout 120
}
