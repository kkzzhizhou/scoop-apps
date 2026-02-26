# Locietta 2026
#
# Retrieves the latest GitHub release tag (including pre-releases) for a repository.

function Get-GitHubLatestVersionTag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Repository', 'Repo')]
        [string]$RepositoryIdentifier
    )

    begin {
        $headers = @{
            'Accept'     = 'application/vnd.github+json'
            'User-Agent' = 'scoop-sniffer'
        }
        
        if (Get-Command -Name Get-GitHubToken -ErrorAction SilentlyContinue) {
            $token = Get-GitHubToken
            if ($token) {
                $headers['Authorization'] = "token $token"
            }
        }
    }

    process {
        $slug = $RepositoryIdentifier.Trim()

        if (-not $slug) {
            throw "Repository identifier cannot be empty."
        }

        if ($slug -match '^(https?):\/\/github\.com\/(.+)$') {
            $slug = $Matches[2]
        } elseif ($slug -match '^git@github\.com:(.+)$') {
            $slug = $Matches[1]
        }

        $slug = $slug.TrimEnd('/')
        $slug = $slug -replace '\.git$', ''

        if ($slug -notmatch '^(?<owner>[^\/\s]+)\/(?<repo>[^\/\s]+)(?:\/.*)?$') {
            throw "Repository identifier '$RepositoryIdentifier' is invalid. Use the form 'owner/repo'."
        }

        $owner = $Matches['owner']
        $repo = $Matches['repo']
        $repo = $repo -replace '\.git$', ''
        $slug = "$owner/$repo"

        $endpoint = "https://api.github.com/repos/$slug/releases?per_page=1"

        try {
            $response = Invoke-RestMethod -Method Get -Uri $endpoint -Headers $headers -ErrorAction Stop
        } catch {
            throw "Failed to query GitHub releases for '$slug': $($_.Exception.Message)"
        }

        $release = if ($response -is [array]) {
            $response | Select-Object -First 1
        } else {
            $response
        }

        if (-not $release) {
            throw "No releases found for '$slug'."
        }

        if (-not $release.tag_name) {
            throw "GitHub response for '$slug' did not include a tag name."
        }

        return $release.tag_name
    }
}



