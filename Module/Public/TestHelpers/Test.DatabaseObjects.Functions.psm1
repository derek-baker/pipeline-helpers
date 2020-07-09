# DOCS: https://dbatools.io/commands/

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop";
#Requires -Version 5.0

function _loadDbaTools() {
    [string] $originalLocation = (Get-Location).Path
    Set-Location $PSScriptRoot 
    $scriptRootParent = (Get-Item .).Parent.FullName
    Import-Module "$scriptRootParent\ModuleHelpers\Module.Functions.psm1"
    LoadModule -moduleNameOrPath 'dbatools' -installViaNuGet $true
    return $originalLocation
}


# INTENT: Ensure views were created accurately / kept up to date with schema changes
function ValidateViews(
    [Parameter(mandatory=$true)]
    [string] $dbInstance,
    
    [Parameter(mandatory=$true)]
    [string] $dbName,

    [Parameter(mandatory=$true)]
    [string] $schema    
) {
    [string] $originalLocation = _loadDbaTools
    $views = Get-DbaDbView -SqlInstance $dbInstance -Database $dbName 

    $appViews = $views | Where-Object { $_.Schema -eq $schema } 
    foreach ($view in $appViews) {
        try {
            $result = Invoke-DbaQuery `
                -SqlInstance $dbInstance `
                -Database $dbName `
                -Query $("SELECT * FROM $dbName.$schema.$($view.Name)") `
                -EnableException                
        }
        catch {
            # INTENT: Avoid interfering with work directories in consuming scripts
            Set-Location $originalLocation
            Write-Host $_
            return 1
        }
    }
    # INTENT: Avoid interfering with work directories in consuming scripts
    Set-Location $originalLocation
    return 0
}


# INTENT: Ensure stored procedures were created accurately / kept up to date with schema changes
# NOTE: This will fail if any procs with params lack default args
function ValidateStoredProcedures(
    [Parameter(mandatory=$true)]
    [string] $dbInstance,
    
    [Parameter(mandatory=$true)]
    [string] $dbName,

    [Parameter(mandatory=$true)]
    [string] $schema    
) {
    [string] $originalLocation = _loadDbaTools
    $storedProcedures = Get-DbaDbStoredProcedure -SqlInstance $dbInstance -Database $dbName 

    $appProcs = $storedProcedures | Where-Object { $_.Schema -eq $schema } 
    foreach ($proc in $appProcs) {
        try {
            $result = Invoke-DbaQuery `
                -SqlInstance $dbInstance `
                -Database $dbName `
                -Query $("EXEC $dbName.$schema.$($proc.Name)") `
                -EnableException                
        }
        catch {
            # INTENT: Avoid interfering with work directories in consuming scripts
            Set-Location $originalLocation
            Write-Host $_
            return 1
        }
    }
    # INTENT: Avoid interfering with work directories in consuming scripts
    Set-Location $originalLocation
    return 0
}



Export-ModuleMember -Function "*"