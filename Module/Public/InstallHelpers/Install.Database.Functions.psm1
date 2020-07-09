Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop";
#Requires -Version 5.0


# TODO: Move to Private?
function _loadDbaTools([string] $moduleName = 'dbatools') {
    [string] $originalLocation = (Get-Location).Path
    Set-Location $PSScriptRoot 
    $scriptRootParent = (Get-Item .).Parent.FullName
    Import-Module "$scriptRootParent\ModuleHelpers\Module.Functions.psm1"
    LoadModule -moduleNameOrPath $moduleName -installViaNuGet $true
    return $originalLocation
}


# DOCS: https://docs.dbatools.io/#Invoke-DbaQuery
# TODO: Stronly typed hash table: New-Object 'System.Collections.Generic.Dictionary[string,int]'
# NOTE: We're using splatting to pass params to Invoke-DbaQuery (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-5.1)
# TODO: This should return an instance of a class
function RunSql(
    # EX: @{ SqlInstance = $Env:ComputerName; Query = 'SELECT 1' }    
    [Parameter(mandatory=$true)]
    [System.Collections.Hashtable] $dbaQueryParams
) {
    [string] $originalLocation = _loadDbaTools
    [System.Collections.Hashtable] $result = @{}
    try {        
        $queryResult = Invoke-DbaQuery @dbaQueryParams          
        $result.QueryResult = $queryResult
        $result.ExitCode = 0
        # TODO: Handle errors with exit 1?
    }
    catch {
        Write-Host -ForegroundColor Red $_
        $result.QueryResult = ''
        $result.ExitCode = 1
    }
    finally {
        # INTENT: Avoid interfering with work directories in consuming scripts
        Set-Location $originalLocation
    }
    return $result
}


# NOTE: This should be kept in sync with encryption used by consumers.
#       Hopefully we'll be able to deprecate it in the future.
function EncryptData(
    [Parameter(mandatory=$true)]
    [string] $data
) {
    [byte[]] $secretKey = @(31, 22, 5, 32, 25, 16, 37, 28)
    [byte[]] $initVector = @(10, 20, 30, 40, 50, 60, 70, 80)
    [byte[]] $inputBuffer = [System.Text.Encoding]::Unicode.GetBytes($data)
    $outputBuffer = [System.Security.Cryptography.DES]::Create().CreateEncryptor(
            $secretKey, 
            $initVector
        ).TransformFinalBlock(
            $inputBuffer, 
            0, 
            $inputBuffer.Length
        )
    return [System.Convert]::ToBase64String($outputBuffer)
}


Export-ModuleMember -Function "*"




