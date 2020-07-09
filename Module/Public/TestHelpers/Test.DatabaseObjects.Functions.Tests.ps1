#Requires -Version 5.0
#Requires -Modules  @{ ModuleName="Pester"; ModuleVersion="4.10.1" }
$ErrorActionPreference = "Stop";
Set-StrictMode -Version 'Latest'

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
Import-Module "$PSScriptRoot\$sut" -Force


# NOTE: This test depends on the presence of a database so probably won't run in CI
Describe 'ValidateViews returns expected when testing valid views' -Tag 'Integration' {
    # Arrange
    $expected = 0
    
    # Act
    [int] $actual = ValidateViews `
        -dbInstance 'localhost' `
        -dbName 'TODO' `
        -schema 'AppCore' 
    
    # Assert
    It 'returns expected' {
        $actual | Should Be $expected
    }
}


# NOTE: This test depends on the presence of a database so probably won't run in CI
Describe 'ValidateStoredProcedures returns expected when testing valid sprocs' -Tag 'Integration' {
    # Arrange
    $expected = 0
    
    # Act
    [int] $actual = ValidateStoredProcedures `
        -dbInstance 'localhost' `
        -dbName 'TODO' `
        -schema 'AppCore' 
    
    # Assert
    It 'returns expected' {
        $actual | Should Be $expected
    }
}


