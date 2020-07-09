#Requires -Version 5.0
#Requires -Modules  @{ ModuleName="Pester"; ModuleVersion="4.10.1" }
$ErrorActionPreference = "Stop";
Set-StrictMode -Version 'Latest'

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
Import-Module "$PSScriptRoot\$sut" -Force


Describe 'RunSql' -Tags 'Integration' {
    It 'returns hashtable with ExitCode prop set to 0 on success' {
        # Arrange
        [System.Collections.Hashtable] $dbaQueryParams = @{ 
            SqlInstance = $Env:ComputerName
            Query = 'SELECT 1 UNION SELECT 2'
            EnableException = $true
        }
        # Act
        [System.Collections.Hashtable] $actual = RunSql $dbaQueryParams
        
        # Assert
        $actual.ExitCode | Should Be 0        
    }
    It 'returns hashtable with ExitCode prop set to 1 on error' {
        # Arrange
        [System.Collections.Hashtable] $dbaQueryParams = @{ 
            SqlInstance = $Env:ComputerName
            Query = 'SELECT FakeColumn From NonExistentTable'
            EnableException = $true
        }
        # Act
        [System.Collections.Hashtable] $actual = RunSql $dbaQueryParams
        
        # Assert
        $actual.ExitCode | Should Be 1             
    }
    It 'can run non-parameterized SQL' {
        # Arrange
        [System.Collections.Hashtable] $dbaQueryParams = @{ 
            SqlInstance = $Env:ComputerName
            Query = 'SELECT 1 UNION SELECT 2'
            EnableException = $true
        }
        # Act
        [System.Collections.HashTable] $actual = RunSql $dbaQueryParams
        
        # Assert
        $actual['QueryResult'].Length | Should Be 2
        $actual['QueryResult'][0]['Column1'] | Should Be 1        
    }
    It 'can run parameterized SQL' {
        # Arrange
        $expected = 'Bob'        
        $testColumnName = 'Name'
        [System.Collections.Hashtable] $dbaQueryParams = @{ 
            SqlInstance = $Env:ComputerName            
            # TODO: Kind of subverting the reason for using parameterization here...
            Query = "SELECT * FROM (SELECT $testColumnName = 'Bob') AS FauxTable WHERE $testColumnName = @Name"
            SqlParameters = @{ Name = "$expected" }
            EnableException = $true
        }
        # Act
        [System.Collections.HashTable] $actual = RunSql $dbaQueryParams
        
        # Assert
        $actual['QueryResult']["$testColumnName"] | Should Be $expected
    }
}


Describe 'EncryptData' -Tags 'Unit' {
    It 'returns expected' {
        # Arrange
        $expected = 'DXdHfp8jLYdyqUPskaBRc+GMck6FDa50'
        $data = 'diaz-bao'
        # Act
        $actual = EncryptData $data
        # Assert
        $actual | Should Be $expected        
    }
    It 'returns expected' {
        # Arrange
        $expected = 'eEry99yQe228ZcoyOiPqGn4GvNSVvpQN'
        $data = 'password2'
        # Act
        $actual = EncryptData $data
        # Assert
        $actual | Should Be $expected        
    }
}


