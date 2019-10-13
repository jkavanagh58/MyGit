#Requires -Modules ImportExcel
<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.PARAMETER reportActive
    Full path to active Git Activity Report file
.PARAMETER reportArchive
    Full path to Git Activity Archive file
.EXAMPLE
    C:\PS>
    Example of how to use this cmdlet
.NOTES
    ===========================================================================
    Created with:	Visual Studio Code
    Created on:		12.28.2018
    Created by:		Kavanagh, John J.
    Organization:	TEKSystems
    Filename:		Update-GAR.ps1
    ===========================================================================
    date initials: Enter first comment here
#>
[CmdletBinding()]
Param (
    [parameter(Mandatory=$False, ValueFromPipeline=$False,
        HelpMessage = "Git Activity Report")]
    [System.String]$reportActive = "C:\temp\GitActivity.xlsx",
    [parameter(Mandatory=$False, ValueFromPipeline=$False,
        HelpMessage = "Git Activity Report Archive File")]
    [System.String]$reportArchive = "C:\temp\GitArchive.xlsx",
    [parameter(Mandatory=$False, ValueFromPipeline=$False,
        HelpMessage = "Number of days used for established archival")]
    [int32]$reportMilestone = 30
)
BEGIN {
    $activesheets = get-excelsheetinfo -Path $reportActive
}
PROCESS {
    $workSet = @()
    ForEach ($sheet in $activeSheets){
        If ((([System.DateTime]::Now) - (Get-Date $sheet.Name)).TotalDays -gt $reportMilestone){
            Copy-ExcelWorkSheet -SourceWorkBook $reportActive -SourceWorkSheet $sheet.Name -DestinationWorkbook $reportArchive $sheet.Name
            Write-Information -MessageData "$($sheet.Name) written to Archive file" -InformationAction Continue
            Remove-worksheet -FullName $sheet.Path -WorksheetName $sheet.name
        }
    }
}
END {
    Remove-Variable -Name reportActive, reportarchive, activesheets
    [System.GC]::Collect()
}