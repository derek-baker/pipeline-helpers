#Requires -Version 5.0
#Requires -Modules  @{ ModuleName="Pester"; ModuleVersion="4.10.1" }
$ErrorActionPreference = "Stop";
Set-StrictMode -Version 'Latest'

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
Import-Module "$PSScriptRoot\$sut" -Force


Describe 'RunExe' -Tags 'Integration' {
    It 'returns expected when running exe with creds' {
        # Arrange
        $expected = 0
        [string] $pathToExe = "$PSScriptRoot\TODO.exe"

        # Act
        $args = '-v true -h ' + "$Env:ComputerName " + '-d TN_UnitTest -u BuildAgent -p <ASK_DEVOPS>'
        [int] $actual = RunExe -pathToExe $pathToExe -argsString $args

        # Assert
        $actual | Should Be $expected
    }
    It 'returns expected when running exe in integrated mode' {
        # Arrange
        $expected = 0
        [string] $pathToExe = "$PSScriptRoot\TODO.exe"

        # Act
        $args = '-v true -h ' + "$Env:ComputerName " + '-d TN_UnitTest -i true'
        [int] $actual = RunExe -pathToExe $pathToExe -argsString $args

        # Assert
        $actual | Should Be $expected
    }
}



