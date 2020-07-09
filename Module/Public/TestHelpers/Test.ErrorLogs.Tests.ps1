#Requires -Version 5.0
#Requires -Modules  @{ ModuleName="Pester"; ModuleVersion="4.10.1" }
$ErrorActionPreference = "Stop";
Set-StrictMode -Version 'Latest'

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
$module = Import-Module "$PSScriptRoot\$sut" -Force -PassThru


Describe 'CheckEventViewerForErrors' -Tags 'Unit' {
    $moduleName = $module.Name
    $fakeSource = 'NonExistentSource'
    $logName = 'Application'
    $logSource = 'Pester'
    $commandToMock = 'Get-EventLog'
    
    It 'returns $false when there are no entries found for the source' {
        # Arrange
        $expected = $true
        Mock `
            -ModuleName $moduleName `
            -CommandName $commandToMock `
            -MockWith { New-Object System.Exception }
        # Act
        [bool] $actual = CheckEventViewerForErrors `
            -logName $logName `
            -logSource $fakeSource `
            -dateGreaterThanFilter $(Get-Date)
        # Assert
        Assert-MockCalled -ModuleName $moduleName -CommandName $commandToMock
        $actual | Should Be $expected            
    }    
    It 'returns $false when there are entries for the source but no errors' {
        # Arrange
        $expected = $false             
        Mock `
            -ModuleName $moduleName `
            -CommandName $commandToMock `
            -MockWith { return @{ TimeGenerated = Get-Date; EntryType = 'Information' } }             
        # Act
        [bool] $actual = CheckEventViewerForErrors `
            -logName $logName `
            -logSource $logSource `
            -dateGreaterThanFilter (Get-Date).AddDays(-1)
        # Assert
        Assert-MockCalled -ModuleName $moduleName -CommandName $commandToMock 
        $actual | Should Be $expected
    } 
    It 'returns $true when there are error entries for the source' {
        # Arrange
        $expected = $true                
        Mock `
            -ModuleName $moduleName `
            -CommandName $commandToMock `
            -MockWith { return @{ TimeGenerated = Get-Date; EntryType = 'Error' } }             
        # Act
        [bool] $actual = CheckEventViewerForErrors `
            -logName $logName `
            -logSource $logSource `
            -dateGreaterThanFilter (Get-Date).AddDays(-1)
        # Assert
        Assert-MockCalled -ModuleName $moduleName -CommandName $commandToMock 
        $actual | Should Be $expected
    }
}    


Describe 'CheckEventViewerForErrors' -Tags 'Integration' {
    BeforeEach {
        $logSource = "Pester"
        if ($null -eq (Get-EventLog -LogName Application -Source $logSource -ErrorAction SilentlyContinue)) {
            New-EventLog -Source $logSource -LogName Application 
        }
    }
    It 'returns $false when there are no entries found' {
        # Arrange
        [bool] $expected = $false    
        # Act
        [bool] $actual = CheckEventViewerForErrors -logSource 'NonExistentSource' -dateGreaterThanFilter (Get-Date)
        # Assert
        $actual | Should Be $expected
    }
    It 'returns $true when there are entries for the source but no errors' {
        # Arrange
        [bool] $expected = $true    
        Write-EventLog -LogName Application -Source $logSource -Message 'Log for test' -EntryType Information -EventId 0 
        # Act
        [bool] $actual = CheckEventViewerForErrors -logSource $logSource -dateGreaterThanFilter (Get-Date)
        # Assert
        $actual | Should Be $expected
    }
    It 'returns $false when there are error entries for the source' {
        # Arrange
        [bool] $expected = $true    
        Write-EventLog -LogName Application -Source $logSource -Message 'Log for test' -EntryType Error -EventId 0 
        # Act
        [bool] $actual = CheckEventViewerForErrors -logSource $logSource -dateGreaterThanFilter (Get-Date)
        # Assert
        $actual | Should Be $expected
    }
}


