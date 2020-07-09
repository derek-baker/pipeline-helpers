#Requires -Version 5.0
#Requires -Modules  @{ ModuleName="Pester"; ModuleVersion="4.10.1" }
$ErrorActionPreference = "Stop";
Set-StrictMode -Version 'Latest'

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
Import-Module "$PSScriptRoot\$sut" -Force


Describe 'CleanDir()' -Tags 'Unit' {    
    BeforeEach {
        # Arrange
        $testDir = 'TestDrive:\somedir'
        New-Item -ItemType Directory -Path $testDir -Force
        $testFile = 'test.txt'
        $testDirFile = "$testDir\$testFile"
        New-Item -ItemType File -Path $testDirFile -Force
        New-Item -ItemType Directory -Path "$testDir\nestedDir" -Force
    }
    It "Cleans dir when appropriate" {
        # Act
        CleanDir -pathToDirToClean $testDir -shouldClean $true
        # Assert
        (Get-ChildItem -Path $testDir -Recurse) | Should Be $null
    }
    It "Skips cleaning dir when appropriate" {
        # Act
        CleanDir -pathToDirToClean $testDir -shouldClean $false
        # Assert
        (Get-ChildItem -Path $testDir -Recurse) | Should not Be $null
    }
}


Describe 'CopyDirToIntoOtherDir()' -Tags 'Unit' {    
    BeforeEach {
        # Arrange
        $testDir = 'TestDrive:\somedir'
        New-Item -ItemType Directory -Path $testDir -Force
        $testFile = 'test.txt'
        $testDirFile = "$testDir\$testFile"
        New-Item -ItemType File -Path $testDirFile -Force
        New-Item -ItemType Directory -Path "$testDir\nestedDir" -Force
    }    
    
    It "Copies contents of dir" {        
        $dest = 'TestDrive:\destDrive'
        # Act
        CopyDirToIntoOtherDir -sourceDir $testDir -destinationDir $dest
        # Assert
        (Get-ChildItem -Path $dest -Recurse) | Should Not Be $null
        (Get-ChildItem -Path $dest -Recurse).Length | Should Be 3
    }
}



