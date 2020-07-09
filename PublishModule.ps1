param(
    [Parameter(mandatory=$true)]
    [string] $apiKey,

    [Parameter(mandatory=$false)]
    [string] $moduleName = 'AzDoPipelineHelpers',

    [Parameter(mandatory=$false)]
    [string] $moduleInstallDir = "$Env:UserProfile\Documents\WindowsPowerShell\Modules\$moduleName"
)

#Requires -Version 5.0
$ErrorActionPreference = "Stop";
Set-StrictMode -Version 'Latest'


function testManifest(
    [Parameter(mandatory=$true)]
    [string] $path
){
    Test-ModuleManifest $path -ErrorAction SilentlyContinue | Out-Null; 
    return $?
}


Import-Module "$PSScriptRoot\Module\Public\DistHelpers\Dist.Files.Functions.psm1" -Force

[string] $moduleDefinitionPath = "$PSScriptRoot\Module\$moduleName.psd1"
[bool] $isValid = testManifest -path $moduleDefinitionPath
if ($isValid -eq $false) {
    Write-Error 'Module invalid'
    exit 1
}

$versionInfo = (Test-ModuleManifest -Path $moduleDefinitionPath).Version
$version = "$($versionInfo.Major).$($versionInfo.Minor).$($versionInfo.Build)"

# INTENT: We want to avoid version conflicts while publishing
Remove-Item -Recurse -Path "$moduleInstallDir\*" -Force -Verbose -ErrorAction SilentlyContinue
CopyDirToIntoOtherDir -sourceDir "$PSScriptRoot\Module\*" -destinationDir "$moduleInstallDir\$version" 

Get-Module -ListAvailable -Refresh | Out-Null

[string] $moduleInstallLocation = "$moduleInstallDir\$version\$moduleName.psm1"


Import-Module $moduleInstallLocation -Force

Publish-Module -Name $moduleName -NuGetApiKey $apiKey 
