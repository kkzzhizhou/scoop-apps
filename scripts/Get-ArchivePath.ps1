# Get-ArchivePath.ps1
# Lists all files in a ZIP archive to help determine extract_dir and shortcuts.

param(
    [Parameter(Mandatory = $true)]
    [string]$Url
)

# Get total length for EOCD search
$totalLength = 0
try {
	$request = [System.Net.HttpWebRequest]::Create($Url)
	$request.Method = "HEAD"
	$response = $request.GetResponse()
	$totalLength = $response.ContentLength
	$response.Close()
} catch {
	throw "Failed to get file size from $Url"
}

function Get-Range {
	param($Url, $Start, $End)
	$temp_path = [System.IO.Path]::GetTempFileName()
	try {
		$headers = @{ Range = "bytes=$Start-$End" }
		Invoke-RestMethod -Uri $Url -Headers $headers -OutFile $temp_path -ErrorAction Stop
		$b = [System.IO.File]::ReadAllBytes($temp_path)
		return , $b
	} catch {
		$request = [System.Net.HttpWebRequest]::Create($Url)
		$request.Method = 'GET'
		$request.AddRange([long]$Start, [long]$End)
		$response = $request.GetResponse()
		$stream = $response.GetResponseStream()
		$ms = New-Object System.IO.MemoryStream
		$stream.CopyTo($ms)
		$bytes = $ms.ToArray()
		$stream.Close()
		$response.Close()
		return , $bytes
	} finally {
		if (Test-Path $temp_path) { Remove-Item $temp_path -Force -ErrorAction SilentlyContinue }
	}
}

# Read last 8KB to find EOCD
$readSize = [Math]::Min($totalLength, 8192)
$bytes = [byte[]](Get-Range $Url ($totalLength - $readSize) ($totalLength - 1))

# Find EOCD (0x06054b50)
$eocdIndex = -1
for ($i = $bytes.Length - 22; $i -ge 0; $i--) {
	if ($bytes[$i] -eq 0x50 -and $bytes[$i+1] -eq 0x4b -and $bytes[$i+2] -eq 0x05 -and $bytes[$i+3] -eq 0x06) {
		$eocdIndex = $i
		break
	}
}

if ($eocdIndex -lt 0) { throw "EOCD signature not found in last 8KB." }

$cdSize = [System.BitConverter]::ToUInt32($bytes, $eocdIndex + 12)
$cdOffset = [System.BitConverter]::ToUInt32($bytes, $eocdIndex + 16)

# Download CD in 8KB chunks
$cdBytes = New-Object byte[] $cdSize
$downloaded = 0
while ($downloaded -lt $cdSize) {
	$chunkSize = [Math]::Min(8192, $cdSize - $downloaded)
	[byte[]]$chunk = Get-Range $Url ([long]($cdOffset + $downloaded)) ([long]($cdOffset + $downloaded + $chunkSize - 1))
	[System.Array]::Copy($chunk, 0, $cdBytes, $downloaded, $chunk.Length)
	$downloaded += $chunk.Length
}


# Parse filenames
$pos = 0
$files = @()
while ($pos + 46 -le $cdSize) {
	if ($cdBytes[$pos] -ne 0x50 -or $cdBytes[$pos+1] -ne 0x4b -or $cdBytes[$pos+2] -ne 0x01 -or $cdBytes[$pos+3] -ne 0x02) { break }
	$nLen = [System.BitConverter]::ToUInt16($cdBytes, $pos + 28)
	$eLen = [System.BitConverter]::ToUInt16($cdBytes, $pos + 30)
	$cLen = [System.BitConverter]::ToUInt16($cdBytes, $pos + 32)
	$name = [System.Text.Encoding]::GetEncoding(437).GetString($cdBytes, $pos + 46, $nLen)
	$files += $name
	$pos += 46 + $nLen + $eLen + $cLen
}

write-host "Files in archive:" -ForegroundColor Cyan
$files | ForEach-Object { write-host "  $_" }

# Determine extract_dir recommendation
$rootItems = $files | ForEach-Object { $_.Split('/')[0] } | Select-Object -Unique | Where-Object { $_ -ne "" }
$rootFiles = $files | Where-Object { $_ -notmatch '/' }
$topDirs = $files | Where-Object { $_ -match '/$' } | ForEach-Object { $_.Split('/')[0] } | Select-Object -Unique

write-host "`nAnalysis:" -ForegroundColor Yellow
$extractDir = $null
if ($rootFiles.Count -gt 0) {
	write-host "Guess: extract_dir NOT NEEDED (found files at root)" -ForegroundColor Green
} elseif ($topDirs.Count -eq 1) {
	$extractDir = $topDirs[0]
	write-host "Guess: extract_dir: `"$extractDir`"" -ForegroundColor Green
} else {
	write-host "Guess: extract_dir NOT NEEDED (multiple or no top-level directories)" -ForegroundColor Green
}

# Suggested Bin / Shortcuts
$executables = $files | Where-Object { $_ -match '\.(exe|ps1|cmd|bat)$' }
if ($executables.Count -gt 0) {
	write-host "`nPotential Bin / Shortcuts (relative to extract_dir):" -ForegroundColor Yellow
	foreach ($exe in $executables) {
		$relPath = $exe
		if ($extractDir -and $exe.StartsWith("$extractDir/")) {
			$relPath = $exe.Substring($extractDir.Length + 1)
		}
		write-host "  $relPath" -ForegroundColor Cyan
	}
}

