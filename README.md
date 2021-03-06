---
services: data-lake-analytics
platforms: powershell
author: matt1883
---

# Data Lake Analytics - Using Azure PowerShell to get input and output paths of a U-SQL job

This script returns a list of input or output paths of a Data Lake Analytics U-SQL job. These paths can be any combination of U-SQL catalog paths, WASB file paths, or ADLS file paths.

## Included script

* [/src/Get-AdlJobIoPath.ps1](https://raw.githubusercontent.com/Azure-Samples/data-lake-analytics-powershell-usql-input-output/master/src/Get-AdlJobIoPath.ps1)

## Prerequisites

1. Install [Azure PowerShell on a Windows machine](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps)
2. Open a new PowerShell session.
3. Log in using ``Login-AzureRmAccount -SubscriptionId <SUBSCRIPTION-ID>``

## How to run the script

1. Copy the contents of [the sample script](https://raw.githubusercontent.com/Azure-Samples/data-lake-analytics-powershell-usql-input-output/master/src/Get-AdlJobIoPath.ps1) to a new local file called ``Get-AdlJobIoPath.ps1``
2. In PowerShell, navigate to the folder containing the script.
3. Run ``Get-AdlJobIoPath.ps1`` using the syntax below.

**Syntax**

```powershell
.\Get-AdlJobIoPath.ps1 [-Account] <string> [-Id] <Guid> [-Direction] {Input | Output}
```

**Example**

```powershell
.\Get-AdlJobIoPath.ps1 -Account contosoadla -Id c3426e86-85f5-4521-b376-e4b3e8d32d8c -Direction Output
```

## Resources

- [Learn more about Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/overview)
- [Learn more about Azure Data Lake Analytics](https://docs.microsoft.com/en-us/azure/data-lake-analytics/)