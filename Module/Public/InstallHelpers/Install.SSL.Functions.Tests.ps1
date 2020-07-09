# #Requires -Version 5.0
# #Requires -Modules  @{ ModuleName='Pester'; ModuleVersion='4.10.1' }
# $ErrorActionPreference = 'Stop';
# Set-StrictMode -Version 'Latest'

# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
# $module = Import-Module "$PSScriptRoot\$sut" -Force -PassThru


# Describe 'ExportCert' -Tags 'Unit' {
#     $moduleName = $module.Name

#     It 'returns expected' {
#         # Arrange
#         $expected = "$PSScriptRoot\pfx_temp\temp.pfx"

#         Mock `
#             -ModuleName $moduleName `
#             -CommandName Export-PfxCertificate `
#             -MockWith { return $null }

#         # Act
#         $actual = ExportCert -certThumbPrint '234' -certPass '213' -workDir $PSScriptRoot

#         # Assert
#         $actual | Should Be $expected
#     }    
# }