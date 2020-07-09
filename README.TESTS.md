### TEST FRAMEWORK: PESTER 4.10.1

    PESTER DOCS: 
        https://pester.dev/docs/introduction/installation
        https://pester.dev/docs/usage/testdrive
        https://pester.dev/docs/commands/BeforeEach

#### To run a single test
    Invoke-Pester -Script <REL_OR_ABS_PATH_TO_TEST_SCRIPT>
    EX: Invoke-Pester -Script .\_Install.Service.Functions.Tests.ps1


#### To run all tests
    cd <DIR_WITH_TESTS>
    Invoke-Pester