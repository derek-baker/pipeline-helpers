Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop";
#Requires -Version 5.0


function CleanDir(
    [Parameter(mandatory=$true)]
    [string] $pathToDirToClean,

    [Parameter(mandatory=$true)]
    [bool] $shouldClean
) {
    if ( ((Test-Path -Path $pathToDirToClean) -eq $true) -and ($shouldClean -eq $true) ) { 
        Write-Host -ForegroundColor Yellow "Cleaning dir $pathToDirToClean"
        Get-ChildItem $pathToDirToClean | ForEach-Object {
            Remove-Item -Recurse $_.FullName -Force 
        }
    }
}


function CopyDirToIntoOtherDir(
    [Parameter(mandatory=$true)]
    [string] $sourceDir,

    [Parameter(mandatory=$true)]
    [string] $destinationDir
) {
    if ((Test-Path -Path $destinationDir) -eq $false) {
        New-Item -Path $destinationDir -ItemType Directory
    }
    Write-Host -ForegroundColor Yellow "Copying items from $sourceDir into $destinationDir"
    Copy-Item -Path $sourceDir -Destination $destinationDir -Recurse -Force 
}


function EnsureAllFoldersInPathExist(
    [Parameter(mandatory=$true)]
    [string] $path
) {
    # TODO
}


Export-ModuleMember -Function "*"