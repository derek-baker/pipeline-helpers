#Requires -Version 5.0
#Requires -Modules  @{ ModuleName="Pester"; ModuleVersion="4.10.1" }
$ErrorActionPreference = "Stop";
Set-StrictMode -Version 'Latest'

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
$module = Import-Module "$PSScriptRoot\$sut" -Force -PassThru


Describe 'DetermineIfServiceInstalled' -Tags 'Unit' {
    It 'returns false when service not present' {
        # Arrange
        [string] $expected = $false
        [string] $serviceName = 'NonExistentService'
        # Act
        [bool] $actual = DetermineIfServiceInstalled -svcName $serviceName 
        # Assert
        $actual | Should Be $expected
    }
    It 'returns true when service present' {
        # Arrange
        [string] $expected = $true
        [string] $serviceName = 'Windows Event Log'
        # Act
        [bool] $actual = DetermineIfServiceInstalled -svcName $serviceName 
        # Assert
        $actual | Should Be $expected
    }
}


Describe 'StopService' -Tags 'Unit' {
    It 'returns false when service not present' {
        # Arrange
        [string] $expected = $false
        [string] $serviceName = 'NonExistentService'
        # Act
        [bool] $actual = DetermineIfServiceInstalled -svcName $serviceName 
        # Assert
        $actual | Should Be $expected
    }
    It 'returns true when service present' {
        # Arrange
        [string] $expected = $true
        [string] $serviceName = 'Windows Event Log'
        # Act
        [bool] $actual = DetermineIfServiceInstalled -svcName $serviceName 
        # Assert
        $actual | Should Be $expected
    }
}


Describe 'StartService using a mock' -Tags 'Unit' {
    $moduleName = $module.Name
    Mock `
        -ModuleName $moduleName `
        -CommandName Set-Service `
        -MockWith { 
            [PSCustomObject] @{ IsPublic=$true; IsSerial=$true; Name='ServiceController'; BaseType='System.ComponentModel.Component' } 
        }

    It 'returns object' {
        # Arrange
        # $expected = $null
        $serviceName = 'DummyService'
        
        # Act
        $actual = StartService -svcName $serviceName 
        # Assert
        $actual | Should Not Be $null
    }    
}


Describe 'StartService' -Tags 'Unit' {
    It 'results in error when service does not exist(IGNORE ERROR MESSAGE!)' {
        # Arrange
        # $expected = $null
        $serviceName = 'DummyService'
        # Act
        $actual = StartService -svcName $serviceName 
        # Assert
        $actual | Should Be $null
    }    
}


# NOTE: This test depends on the presence of an EXE/installer
# DANGER: This test will remove a specified service from your machine
Describe 'InstallService' -Tags 'Integration' {
    # Arrange
    [string] $expected = 'Stopped'
    [string] $serviceName = 'Test_Service' 

    [string] $pathToExe = 'TODO'    

    # Act
    InstallService -svcName $serviceName -pathToExe $pathToExe -description 'DELETE ME'

    [System.ServiceProcess.ServiceController] $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    [string] $actual = if ($null -ne $svc) { $svc.Status } else { '' }

    # Assert
    It 'returns expected' {
        $actual | Should Be $expected
    }
}


