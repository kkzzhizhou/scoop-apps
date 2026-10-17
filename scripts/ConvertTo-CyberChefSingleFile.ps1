#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $InstallDir
)

$ErrorActionPreference = 'Stop'
$root = Join-Path $InstallDir 'original'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$htmlFiles = @(Get-ChildItem -LiteralPath $root -Filter 'CyberChef*.html' -File)
if ($htmlFiles.Count -ne 1) { throw 'Expected exactly one upstream CyberChef HTML file.' }
$html = [IO.File]::ReadAllText($htmlFiles[0].FullName, $utf8)
$resources = @{}
$mimeTypes = @{
    '.js' = 'application/javascript'; '.css' = 'text/css'; '.png' = 'image/png'
    '.ico' = 'image/x-icon'; '.svg' = 'image/svg+xml'; '.ttf' = 'font/ttf'
    '.woff' = 'font/woff'; '.woff2' = 'font/woff2'; '.json' = 'application/json'
}
foreach ($folder in 'assets', 'images', 'modules') {
    foreach ($file in Get-ChildItem -LiteralPath (Join-Path $root $folder) -Recurse -File | Sort-Object FullName) {
        # Keep compressed OCR language data, but omit duplicate web-server encodings.
        if ($file.Name -match '\.(?:js|css)\.(?:gz|br)$|\.LICENSE\.txt$') { continue }
        $key = $file.FullName.Substring($root.TrimEnd('\', '/').Length + 1).Replace('\', '/')
        $mime = $mimeTypes[$file.Extension]
        if (!$mime) { $mime = 'application/octet-stream' }
        $resources[$key] = "data:$mime;base64," + [Convert]::ToBase64String([IO.File]::ReadAllBytes($file.FullName))
    }
}
if (!$resources['assets/main.js'] -or !$resources['assets/main.css'] -or !$resources['modules/Protobuf.js']) {
    throw 'Unsupported CyberChef release layout: required assets or modules are missing.'
}

# Inline CSS dependencies relative to the original stylesheet.
$css = [IO.File]::ReadAllText((Join-Path $root 'assets/main.css'), $utf8)
$css = [regex]::Replace($css, 'url\((?<quote>["'']?)(?<path>(?!data:)[^\s)"'']+)\k<quote>\)', [System.Text.RegularExpressions.MatchEvaluator] {
    param($match)
    $path = $match.Groups['path'].Value
    $uri = New-Object System.Uri(([IO.Path]::GetFullPath((Join-Path $root 'assets/main.css'))))
    $resolved = New-Object System.Uri($uri, $path)
    $key = $resolved.LocalPath.Substring($root.TrimEnd('\', '/').Length + 1).Replace('\', '/')
    if (!$resources.ContainsKey($key)) { throw "Unresolved CSS resource: $path" }
    'url("' + $resources[$key] + '")'
})
$resources['assets/main.css'] = 'data:text/css;base64,' + [Convert]::ToBase64String($utf8.GetBytes($css))

# Webpack also creates image URLs dynamically; replace its literal image paths.
$main = [IO.File]::ReadAllText((Join-Path $root 'assets/main.js'), $utf8)
$main = [regex]::Replace($main, '"(?<path>images/[^"\r\n]+)"', [System.Text.RegularExpressions.MatchEvaluator] {
    param($match)
    $key = $match.Groups['path'].Value
    if (!$resources.ContainsKey($key)) { throw "Unresolved script image: $key" }
    '"' + $resources[$key] + '"'
})
$resources['assets/main.js'] = 'data:application/javascript;base64,' + [Convert]::ToBase64String($utf8.GetBytes($main))

# Workers on file:// cannot import sibling files. Pass source and resources as
# Blobs, then import embedded data URLs, following the tested file-mode bootstrap.
$bootstrap = @'
function installEmbeddedResources(resources, resourcesBlob) {
    const sourceBlobs = new Map();
    const createURL = URL.createObjectURL.bind(URL);
    const revokeURL = URL.revokeObjectURL.bind(URL);
    function lookup(url) {
        const match = /(?:^|\/)((?:assets|images|modules)\/[^?#]+)(?:[?#].*)?$/.exec(String(url));
        if (!match) return null;
        if (!resources) resources = JSON.parse(new FileReaderSync().readAsText(resourcesBlob));
        return resources[decodeURIComponent(match[1])] || null;
    }
    URL.createObjectURL = function(blob) {
        const url = createURL(blob);
        sourceBlobs.set(url, blob);
        return url;
    };
    URL.revokeObjectURL = function(url) {
        sourceBlobs.delete(String(url));
        revokeURL(url);
    };
    if (self.importScripts) {
        const nativeImport = self.importScripts.bind(self);
        self.importScripts = (...urls) => nativeImport(...urls.map(url => lookup(url) || url));
    }
    const nativeFetch = self.fetch.bind(self);
    self.fetch = (url, options) => nativeFetch(lookup(url instanceof Request ? url.url : url) || url, options);
    const nativeOpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function(method, url, ...args) {
        return nativeOpen.call(this, method, lookup(url) || url, ...args);
    };
    const NativeWorker = self.Worker;
    if (!NativeWorker) return;
    self.Worker = class extends NativeWorker {
        constructor(url, options) {
            let source = sourceBlobs.get(String(url));
            const embedded = lookup(url);
            if (!source && embedded) {
                source = new Blob([Uint8Array.from(atob(embedded.split(',')[1]), c => c.charCodeAt(0))]);
            }
            if (!source || (options && options.type === 'module')) {
                super(url, options);
                return;
            }
            const code = '(' + workerBootstrap.toString() + ')(' + installEmbeddedResources.toString() + ');';
            const workerURL = createURL(new Blob([code], {type: 'application/javascript'}));
            super(workerURL, options);
            sourceBlobs.delete(String(url));
            super.postMessage({type: '__cyberchef_embedded_init__', source, resources: resourcesBlob});
            revokeURL(workerURL);
        }
    };
    function workerBootstrap(install) {
        self.addEventListener('message', function init(event) {
            if (!event.data || event.data.type !== '__cyberchef_embedded_init__') return;
            event.stopImmediatePropagation();
            self.removeEventListener('message', init);
            install(null, event.data.resources);
            (0, eval)(new FileReaderSync().readAsText(event.data.source));
        });
    }
}
'@

# Use data URLs for external tags, preserving defer semantics and avoiding raw
# script/style closing tags inside upstream JavaScript or CSS.
$html = [regex]::Replace($html, '(?<prefix>\b(?:src|href)=)(?<quote>["'']?)(?<path>(?:assets|images)/[^\s>"'']+)\k<quote>', [System.Text.RegularExpressions.MatchEvaluator] {
    param($match)
    $key = $match.Groups['path'].Value
    if (!$resources.ContainsKey($key)) { throw "Unresolved HTML resource: $key" }
    $match.Groups['prefix'].Value + '"' + $resources[$key] + '"'
})
# Main JS/CSS are already referenced in HTML; workers only need the other files.
$resources.Remove('assets/main.js')
$resources.Remove('assets/main.css')
$json = ConvertTo-Json -InputObject $resources -Compress -Depth 3
$shim = $bootstrap + "`nconst embeddedResources = $json;`ninstallEmbeddedResources(embeddedResources, new Blob([JSON.stringify(embeddedResources)], {type: 'application/json'}));"
if (!$html.Contains('<head>')) { throw 'Unsupported CyberChef HTML: missing head tag.' }
$html = $html.Replace('<head>', ('<head><script>' + $shim + '</script>'))
# Only replace the launch target after every transformation has succeeded.
[IO.File]::WriteAllText((Join-Path $InstallDir 'CyberChef.html'), $html, $utf8)
