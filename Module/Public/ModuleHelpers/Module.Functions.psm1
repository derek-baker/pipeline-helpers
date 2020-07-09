Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop";
#Requires -Version 5.0


function LoadModule(
    [Parameter(mandatory=$true)]
    [string] $moduleNameOrPath,

    [Parameter(mandatory=$true)]
    [bool] $installViaNuGet
) {
    Write-Host -ForegroundColor Yellow "Loading $moduleNameOrPath module..."
    if ($installViaNuGet -eq $false) {
        if ($null -eq (Get-PackageProvider -Name 'NuGet' -ErrorAction SilentlyContinue)) {
            Install-PackageProvider -Name NuGet -Scope CurrentUser -MinimumVersion 2.8.5.201 -Force
        }
        if ($null -eq (Get-Module -Name $moduleNameOrPath -ErrorAction SilentlyContinue)) {        
            Install-Module $moduleNameOrPath -Scope CurrentUser -Force -AllowClobber | Out-Null
        }
    }
    Get-Module -ListAvailable -Refresh | Out-Null  
    Remove-Module $moduleNameOrPath -Force -ErrorAction SilentlyContinue
    Import-Module $moduleNameOrPath -Force
}


Export-ModuleMember -Function "*"