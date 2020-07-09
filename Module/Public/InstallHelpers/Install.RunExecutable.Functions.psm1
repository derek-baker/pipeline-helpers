Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop";
#Requires -Version 5.0


# TODO
function BuildExeArgs() {
    # TODO
}


function RunExe(
    [Parameter(mandatory=$true)]
    [string] $pathToExe,

    # EX: -v true -h localhost -d <DB_NAME> -i true
    # EX: -v true -h <HOST> -d <DB_NAME> -u <SQL_LOGIN> -p <SQL_LOGIN_PASS>
    [Parameter(mandatory=$true)]
    [string] $argsString
) {
    Write-Host -ForegroundColor Yellow "Running $pathToExe with args $argsString..."
    $process = Start-Process -FilePath $pathToExe -ArgumentList $argsString -PassThru
    $process.WaitForExit()
    return $process.ExitCode
}


Export-ModuleMember -Function "*"