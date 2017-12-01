<#
.SYNOPSIS
Retrieves the input or output paths of a Data Lake Analytics U-SQL job.

.DESCRIPTION
This script returns a list of input or output paths of a Data Lake Analytics U-SQL job. These paths can be any combination of U-SQL catalog paths, WASB file paths, or ADLS file paths.
Note: If you choose to depend on this script, please be aware that the structure of the file that this script reads could change in the future.

.PARAMETER Account
The name of the Data Lake Analytics account.

.PARAMETER Id
The Job ID of the job for which input or output paths should be returned. Find the Job ID by using the Get-AdlJob cmdlet or by opening the job in the portal.

.PARAMETER Direction
Indicates whether to return input or output paths. This can be "Input" or "Output".

.EXAMPLE
Get-AdlJobIoPath.ps1 -Account contosoadla -Id c3426e86-85f5-4521-b376-e4b3e8d32d8c -Direction Output
#>

param
(
    [Parameter(Mandatory=$true)]
    [string] $Account,
    [Parameter(Mandatory=$true)]
    [Guid] $Id,
    [ValidateSet("Input", "Output")]
    [Parameter(Mandatory=$true)]
    [string] $Direction
)

try {
    $isInput = $Direction -eq "Input"
    
    # Fetch algebra XML file path
    $job = Get-AdlJob -Account $Account -JobId $Id
    $algebraAdlsFullPath = [Uri]$job.Properties.AlgebraFilePath
    $adlsAccountName = $algebraAdlsFullPath.Host.Split(".")[0]
    $adlsPath = $algebraAdlsFullPath.AbsolutePath

    # Open algebra XML file
    $algebraXmlFileContents = Get-AdlStoreItemContent -Account $adlsAccountName -Path $adlsPath
    $stages = ([xml]$algebraXmlFileContents).ScriptAndGraph.graph.process
    
    $paths = @()

    # For each stage in the algebra XML file, identify the input or output paths
    foreach ($stage in $stages) {
        if ($isInput){
            $items = $stage.input
        }
        else {
            $items = $stage.output
        }

        foreach ($item in $items) {
            if ($item.usqlTableName -ne $null) {
                $newPath = New-Object -TypeName PSObject
                $newPath | Add-Member -MemberType NoteProperty -Name Type -Value "Table"
                $newPath | Add-Member -MemberType NoteProperty -Name Path -Value ($item.usqlTableName)
                $paths += $newPath
            }
            elseif ($item.structuredStream -ne $null) {
                $newPath = New-Object -TypeName PSObject
                $newPath | Add-Member -MemberType NoteProperty -Name Type -Value "StructuredStream"
                $newPath | Add-Member -MemberType NoteProperty -Name Path -Value ($item.structuredStream)
                $paths += $newPath
            }
            elseif ($item.cosmosStream -ne $null) {
                if ($item.cosmosStream.cosmosPath -ne $null) {
                    foreach ($file in $item.cosmosStream) {
                        $newPath = New-Object -TypeName PSObject
                        $newPath | Add-Member -MemberType NoteProperty -Name Type -Value "File"
                        $newPath | Add-Member -MemberType NoteProperty -Name Path -Value ($file.cosmosPath)
                        $paths += $newPath
                    }
                }
                else {
                    $newPath = New-Object -TypeName PSObject
                    $newPath | Add-Member -MemberType NoteProperty -Name Type -Value "File"
                    $newPath | Add-Member -MemberType NoteProperty -Name Path -Value ($item.cosmosStream)
                    $paths += $newPath
                }
            }
        }
    }

    $paths | select -Property Type, Path -Unique
}
catch {
    Write-Error $_
}