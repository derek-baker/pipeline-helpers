#Requires -Version 5.0
#Requires -Modules  @{ ModuleName='Pester'; ModuleVersion='4.10.1' }
$ErrorActionPreference = 'Stop';
Set-StrictMode -Version 'Latest'

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
Import-Module "$PSScriptRoot\$sut" -Force


Describe 'BackUpDir()' -Tags 'Unit' {
    # Arrange
    $expected = $true
    $testDirToCopy = 'TestDrive:\somedir'
    New-Item -ItemType Directory -Path $testDirToCopy
    $testFile = 'test.txt'
    $testDirFile = "$testDirToCopy\$testFile"
    New-Item -ItemType File -Path $testDirFile
    $expectedNewDirLocation = "$testDirToCopy.BAK"

    # Act
    BackUpDir -srcDir $testDirToCopy -newDirPostFix 'BAK'
    
    # Assert
    It "Backs up dir" {
        (Test-Path -Path $expectedNewDirLocation) | Should Be $expected
    }
    It "Backs up file in dir" {
        (Test-Path -Path "$expectedNewDirLocation\$testFile") | Should Be $expected
    }
}


Describe 'PurgeUnnecessaryFilesFromSource()' -Tags 'Unit' {
    # Arrange
    BeforeEach {
        $testDir = 'TestDrive:\somedir'
        $testFile1 = 'config.json'
        $testFile2 = 'app.config'
        $testFile1Path = "$testDir\$testFile1"
        $testFile2Path = "$testDir\$testFile2"

        New-Item -ItemType Directory -Path $testDir -Force
        New-Item -ItemType File -Path $testFile1Path -Force
        New-Item -ItemType File -Path $testFile2Path -Force
    }

    It "Does purge file from source dir when -preserveSettings is true" {
        $preserveSettings = $true
        # Act
        PurgeUnnecessaryFilesFromSource `
            -preserveSettings $preserveSettings `
            -workDir $testDir `
            -filesToNotInstall @($testFile1, $testFile2)
        $actual = Test-Path -Path $testFile1Path
        $actual = Test-Path -Path $testFile2Path
        # Assert
        $actual | Should Be $false
    }

    It "Doesn't purge file from source dir when -preserveSettings is false" {
        $preserveSettings = $false
        # Act
        PurgeUnnecessaryFilesFromSource `
            -preserveSettings $preserveSettings `
            -workDir $testDir `
            -filesToNotInstall @($testFile1, $testFile2)
        $actual = Test-Path -Path $testFile1Path
        $actual = Test-Path -Path $testFile2Path
        # Assert
        $actual | Should Be $true
    }
}


Describe 'CopyNewFilesIntoDir()' -Tags 'Unit' {
    # Arrange
    BeforeEach {
        $testSrcDir = 'TestDrive:\srcdir'
        $subdirName = 'subdir'
        $testSrcSubDir = "$testSrcDir\$subdirName"
        $testDestDir = 'TestDrive:\destdir'
        $testSrcFile = 'Users.json'
        $testSrcFilePath = "$testSrcDir\$testSrcFile"
        $testSrcSubDirFilePath = "$testSrcSubDir\$testSrcFile"
        New-Item -ItemType Directory -Path $testSrcDir -Force
        New-Item -ItemType File -Path $testSrcFilePath -Force
        New-Item -ItemType File -Path $testSrcSubDirFilePath -Force
        Remove-Item -Path $testDestDir -Force -ErrorAction SilentlyContinue
    }
    It "Copies new dir and that dir contains the file" {
        # Act
        CopyNewFilesIntoDir -distArtifactsParentDir $testSrcDir -destDirPath $testDestDir 
        # Assert
        (Test-Path -Path $testDestDir) | Should Be $true
        (Test-Path -Path "$testDestDir\$testSrcFile") | Should Be $true
        (Test-Path -Path "$testSrcSubDirFilePath") | Should Be $true
    }
}


Describe 'UpdateXmlConfigAppSettings()' -Tags 'Unit' {
    # Arrange
    BeforeEach {
        $testDestDir = 'TestDrive:\test'
        $filename = 'AppService.exe.config'
        $filePath = "$testDestDir\$filename"
        $dummyUri = "DummyServiceUri"
        $dummyPort = "DummyPort"
        New-Item -Path $testDestDir -ItemType Directory -Force
        New-Item -Path $filePath -ItemType File -Force
        Set-Content -PassThru $filePath -Value $(@"
        <?xml version="1.0" encoding="utf-8"?>
        <configuration>
          <appSettings>            
            <add key="ClientSettingsProvider_ServiceUri" value="$dummyUri" />
            <add key="ClientSettingsProvider_ServicePort" value="$dummyPort" />
          </appSettings>
        </configuration>        
"@).Trim()

        # NOTE: Ignore PSScriptAnalyzer warning
        $configFilePath = $($filePath).Replace('TestDrive:', (Get-PSDrive TestDrive).Root)
    }

    It "Updates file when -preserveSettings is false" {
        $preserveSettings = $false
        # The values below should not be present in the fixture file prior to update
        $serviceUrl = 'https://host.domain.com'
        $servicePort = '9877'        
        [System.Collections.Hashtable] $settings = @{ 
            ClientSettingsProvider_ServiceUri = $serviceUrl; 
            ClientSettingsProvider_ServicePort = $servicePort 
        }
        # Act
        UpdateXmlConfigAppSettings `
            -preserveSettings $preserveSettings `
            -configFilePath $configFilePath `
            -appSettingsDict $settings                        
        # Assert
        $updatedContent = (Get-Content -Path $configFilePath)
        $updatedContent | Select-String $serviceUrl | Should Not Be $null
        $updatedContent | Select-String $servicePort | Should Not Be $null        
    }

    It "Doesn't update file when -preserveSettings is true" {
        $preserveSettings = $true
        # Act        
        UpdateXmlConfigAppSettings `
            -preserveSettings $preserveSettings `
            -configFilePath $configFilePath `
            -appSettingsDict @{}            
        # Assert
        $updatedContent = (Get-Content -Path $configFilePath)
        $updatedContent | Select-String $dummyUri | Should Not Be $null
        $updatedContent | Select-String $dummyPort | Should Not Be $null
    }
}


Describe 'UpdateXmlConfigAppConnectionStringDataSource()' -Tags 'Unit' {
    # Arrange
    BeforeEach {
        $testDestDir = 'TestDrive:\test'
        $filename = 'AppService.exe.config'
        $filePath = "$testDestDir\$filename"
        $dummyDbInstance = "dummyDbInstance"
        New-Item -Path $testDestDir -ItemType Directory -Force
        New-Item -Path $filePath -ItemType File -Force
        Set-Content -PassThru $filePath -Value $(@"
        <?xml version="1.0" encoding="utf-8"?>
        <configuration>
          <connectionStrings>            
            <add name="AppDbEntities" connectionString="metadata=res://*/Entity.AppDb.csdl|res://*/Entity.AppDb.ssdl|res://*/Entity.AppDb.msl;provider=System.Data.SqlClient;provider connection string=&quot;data source=$dummyDbInstance;initial catalog=TrainingNotifier;Persist Security Info=False;User ID=TrainingNotifier;Password=!Ugb71ZRQ0;MultipleActiveResultSets=True;App=EntityFramework&quot;" providerName="System.Data.EntityClient" />
          </connectionStrings>
        </configuration>        
"@).Trim()

        # NOTE: Ignore PSScriptAnalyzer warning
        $configFilePath = $($filePath).Replace('TestDrive:', (Get-PSDrive TestDrive).Root)
    }

    It "Updates file when -preserveSettings is false" {
        $preserveSettings = $false
        # The values below should not be present in the fixture file prior to update
        $dbInstance = 'TheDatabase'
        # Act
        UpdateXmlConfigAppConnectionStringDataSource `
            -preserveSettings $preserveSettings `
            -configFilePath $configFilePath `
            -dbInstance $dbInstance            
            
        # Assert
        $updatedContent = (Get-Content -Path $configFilePath)        
        $updatedContent | Select-String $dbInstance | Should Not Be $null        
    }

    It "Doesn't update file when -preserveSettings is true" {
        $preserveSettings = $true
        # Act        
        UpdateXmlConfigAppConnectionStringDataSource `
            -preserveSettings $preserveSettings `
            -configFilePath $configFilePath `
            -dbInstance 'RandomDatabase'
        # Assert
        $updatedContent = (Get-Content -Path $configFilePath)
        $updatedContent | Select-String $dummyDbInstance | Should Not Be $null        
    }
}


Describe 'RemoveSensitiveArtifacts()' -Tags 'Unit' {
    # Arrange
    BeforeEach {
        $testDir = 'TestDrive:\test'
        New-Item -ItemType Directory -Path $testDir -Force
        # NOTE: Ignore PSScriptAnalyzer warning
        $literalDirPath = $("$testDir").Replace('TestDrive:', (Get-PSDrive TestDrive).Root)
    }

    It "Removes dir" {        
        $expected = $false
        # Act
        RemoveSensitiveArtifacts -artifactsLocation $literalDirPath
        # Assert
        (Test-Path -Path $literalDirPath) | Should Be $expected        
    }    
}



Describe 'InstallJsonFile()' -Tags 'Unit' {
    # Arrange
    BeforeEach {
        $testDestDir = 'TestDrive:\dest'
        $testFile = 'Users.json'
        $destFilePath = "$testDestDir\$testFile"
        Remove-Item -Path $destFilePath -Force -ErrorAction SilentlyContinue
    }

    It "Doesn't create file when -preserveSettings is true" {
        $preserveSettings = $true
        # Act
        InstallJsonFile `
            -preserveSettings $preserveSettings `
            -filePath $destFilePath `
            -desiredFileContent @(@{}, @{})
        $actual = Test-Path -Path $destFilePath
        # Assert
        $actual | Should Be $false
    }

    It "Does create file when -preserveSettings is false" {
        $preserveSettings = $false
        $expectedValueInFile = 'Administrator'        
        # Act
        InstallJsonFile `
            -preserveSettings $preserveSettings `
            -filePath $destFilePath `
            -desiredFileContent @(
                @{
                    username =  $expectedValueInFile
                    role =  "Admin"
                },
                @{
                    username =  "FakeEditor"
                    role =  "Edit"
                }
            )
        $actual = Test-Path -Path $destFilePath
        # Assert
        $actual | Should Be $true
        $content = (Get-Content $destFilePath)
        $content | Should Not Be $null
        $content | Select-String $expectedValueInFile | Should Not Be $null  
    }
}