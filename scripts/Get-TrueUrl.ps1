# Locietta 2025
# Extract the real download URL from a short URL by following redirects

function Get-TrueUrl {
    param (
        [string]$shortUrl,
        [int]$maxRedirects = 10,
        [int]$timeoutSeconds = 5,
        [int]$retryCount = 2
    )

    if ([string]::IsNullOrWhiteSpace($shortUrl)) {
        Write-Warning "Input URL is empty."
        return $null
    }

    $currentUrl = $shortUrl

    for ($redirects = 0; $redirects -lt $maxRedirects; $redirects++) {
        # send request a few times in case of transient network issues
        for ($attempt = 0; $attempt -lt $retryCount; $attempt++) {
            # Try a HEAD request to inspect redirects without downloading content
            $response = InternalSendRequest -url $currentUrl -method "HEAD" -timeoutSeconds $timeoutSeconds
            if ($null -eq $response) { return $null }

            $status = [int]$response.StatusCode
            $location = $response.Headers["Location"]
            $response.Close()

            # If redirect, compute the next URL (support relative Location) and continue
            if ($status -ge 300 -and $status -le 399) {
                $next = InternalResolveLocation -baseUrl $currentUrl -location $location
                if ($null -eq $next) { return $currentUrl }
                $currentUrl = $next
                continue
            }

            # Success (2xx) and not a redirect: we're done
            if ($status -ge 200 -and $status -le 299) { return $currentUrl }

            # If HEAD returned 404, retry
            if ($status -eq 404) { continue }

            # Other non-redirect errors that is not 404: abort
            Write-Warning "Error resolving URL: $currentUrl - HTTP $status"
            return $null
        }
    }

    Write-Warning "Maximum redirects exceeded for: $shortUrl"
    return $currentUrl
}

# nothrows
function InternalSendRequest(
    [string]$url,
    [string]$method,
    [int]$timeoutSeconds
) {
    $response = $null
    $request = [System.Net.HttpWebRequest]::Create($url)
    $request.Method = $method
    $request.AllowAutoRedirect = $false
    $request.Timeout = $timeoutSeconds * 1000
    $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 Edg/140.0.0.0"

    try {
        $response = $request.GetResponse()
    } catch [System.Net.WebException] {
        $response = $_.Exception.Response
    } catch {
        Write-Warning "Error sending request: $url - $_"
        return $null
    }

    if ($null -eq $response) {
        Write-Warning "Error sending request: $url - no response returned"
        return $null
    }

    return $response
}

function InternalResolveLocation(
    [string]$baseUrl,
    [string]$location
) {
    if ([string]::IsNullOrEmpty($location)) { return $null }
    if ($location -match '^https?://') { return $location }
    $base = [System.Uri]::new($baseUrl)
    return ([System.Uri]::new($base, $location)).ToString()
}
