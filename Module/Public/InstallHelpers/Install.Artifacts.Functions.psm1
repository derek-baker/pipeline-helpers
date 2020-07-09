Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop";
#Requires -Version 5.0


# INTENT: Should create a timestamped copy of a dir
function BackUpDir(
    [Parameter(mandatory=$true)]
    [string] $srcDir,

    [Parameter(mandatory=$false)]
    [string] $newDirPostfix = "$(Get-Date -f yyyy-MM-dd_hh-mm-ss).BAK"
) {
    try {
        [string] $dest = "$srcDir.$newDirPostfix"
        Move-Item -Path $srcDir -Destination $dest
        return "Backed up existing files to $dest."
    }
    catch {
        return 'Destination dir did not exist yet. Skipped backup.'
    }    
}


# INTENT: Remove artifacts that should not be deployed.
# TODO: Figure out how to make mutually exclusive param sets
#       The first and third params should be mandatory on a mutex basis.
function PurgeUnnecessaryFilesFromSource(
    [Parameter(mandatory=$true)]
    [bool] $preserveSettings,

    [Parameter(mandatory=$true)]
    [string] $workDir,
    
    [Parameter(mandatory=$true)]
    [string[]] $filesToNotInstall 
) {
    # If we do want to preserve existing settings...
    if ($preserveSettings -eq $true) {
        Get-ChildItem -Path $workDir -Recurse | Where-Object {
            # TODO: This is sketchy. It could be the case that two files of the same name exist...
            $filesToNotInstall -contains $_.Name 
        } | ForEach-Object { 
            # ...we'll remove files from source to prevent overwriting existing settings files later
            Remove-Item -Path $_.FullName -Force
        }
        return 'Purged unnecessary files before install.'
    }
}


function CopyNewFilesIntoDir(
    [Parameter(mandatory=$true)]
    [string] $distArtifactsParentDir,

    [Parameter(mandatory=$true)]
    [string] $destDirPath,

    [Parameter(mandatory=$false)]
    [string] $excludePattern = "*_Install*"
) {
    if ( (Test-Path -Path $destDirPath) -eq $false) {
        New-Item -ItemType Directory $destDirPath
    }
    Get-ChildItem -Path $distArtifactsParentDir | `
        Where-Object { 
            $_.Name -notlike $excludePattern 
        } | `
        ForEach-Object {
            Copy-Item $_.FullName -Destination "$destDirPath" -Recurse -Force
        }
    return 'Copied new files.'
}


# WARNING: This code updates <appSettings> values ONLY IF the key (see $appSettingsDict) exists.
function UpdateXmlConfigAppSettings(
    [Parameter(mandatory=$true)]
    [bool] $preserveSettings,

    [Parameter(mandatory=$true)]
    [string] $configFilePath,

    # EX: @{ ClientSettingsProvider_ServiceUri = $serviceUrl; ClientSettingsProvider_ServicePort = $servicePort }
    [Parameter(mandatory=$true)]
    [System.Collections.Hashtable] $appSettingsDict 
) {
    if ($preserveSettings -eq $false) { 
        # Update other config values
        [xml] $webConfig = Get-Content $configFilePath
        foreach($key in $appSettingsDict.Keys) {
            $node = $webConfig.SelectSingleNode("//appSettings/add[@key = '$key']")
            if ($null -ne $node) {
                $node.SetAttribute('value', $appSettingsDict[$key])
            }
            else {
                throw "$appSettingsDict[$key] is not a valid key in AppSettings"
            }
        }
        $webConfig.Save($configFilePath)        
        
        return "Updated $configFilePath''s AppSettings"
    }
    return "Skipped updating $configFilePath''s AppSettings"
}


function UpdateXmlConfigAppConnectionStringDataSource(
    [Parameter(mandatory=$true)]
    [bool] $preserveSettings,

    [Parameter(mandatory=$true)]
    [string] $configFilePath,
    
    [Parameter(mandatory=$true)]
    [string] $dbInstance
) {
    if ($preserveSettings -eq $false) { 
        # Update connection string
        $content = Get-Content $configFilePath
        # NOTE: Below is a RegEx
        $newContent = $content -replace 'data source=.*?;', "data source=$dbInstance;"
        Set-Content -Path $configFilePath -Value $newContent
        
        return "Updated connection string data-source in $configFilePath"
    }
    return "Skipped updating connection string data-source in $configFilePath."
}


function UpdateXmlConfigAppConnectionStringInitialCatalog(
    [Parameter(mandatory=$true)]
    [bool] $preserveSettings,

    [Parameter(mandatory=$true)]
    [string] $configFilePath,
    
    [Parameter(mandatory=$true)]
    [string] $appName
) {
    if ($preserveSettings -eq $false) { 
        # Update connection string
        $content = Get-Content $configFilePath
        # NOTE: Below is a RegEx
        $newContent = $content -replace 'initial catalog=.*?;', "initial catalog=$appName;"
        Set-Content -Path $configFilePath -Value $newContent
        
        return "Updated connection string initial catalog in $configFilePath"
    }
    return "Skipped updating connection string  initial catalog in $configFilePath."
}


function UpdateXmlConfigAppConnectionStringAuthMethod(
    [Parameter(mandatory=$true)]
    [bool] $preserveSettings,

    [Parameter(mandatory=$true)]
    [string] $configFilePath,

    [Parameter(mandatory=$true)]
    [string] $authInfo
) {
    if ($preserveSettings -eq $false) { 
        # Update connection string
        $content = Get-Content $configFilePath
        # NOTE: Below is a RegEx
        $newContent = $content -replace 'Integrated Security=.*?;', $authInfo
        Set-Content -Path $configFilePath -Value $newContent
        
        return "Updated connection string initial catalog in $configFilePath"
    }
    return "Skipped updating connection string  initial catalog in $configFilePath."
}


# INTENT: Some scripts used during install should be deleted
function RemoveSensitiveArtifacts(
    [Parameter(mandatory=$true)]
    [string] $artifactsLocation
) {
    $dir = Get-Item $artifactsLocation
    $dir | Remove-Item -Recurse -Force
}


# NOTE: You may want $desiredFileContent to have a length greater than 1
function InstallJsonFile(
    [Parameter(mandatory=$true)]
    [bool] $preserveSettings,

    [Parameter(mandatory=$true)]
    [string] $filePath,

    # EX: @( @{ username =  "Administrator" }, @{ username =  "FakeEditor" })
    [Parameter(mandatory=$true)]
    [System.Object[]] $desiredFileContent
) {
    if ($preserveSettings -eq $false) {
        if ( (Test-Path -Path $filePath) -eq $false) {
            New-Item -Type File -Path $filePath -Force
        }
        $jsonContent = $desiredFileContent | ConvertTo-Json 
        Set-Content -Path $filePath -Value $jsonContent
        return "Installed JSON file at: $filePath"
    }
}


Export-ModuleMember -Function "*"