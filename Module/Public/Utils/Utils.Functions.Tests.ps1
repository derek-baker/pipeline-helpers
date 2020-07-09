#Requires -Version 5.0
#Requires -Modules  @{ ModuleName="Pester"; ModuleVersion="4.10.1" }
$ErrorActionPreference = "Stop";
Set-StrictMode -Version 'Latest'

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
Import-Module "$PSScriptRoot\$sut" -Force


Describe 'BuildRunAsCredential' -Tags 'Unit' {
    It 'returns expected' {
        # Arrange 
        $user = 'Bob'
        $pass = 'Martin'
        # Act
        $actual = BuildRunAsCredential -runAsUser $user -runAsUserPass $pass
        
        # Assert
        $actual | Should BeOfType System.Management.Automation.PSCredential
        $actual.UserName | Should Be $user
        $actual.Password.Length | Should Be $pass.Length
    }
}


Describe 'HandleExitCode' -Tags 'Unit' {
    It 'performs expected when code param is 1' {
        # Arrange 
        $expected = 'The message'
        # Act
        try {
            HandleExitCode -code 1 -msg "$expected"
        }
        catch {
            $_.Exception.Message | Should Be $expected
        }
    }
    It 'performs expected when code param is 0' {
        # Arrange 
        $input = 0
        # Act
        [int] $actual = HandleExitCode -code 0 -msg "Non-problem message"
        $actual | Should Be $input
    }
}



