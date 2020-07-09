#Requires -Version 5.0
#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop";


# DOCS: http://docs.topshelf-project.com/en/latest/overview/commandline.html
# NOTE: Was unable to reliably remove the service using the methods below and Powershell 5.1 sucks at removing services
# [string] $command = "sc delete $svcName"; $command | cmd.exe
# (Get-WmiObject Win32_Service -filter "name='$svcName'").Delete()
function _uninstallService(
    [Parameter(mandatory=$true)]
    [string] $svcName,

    [Parameter(mandatory=$true)]
    [string] $pathToExe
) {
    Set-Service -Name $svcName -Status Stopped -ErrorAction SilentlyContinue | Out-Null
    if ( (Test-Path -Path $pathToExe) -eq $false) {
        [string] $msg = `
            "ERROR: Service installer EXE not found in $pathToExe. " + 
            "Please manually uninstall the $svcName service (if installed) and re-run this installer."
        throw $msg
    }
    $output = & $pathToExe uninstall -servicename:$svcName | Out-String
    if ($LASTEXITCODE -ne 0) {
        Write-Host "##vso[task.logissue type=error]Unable to uninstall service. $output"                
    }    
}


function _handleReturnCode([int] $code) {
    if ($code -ne 0) {
        Write-Host "Attempting to uninstall service $svcName using EXE $pathToExe"
        Exit 1
    }
}


# DOCS: http://docs.topshelf-project.com/en/latest/overview/commandline.html
# NOTE: Avoiding starting service so we can test this function without worrying about port conflicts
function InstallService(
    [Parameter(mandatory=$true)]
    [string] $svcName,

    [Parameter(mandatory=$true)]
    [string] $pathToExe,

    [Parameter(mandatory=$false)]
    [string] $description
) {
    Write-Host "Attempting to uninstall service $svcName using EXE $pathToExe"
    _uninstallService -svcName $svcName -pathToExe $pathToExe    
    
    # NOTE: This guard seems to produce false positives due to residue left from the service
    # if ($null -eq (Get-Service -Name $svcName -ErrorAction SilentlyContinue)) {
    #     throw "ERROR: Service $svcName is currently installed. Please manually uninstall it and re-run this installer"
    # }
    Write-Host "Attempting to install service $svcName using EXE $pathToExe"
    & $pathToExe install `
        -servicename:$svcName `
        -displayname:$svcName `
        -description $description `
        --autostart `
        --localsystem `
        --delayed
}


function DetermineIfServiceInstalled(
    [Parameter(mandatory=$true)]
    [string] $svcName  
) {
    return ($null -ne (Get-Service $svcName -ErrorAction SilentlyContinue))
}


function StopService(
    [Parameter(mandatory=$true)]
    [string] $svcName    
) {    
    Set-Service -Name $svcName -Status Stopped -Verbose -ErrorAction SilentlyContinue
}


function StartService(
    [Parameter(mandatory=$true)]
    [string] $svcName    
) {    
    $svc = Set-Service -Name $svcName -Status Running -Verbose -PassThru 
    return $svc
}


Export-ModuleMember -Function "*"
