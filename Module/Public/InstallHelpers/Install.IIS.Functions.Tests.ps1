# # # Requires -RunAsAdministrator
# #Requires -Version 5.0
# #Requires -Modules  @{ ModuleName='Pester'; ModuleVersion='4.10.1' }
# $ErrorActionPreference = 'Stop';
# Set-StrictMode -Version 'Latest'

# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
# Import-Module "$PSScriptRoot\$sut" -Force


# Describe '_determineIfFeatureIsActive' {
#     # Arrange
#     [string] $expected = 'Disabled'     
#     [string] $featureTested = 'TelnetClient' # <== NOTE: Using a feature we expect is already disabled
#     Disable-WindowsOptionalFeature -Online -FeatureName $featureTested 

#     # Act
#     [string] $actual = _determineIfFeatureIsActive -featureName $featureTested

#     # Assert
#     It "returns expected" {
#         $actual | Should Be $expected
#     }
# }


# Describe '_enableWindowsFeature' {
#     # Arrange
#     [string] $expected = 'True'
#     [string] $featureTested = 'Printing-XPSServices-Features' # <== NOTE: Using a feature we expect is already enabled
#     Disable-WindowsOptionalFeature -Online -FeatureName $featureTested 

#     # Act
#     [string] $actual = _enableWindowsFeature -featureName $featureTested

#     # Assert
#     It "returns expected" {
#         $actual | Should Be $expected
#     }
# }


# Describe 'TestForIISSiteExistence' {
#     # Arrange
#     [string] $expected = $false
    
#     # Act
#     [boolean] $actual = TestForIISSiteExistence -siteName 'NonExistentSite_asdfjkhadf'

#     # Assert
#     It "returns expected" {
#         $actual | Should Be $expected
#     }
# }


# # NOTE: This test requires you to have a local IIS
# Describe 'AddVirtualDirectoryToSite' {
#     # Arrange
#     [string] $expectedTestSiteName = 'SiteForTests'
#     [string] $virDirName = 'TestVirDir'
#     [string] $pathToTestSiteArtifacts = "$Env:systemdrive\inetpub\wwwroot\$expectedTestSiteName"
#     [string] $pathToTestSiteVirDir = "$Env:systemdrive\inetpub\wwwroot\$virDirName"
    
#     # Ensure existence of site dir
#     New-Item -ItemType Directory -Path $pathToTestSiteArtifacts -Force
    
#     # Ensure existence of vir dir dir
#     New-Item -ItemType Directory -Path $pathToTestSiteVirDir -Force
    
#     # Create site to act as parent to vir dir
#     New-WebSite -Name $expectedTestSiteName -Port 80 -HostHeader "TestSite" -PhysicalPath $pathToTestSiteArtifacts -Force
    
#     # Act
#     AddVirtualDirectoryToSite -siteName $expectedTestSiteName -virDirName $virDirName -pathToArtifacts $pathToTestSiteVirDir
    
#     # Assert
#     It "returns expected" {
#         Get-WebVirtualDirectory -Site $expectedTestSiteName | Should Not Be $null
#     }
# }


# Describe 'ConfigureIISFilesystemPermissions()' {
#     # Arrange
#     BeforeEach {
#         # $testDir = 'TestDrive:\somedir'
#         $dirPath = "$PSScriptRoot\TestFixtures\TestDir"
#         New-Item -ItemType Directory -Path $dirPath -Force
#         # NOTE: Couldn't get this test to work with Pester's drive mock (TestDrive)
#         # $dirPath = $($testDir).Replace('TestDrive:', (Get-PSDrive TestDrive).Root)
#     }
#     It "Creates ACL as expected" {
#         $expected = 'FullControl'
#         $usr = 'IIS_IUSRS'
#         # Act
#         ConfigureIISFilesystemPermissions -dirToChmod $dirPath -webUser $usr
#         $rights = ((Get-Acl $dirPath | Select-Object -Property * ).Access `
#             | Where-Object { 
#                 $_.IdentityReference -like "*$usr*" 
#             }).FileSystemRights
#         # Assert
#         $rights | Should Be $expected
#         Remove-Item -Path $dirPath -Force
#     }
# }
