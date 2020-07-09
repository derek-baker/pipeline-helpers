Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop";
#Requires -Version 5.0


function BuildRunAsCredential(
    [Parameter(Position=0,mandatory=$true)]
    [string] $runAsUser,

    [Parameter(Position=1,mandatory=$true)]
    [string] $runAsUserPass
) {
    $securePassword = ConvertTo-SecureString $runAsUserPass -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential $runAsUser, $securePassword
    return $credential
}


# TODO: Refactor this to elsewhere
function HandleExitCode(
    [Parameter(mandatory=$true)]    
    [int] $code,

    [Parameter(mandatory=$true)]    
    [string] $msg
) {
    if ($code -ne 0) {
        throw $msg
        # NOTE: Exit with 1 to fail the build
        exit 1;
    }
    return $code
}