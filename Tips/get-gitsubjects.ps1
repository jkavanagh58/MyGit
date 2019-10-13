<#
.SYNOPSIS
    Creates a Quick List of Commit Subject Lines
.DESCRIPTION
    Creates a Quick List of Commit Subject Lines. Saves data to Excel file in users Documents folder.
.PARAMETER gitData
    Output from git log is stored in this parameter.
.PARAMETER rptData
    Array for reporting data.
.EXAMPLE
    C:\PS>
    Example of how to use this cmdlet
.NOTES
    ===========================================================================
    Created with:	Visual Studio Code
    Created on:		10.08.2018
    Created by:		Kavanagh, John J.
    Organization:	TEKSystems
    Filename:		get-gitsubjects.ps1
    ===========================================================================
    date initials: Enter first comment here
#>
$gitData = git log --pretty=format:%f --since=3.months
$rptData = [System.Collections.ArrayList]@()
# Create header row
$rptData.add("SubjectLine") | Out-Null
ForEach ($data in $gitData) {
    $rptData.add($data) | Out-Null
}
$exportexcelSplat = @{
    Path       = "$env:userprofile\Documents\Commit_Subjects.XLSX"
    AutoSize   = $true
    Show       = $true
    TableName  = 'Subj_Lines'
    ClearSheet = $true
}
$rptData | Select-Object -Unique | Sort-Object | export-excel @exportexcelSplat 