# pipeline-helpers

Tools used in build and release pipelines, with a focus on agentsrunning on Windows Servers. Packaging tools in a module allows more reusability, testability, and faster development cycles than otherwise.


## Getting Started

<!--
To browse the API you can use [this](./README.DOCS.md).

If only intending to use the module, use the command below to install from the Powershell Gallery. To contribute to this module, clone this repo.

```
Install-Module AzureDevOpsHelpers -Scope <CurrentUser | AllUsers>
```
-->

### Prerequisites

- Powershell 5/5.1 (YMMV on Powershell Core [6+])
- Pester 4.10.1 


## Running the tests

To run tests, navigate to ./Module/Public, then:

```
Invoke-Pester -Tag 'Unit'
```
Or, to run tests from a specific file:

```
Invoke-Pester -Script <PATH_TO_SCRIPT> -Tag 'Unit'
```

Running integration tests could be done like so, but you'll need to stage dependencies first:

```
Invoke-Pester -Tag 'Integration' 
```



## Versioning

The intent is to use [SemVer](http://semver.org/) for versioning. 



