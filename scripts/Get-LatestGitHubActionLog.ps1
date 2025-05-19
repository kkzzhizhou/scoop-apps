#Requires -Version 7
<#
.SYNOPSIS
    Views the log of a selected GitHub Actions workflow run for the current repository.
.DESCRIPTION
    This script uses the GitHub CLI ('gh') to:
    1. List available workflows in the current repository.
    2. Allow the user to select a workflow.
    3. For the selected workflow, show the latest run and offer to list other recent runs.
    4. Allow the user to select a specific run.
    5. If the run has multiple jobs, prompt the user to select a job whose log they want to view.
.NOTES
    Author: Your Name/AI
    Version: 2.0
    Requires: GitHub CLI ('gh') to be installed and authenticated.
              PowerShell 7 or higher.
.EXAMPLE
    .\Get-GitHubActionLogInteractive.ps1
    Interactively selects a workflow, then a run, then a job (if applicable) to view logs.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop' # Stop on first error for easier debugging

# Function to check if gh CLI is available
function Test-GhCliInstalled {
    try {
        Get-Command gh -ErrorAction SilentlyContinue | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to present choices and get user selection
function Get-UserChoice {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PromptMessage,
        [Parameter(Mandatory=$true)]
        [System.Collections.IList]$Choices, # Expects an array of objects with a 'Name' property for display
        [string]$ChoicePropertyName = 'Name', # Property to display for choice
        [string]$AdditionalInfoPropertyName = $null, # Optional secondary property to display
        [string]$QuitOptionString = 'q'
    )

    Write-Host $PromptMessage
    for ($i = 0; $i -lt $Choices.Count; $i++) {
        $displayString = ("  {0,2}. {1}" -f ($i + 1), $Choices[$i].($ChoicePropertyName))
        if ($AdditionalInfoPropertyName -and $Choices[$i].PSObject.Properties[$AdditionalInfoPropertyName]) {
            $displayString += (" ({0})" -f $Choices[$i].($AdditionalInfoPropertyName))
        }
        Write-Host $displayString
    }

    $maxChoice = $Choices.Count
    while ($true) {
        try {
            $userInput = Read-Host -Prompt "Enter number (1-$maxChoice) or '$QuitOptionString' to quit"
            if ($userInput -eq $QuitOptionString) {
                return $null # Indicate quit
            }
            $choiceIndex = [int]$userInput - 1
            if ($choiceIndex -ge 0 -and $choiceIndex -lt $maxChoice) {
                return $Choices[$choiceIndex]
            }
            else {
                Write-Warning "Invalid selection. Please enter a number between 1 and $maxChoice."
            }
        }
        catch {
            Write-Warning "Invalid input. Please enter a number or '$QuitOptionString'."
        }
    }
}

if (-not (Test-GhCliInstalled)) {
    Write-Error "GitHub CLI ('gh') is not installed or not found in your PATH. Please install it from https://cli.github.com/"
    exit 1
}

# --- 1. Get Repository Name ---
Write-Host "Determining current repository..."
$repoFullName = ""
try {
    $repoFullName = gh repo view --json nameWithOwner --jq .nameWithOwner
    if ([string]::IsNullOrWhiteSpace($repoFullName)) {
        throw "Could not determine repository full name. Are you in a git repository with a GitHub remote?"
    }
    Write-Host "Current repository: $repoFullName"
}
catch {
    Write-Error "Failed to determine current repository: $($_.Exception.Message)"
    Write-Error "Ensure you are in a directory that is part of a Git repository, and it has a remote configured on GitHub."
    exit 1
}

# --- 2. Select Workflow ---
Write-Host "Fetching workflows for repository '$repoFullName'..."
$workflows = @()
try {
    # id is the workflow file name e.g. main.yml, state can be active, disabled_inactivity, disabled_manually
    $workflowsJson = gh workflow list --repo "$repoFullName" --json name,id,state --jq '.[] | select(.state == "active")'
    if ($workflowsJson) {
        $workflows = $workflowsJson | ConvertFrom-Json
        if ($workflows -is [System.Management.Automation.PSCustomObject] -and -not ($workflows -is [System.Array])) {
            $workflows = @($workflows) # Ensure it's an array if only one workflow
        }
    }
}
catch {
    Write-Error "Error fetching workflows: $($_.Exception.Message)"
    exit 1
}

if (-not $workflows -or $workflows.Count -eq 0) {
    Write-Warning "No active workflows found for repository '$repoFullName'."
    exit 0
}

$selectedWorkflow = Get-UserChoice -PromptMessage "Select a workflow:" -Choices $workflows -ChoicePropertyName "name" -AdditionalInfoPropertyName "id"
if (-not $selectedWorkflow) {
    Write-Host "Exiting."
    exit 0
}
Write-Host ("Selected workflow: '{0}' (ID: {1})" -f $selectedWorkflow.name, $selectedWorkflow.id)


# --- 3. Select Run (Default to latest, option to choose another) ---
$selectedRunId = ""
$selectedRunDisplayTitle = ""
$runsLimitForListing = 10 # How many past runs to list if user wants to select

try {
    Write-Host "Fetching latest run for workflow '$($selectedWorkflow.name)'..."
    # Get the most recent run for the selected workflow
    $latestRunJson = gh run list --repo "$repoFullName" --workflow "$($selectedWorkflow.id)" --limit 1 --json databaseId,displayTitle,status,conclusion,createdAt,event

    $latestRunInfo = $null
    if (-not ([string]::IsNullOrWhiteSpace($latestRunJson) -or $latestRunJson -eq "[]")) {
        $latestRunArray = $latestRunJson | ConvertFrom-Json
        if ($latestRunArray -and $latestRunArray.Count -gt 0) {
            $latestRunInfo = $latestRunArray[0]
        }
    }

    if (-not $latestRunInfo) {
        Write-Warning "No runs found for workflow '$($selectedWorkflow.name)'."
        exit 0
    }

    Write-Host ("Latest run: '{0}' (ID: {1}, Status: {2}, Conclusion: {3}, Created: {4})" -f $latestRunInfo.displayTitle, $latestRunInfo.databaseId, $latestRunInfo.status, $latestRunInfo.conclusion, $latestRunInfo.createdAt)

    $action = Read-Host -Prompt "Press ENTER to view this latest run, 's' to select from recent runs, or 'q' to quit"

    if ($action -eq 'q') {
        Write-Host "Exiting."
        exit 0
    } elseif ($action -eq 's') {
        Write-Host "Fetching recent runs for workflow '$($selectedWorkflow.name)' (limit $runsLimitForListing)..."
        $recentRunsJson = gh run list --repo "$repoFullName" --workflow "$($selectedWorkflow.id)" --limit $runsLimitForListing --json databaseId,displayTitle,status,conclusion,createdAt,event
        $recentRuns = @()
        if (-not ([string]::IsNullOrWhiteSpace($recentRunsJson) -or $recentRunsJson -eq "[]")) {
             $recentRuns = $recentRunsJson | ConvertFrom-Json
             if ($recentRuns -is [System.Management.Automation.PSCustomObject] -and -not ($recentRuns -is [System.Array])) {
                $recentRuns = @($recentRuns) # Ensure array
            }
        }

        if (-not $recentRuns -or $recentRuns.Count -eq 0) {
            Write-Warning "No runs found to select from for workflow '$($selectedWorkflow.name)'. Using the latest."
            $selectedRunId = $latestRunInfo.databaseId
            $selectedRunDisplayTitle = $latestRunInfo.displayTitle
        } else {
            # Add a 'FormattedName' property for better display in Get-UserChoice
            $recentRunsForChoice = $recentRuns | ForEach-Object {
                $_ | Add-Member -MemberType NoteProperty -Name "FormattedName" -Value ("{0} (Status: {1}, Conclusion: {2}, Created: {3})" -f $_.displayTitle, $_.status, $_.conclusion, $_.createdAt) -PassThru
            }

            $chosenRun = Get-UserChoice -PromptMessage "Select a run:" -Choices $recentRunsForChoice -ChoicePropertyName "FormattedName"
            if (-not $chosenRun) {
                Write-Host "No run selected or quit. Exiting."
                exit 0
            }
            $selectedRunId = $chosenRun.databaseId
            $selectedRunDisplayTitle = $chosenRun.displayTitle
        }
    } else { # Default is Enter, use latest run
        $selectedRunId = $latestRunInfo.databaseId
        $selectedRunDisplayTitle = $latestRunInfo.displayTitle
    }

    Write-Host ("Selected run: '{0}' (ID: {1})" -f $selectedRunDisplayTitle, $selectedRunId)

}
catch {
    Write-Error "Error processing runs for workflow '$($selectedWorkflow.name)': $($_.Exception.Message)"
    exit 1
}


# --- 4. Fetch and Select Job (if applicable) ---
Write-Host "Fetching jobs for run ID '$selectedRunId'..."
$jobs = @()
try {
    $jobsJson = gh run view "$selectedRunId" --repo "$repoFullName" --json jobs --jq '.jobs[] | {name, databaseId, status, conclusion}'
    if ($jobsJson -and $jobsJson -ne "[]") {
      $jobs = $jobsJson | ConvertFrom-Json
      if ($jobs -isnot [System.Array] -and $jobs -is [System.Management.Automation.PSCustomObject]) {
          $jobs = @($jobs)
      }
    }
}
catch {
    Write-Warning "Could not fetch job details for run '$selectedRunId': $($_.Exception.Message)"
    Write-Warning "This might happen if the run failed very early or has no defined jobs."
    Write-Warning "Attempting to view the raw log for the entire run..."
    gh run view "$selectedRunId" --repo "$repoFullName" --log --exit-status
    exit $LASTEXITCODE
}

if (-not $jobs -or $jobs.Count -eq 0) {
    Write-Warning "No jobs found for run ID '$selectedRunId'."
    Write-Warning "This might happen if the run failed before jobs could be created, or if the workflow has no jobs."
    Write-Warning "Attempting to view the raw log for the entire run (this may or may not be available)..."
    gh run view "$selectedRunId" --repo "$repoFullName" --log --exit-status
    exit $LASTEXITCODE
}

$selectedJobId = ""
$selectedJobName = ""

if ($jobs.Count -eq 1) {
    $selectedJobId = $jobs[0].databaseId
    $selectedJobName = $jobs[0].name
    Write-Host "Run has 1 job: '$selectedJobName'. Displaying its log."
}
else {
    # Add a 'FormattedName' property for better display in Get-UserChoice
    $jobsForChoice = $jobs | ForEach-Object {
        $jobStatus = if ($_.conclusion) { $_.conclusion } else { $_.status }
        $_ | Add-Member -MemberType NoteProperty -Name "FormattedName" -Value ("{0} ({1})" -f $_.name, $jobStatus) -PassThru
    }
    $chosenJob = Get-UserChoice -PromptMessage "Multiple jobs found. Select one to view its log:" -Choices $jobsForChoice -ChoicePropertyName "FormattedName"

    if (-not $chosenJob) {
        Write-Host "No job selected or quit. Exiting."
        exit 0
    }
    $selectedJobId = $chosenJob.databaseId
    $selectedJobName = $chosenJob.name # Or $chosenJob.FormattedName if you prefer the full string
    Write-Host "Selected job: '$selectedJobName'"
}

# --- 5. View Log ---
Write-Host "Fetching log for job '$selectedJobName' (ID: $selectedJobId) of run '$selectedRunId'..."
gh run view "$selectedRunId" --repo "$repoFullName" --job "$selectedJobId" --log --exit-status

exit $LASTEXITCODE
