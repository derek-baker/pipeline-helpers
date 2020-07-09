Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop";
#Requires -Version 5.0


# INTENT: Check event viewer for app-specific errors during smoke testing
function CheckEventViewerForErrors(
    [ValidateSet('Application')]
    [Parameter(mandatory=$true)]
    [string] $logName,

    [Parameter(mandatory=$true)]
    [string] $logSource,

    [Parameter(mandatory=$true)]
    [System.DateTime] $dateGreaterThanFilter
) {
    try {
        $logs = Get-EventLog -LogName $logName -Source $logSource 
        $errorLogs = $logs | Where-Object { 
                ($_.TimeGenerated -gt $dateGreaterThanFilter) `
                -and `
                ($_.EntryType -eq 'Error')
            }
        if ($null -ne $errorLogs) {
            return $true
        }
        return $false
    }
    catch {
        # $exception = $_.Exception
        Write-Host -ForegroundColor Red `
            "There are no Event Log entries for $logSource after $dateGreaterThanFilter. Please investigate."
        return $true
    }
}


# INTENT: Check for error log. Presence of error log indicates a problem.
function CheckErrorLogForErrors(
    [Parameter(mandatory=$true)]
    [string] $logFilePath
) {
    if ((Test-Path -Path $logFilePath -PathType Leaf) -eq $true) {
        # TODO: Read log
        return $false;
    }
    return $true;
}


Export-ModuleMember -Function "*"