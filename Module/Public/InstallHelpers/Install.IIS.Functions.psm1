# # DOCS: https://docs.microsoft.com/en-us/iis/get-started/whats-new-in-iis-10/iisadministration-powershell-cmdlets
# # DOCS: CMDLET LIST - https://docs.microsoft.com/en-us/powershell/module/iisadministration/?view=win10-ps

# # DOCS: EXAMPLES: https://blogs.iis.net/jeonghwan/how-to-use-iisadministration-powershell-cmdlets-to-configure-iis-configuration-settings

# # DOCS: https://octopus.com/blog/iis-powershell

# # NOTE: You may need to run this if you have IISAdministration 1.0.0 installed:
# #           Install-Module -Name IISAdministration -AllowClobber -Force

# #Requires -RunAsAdministrator
# #Requires -Version 5.0
# $ErrorActionPreference = "Stop";
# Set-StrictMode -Version 'Latest'


# [string[]] $desiredFeatures = @(
#     'IIS-WebServerRole',
#     'IIS-WebServer',
#     'IIS-CommonHttpFeatures',
#     'IIS-HttpErrors',
#     'IIS-HttpRedirect',
#     'IIS-ApplicationDevelopment',
#     'NetFx4Extended-ASPNET45',
#     'IIS-NetFxExtensibility45',
#     'IIS-HealthAndDiagnostics',
#     'IIS-HttpLogging',
#     'IIS-LoggingLibraries',
#     'IIS-RequestMonitor',
#     'IIS-HttpTracing',
#     'IIS-Security',
#     'IIS-RequestFiltering',
#     'IIS-Performance',
#     'IIS-WebServerManagementTools',
#     'IIS-Metabase',
#     'IIS-ManagementConsole',
#     'IIS-BasicAuthentication',
#     'IIS-WindowsAuthentication',
#     'IIS-StaticContent',
#     'IIS-DefaultDocument',
#     'IIS-WebSockets',
#     'IIS-ApplicationInit',
#     'IIS-ISAPIExtensions',
#     'IIS-ISAPIFilter',
#     'IIS-HttpCompressionStatic',
#     'IIS-ASPNET45'
# )


# # TODO: Move this to the private folder
# function _determineIfFeatureIsActive(
#     [Parameter(mandatory=$true)]
#     [string] $featureName
# ) {
#     (Get-WindowsOptionalFeature -Online | Where-Object FeatureName -eq $featureName).State
# }


# # TODO: Move this to the private folder
# function _enableWindowsFeature(
#     [Parameter(mandatory=$true)]
#     [string] $featureName
# ) {
#     (Enable-WindowsOptionalFeature -Online -FeatureName $featureName).Online
# }


# function InstallIISWebServer(
#     [Parameter(mandatory=$false)]
#     $features = $desiredFeatures
# ) {
#     foreach ($feature in $desiredFeatures) {
#         [string] $result = _determineIfFeatureIsActive -featureName $feature
#         if ($result -eq 'Disabled') {
#             _enableWindowsFeature $feature
#         }
#     }    
# }


# function InstallIISAdminModule(
#     [Parameter(mandatory=$false)]
#     [bool] $clobberIISModule = $true
# ) {
#     Install-Module `
#         -Name IISAdministration `
#         -AllowClobber:$clobberIISModule `
#         -WarningAction SilentlyContinue `
#         -Force 
# }

# function TestForIISSiteExistence(
#     [Parameter(mandatory=$true)]
#     [string] $siteName
# ) {
#     if ($null -eq (Get-IISSite $siteName -WarningAction SilentlyContinue)) {
#         return $false
#     }
#     return $true
# }


# # NOTE: Any sites or app pools that already exist will not be recreated.
# # NOTE: Depends on module IISAdministration having been previously loaded
# # App pool should be created before site so we can add the site to the pool after the site's creation
# function CreateIISWebsite(
#     [Parameter(mandatory=$true)]
#     [string] $siteName,

#     [Parameter(mandatory=$true)]
#     [string] $port,

#     [Parameter(mandatory=$true)]
#     [string] $siteArtifactsFolder,

#     [Parameter(mandatory=$true)]
#     [bool] $useSelfSignedSSLCert
# ) {    
#     # In case previous invocations left one open 
#     Stop-IISCommitDelay -commit $false -WarningAction SilentlyContinue
    
#     $absPathToSiteFiles = "$siteArtifactsFolder"    
    
#     # # App pool should be created before site so we can add the site to the pool after the site's creation
#     $pool = Get-IISAppPool $siteName -WarningAction SilentlyContinue
#     if($null -eq $pool){
#         Write-Host -ForegroundColor Yellow "Creating app pool: $siteName"
#         CreateAppPool -appPoolName $siteName 
#     }        
#     $site = Get-IISSite $siteName -WarningAction SilentlyContinue
#     if($null -eq $site) {
#         Write-Host -ForegroundColor Yellow "Creating site: $siteName"
#         Start-IISCommitDelay    
#         $site = New-IISSite `
#             -Name $siteName `
#             -BindingInformation $("*:8081:" + $siteName) `
#             -PhysicalPath $absPathToSiteFiles `
#             -PassThru
#         # Examples of -BindingInformation: 
#         #    "*:80:"                - Listens on port 80, any IP address, any hostname
#         #    "10.0.0.1:80:"         - Listens on port 80, specific IP address, any host
#         #    "*:80:myhost.com"      - Listens on port 80, specific hostname
        
#         # Set the Application Pool for the newly-created site.
#         $site.Applications["/"].ApplicationPoolName = $siteName
        
#         if ($useSelfSignedSSLCert -eq $true) {
#             $port = "443"
#             $bindingInformation = "*:" + $port + ":" + $siteName
#             $info = CreateSelfSignedCert -siteName $siteName        
#             New-IISSiteBinding -Name $siteName -BindingInformation $bindingInformation `
#                 -CertificateThumbPrint $info['thumbPrint'] -CertStoreLocation $info['storePath'] `
#                 -Protocol https -Verbose -SslFlag 'Sni'
#         }
#         Stop-IISCommitDelay -Commit $true       
#     }
# }


# # NOTE: Depends on WebAdministration module, which depends on IIS being installed
# function AddVirtualDirectoryToSite(
#     [Parameter(mandatory=$true)]
#     [string] $siteName,

#     [Parameter(mandatory=$true)]
#     [string] $virDirName,

#     [Parameter(mandatory=$true)]
#     [string] $pathToArtifacts,

#     [Parameter(mandatory=$true)]
#     [string] $workDir
# ) {
#     Set-Location $PSScriptRoot 
#     $scriptRootParent = (Get-Item .).Parent.FullName
#     Import-Module "$scriptRootParent\ModuleHelpers\Module.Functions.psm1"
#     LoadModule -moduleNameOrPath 'WebAdministration' -installViaNuGet $true

#     if ($null -ne (Get-WebVirtualDirectory -site $siteName -Name "/$virDirName")) {        
#         Remove-Item "IIS:\Sites\$siteName\$virDirName" -Force -Recurse
#     }   
#     # TODO : Use IIS provider (see if() above) to create virtual directory? 
#     New-WebVirtualDirectory -Site "$siteName" -Name $virDirName -PhysicalPath $pathToArtifacts  
#     Set-Location $workDir
# }


# function ConfigureIISFilesystemPermissions(
#     [Parameter(mandatory=$true)]
#     [string] $dirToChmod,

#     [Parameter(mandatory=$false)]
#     [string] $webUser = 'IIS_IUSRS'    
#     # [string] $webUser = 'Everyone'    
# ) {
#     # NOTE: IIS_IUSRS(local user) needs READ/WRITE/MODIFY in $artifactDestinationDir
#     $acl = Get-Acl $dirToChmod
#     $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
#         $webUser,
#         'FullControl', 
#         'ContainerInherit,ObjectInherit', 
#         'None',
#         'Allow'
#     )
#     $acl.SetAccessRule($accessRule)
#     $acl | Set-Acl $dirToChmod
# }


# Export-ModuleMember -Function "*"