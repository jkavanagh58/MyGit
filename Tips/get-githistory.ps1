#Requires -Modules ImportExcel
<#
.SYNOPSIS
	Report on git repo activity
.DESCRIPTION
	Retrieves the git history of a repo using a custom format. Returned data is written to a PSCustomObject.
.PARAMETER repoPath
	Specifies a path of the cloned repo
.PARAMETER gitSep
	Specifies the seperator character for formating git prety output and then use when creating array objects
.PARAMETER viewReport
	Switch parameter if used the new spreadsheet will be opened
.EXAMPLE
	C:\PS> .\get-githistory.ps1 -logdays 7
	Example of how to use this script to report on activity in the last week
.EXAMPLE
	C:\PS> .\get-githistory.ps1 -logdays 7 -viewReport
	Example of how to use this script to report on activity in the last week and open the Excel file
.OUTPUTS
	System.Management.Automation.PSCustomObject
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		05.11.2018
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		get-githistory.ps1
	===========================================================================
	05.12.2018 JJK: Changed git log output field seperator as commas had been enteterd in commit message
	05.12.2018 JJK: Added custom help so script can be documented as initial script debugged successfully
	05.12.2018 JJK: TODO: Develop better process for setting location to a valid repo path
	05.12.2018 JJK: Testing a process to find local repos for better felxibility, use for parameter validation?
	05.12.2018 JJK: TODO: Use Repos for parameter validation or other presentation at runtime
	05.12.2018 JJK: Removed fully typed field seperator from git pretty and the PSCustom object. Making flexible
					as data entry in commit message could be problematic, for example I use colons and comments so
					I set the gitsep to a semicolon.
	05.14.2018 JJK:	DONE: Add reporting using the ImportExcelModule - working on multiple sheets.
	05.14.2018 JJK:	DONE: Approach reporting with new info git log is repo specific not computer specific
	05.14.2018 JJK:	DONE: Look for git date value - use get-Date to make commit Date easier to read
	05.14.2018 JJK:	Tested new Report format; converted commandling to splat
	07.22.2018 JJK:	Returned to the original git log format due to issues with expanded git fields and possible data entry
					formats.
	07.22.2018 JJK:	DONE: Work on the expanded commit information, need to determine where the formatting can be dealt with
					possible replace statements.
	07.31.2018 JJK:	Expanded commit messages cause linefeed isses
	07.31.2018 JJK:	Blank line necessary to seperate subject from message
	07.31.2918 JJK:	TODO: Clean up the git repo search
	09.18.2018 JJK:	DONE: Remove logStmnt parameter
	09.18.2018 JJK:	DONE: Add parameter for number of days to report on
	09.23.2018 JJK: DONE: Add option to view report at invocation
	02.04.2019 JJK:	DONE: Archive process added
	02.04.2019 JJK: DONE: Add tables to export-excel process
	02.04.2019 JJK:	Removed validateset for Report file. Testing indicated this would be an issue for new user
	02.04.2019 JJK:	Removed extraneous export-exel statement
#>
[CmdletBinding()]
Param (
	[String]$repoPath = "Documents\github\ServiceDelivery",
	[parameter(Mandatory=$False, ValueFromPipeline=$True,
		HelpMessage = "Number of days to report on")]
	[Alias("ReportPeriod")]
	[ValidateRange(1,21)]
	[System.String]$logdays = 7,
	[String]$gitRun = "git.exe",
	[Parameter(Mandatory=$False)]
	[System.Array]$gitRepos,
	[String]$gitSep = "|",
	[String]$wksTabName = (get-date -Format "MM.dd.yyyy"),
	[Parameter(Mandatory=$False, ValueFromPipeline=$True)]
	[System.String]$wksName = "C:\etc\GitActivity.xlsx",
	[Parameter(Mandatory=$False, ValueFromPipeline=$True)]
	[ValidateScript ({Test-Path $_})]
    [System.String]$wksArchive = "C:\users\vndtekjxk\OneDrive - Wegmans Food Markets, Inc\Documents\GitActivity_Archived.xlsx",
	[parameter(Mandatory=$False, ValueFromPipeline=$True,
			HelpMessage = "Used if operator wants to view new report file")]
	[Switch]$ViewReport,
	[parameter(Mandatory=$False, ValueFromPipeline=$False,
		HelpMessage = "Format Excel friendly table name")]
	[System.String]$rptTablename = "git" + (get-date -format MMddyyyy).ToString(),
	[parameter(Mandatory=$False, ValueFromPipeline=$False,
		HelpMessage = "Format Excel friendly Table Style")]
	[System.String]$rptTableStyle = "Medium" + (get-date).Month.ToString()
)
BEGIN {
	Function update-gitreport {
        If (test-path $wksname) {
            $activeSheets = Get-ExcelSheetInfo -Path $wksName | Where-Object {((get-Date) - (Get-Date($_.Name))).TotalDays -gt 30}
            ForEach ($sheet in $activeSheets) {
                # Copy older sheet to archive file
				Copy-ExcelWorkSheet $sheet.path -DestinationWorkbook $wksArchive -DestinationWorkSheet $sheet.name -Verbose
				Write-Information -MessageData "Worksheet moved to Archive File" -InformationAction Continue
                # Remove from Active Sheet
                Write-Information -MessageData "Removing Worksheet from Active based on date" -InformationAction Continue
                Remove-WorkSheet -Path $sheet.path -WorksheetName $sheet.Name -Verbose
            }
		}
		Else {
			Write-Warning -Message "Unable to find source Activity Sheet" -ErrorAction Continue
			Write-Information -MessageData "Creating new GitActivity Report" -InformationAction Continue
		}
	}
	$Report = New-Object System.Collections.ArrayList
}
PROCESS {
    #update-gitreport
	Try {
		# Hard code repo until search logic works
		$automationRepo = join-path $env:userprofile\documents -ChildPath "github\servicedelivery"
		set-location $automationRepo
		# git log --pretty=format:'%Cred%ad%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --since=1.week
		$gitPretty = "%ai$gitSep%s$gitSep%cr$gitSep%an"
		Write-Verbose "[PROCESS]Retrieving git data."
		#git log --pretty=format:$newPretty --since=7.days --abbrev-commit |
		$newPretty = "%ai$gitSep%f$gitSep%cr$gitSep%an$gitSep%s"
		git log --pretty=format:$newPretty --since=$logdays.days --abbrev-commit |
			ForEach {
				$logItem = [PSCustomObject]@{
					Date         = Get-Date($_.Split($gitSep)[0]) -Format "MM.dd.yyyy"
					#Date         = $_.Split($gitSep)[0]
					Subject      = $_.Split($gitSep)[1]
					TimeDuration = $_.Split($gitSep)[2]
					Author       = $_.Split($gitSep)[3]
					Notes        = ($_.Split($gitSep)[4]).ToString()
				}
				Write-Verbose "[BEGIN]Adding record to Report Array"
				$Report.Add($logItem) > $null
			}
}
	Catch {
		"Unable to retrieve git log data"
		$Error[0].Exception.Message
	}
	# $rptTableName Only used for debugging
    $exportExcelSplat = @{
        Path          = $wksName
        AutoSize      = $true
        MoveToStart   = $true
        WorkSheetname = $wksTabName
        TableName     = $rptTablename
        TableStyle    = $rptTableStyle
    }

	if ((Get-ExcelSheetInfo -Path $wksName -ErrorAction SilentlyContinue).Name -eq $wksTabName) {
		# Clear current worksheet
		Write-Verbose "[PROCESS]Clearing data from $($wksTabName)"
		#Export-Excel @exportExcelSplat -ClearSheet
		# write data to cleared tab
		Write-Verbose "[PROCESS ]Writing Data to $($wksName)"
		If ($ViewReport){
			$Report.Where{$_.Subject -notlike "Merge*"} |
			Sort-Object -Property Date |
			Sort-Object -Property Date |
			Export-Excel @exportExcelSplat -ClearSheet -Show
		}
		Else {
			$Report.Where{$_.Subject -notlike "Merge*"} |
			Sort-Object -Property Date |
			Sort-Object -Property Date |
			Export-Excel -ClearSheet  @exportExcelSplat
		}
	}
	Else {
		Write-Verbose "[PROCESS]Writing Data to $($wksName)"
		If ($viewReport){
			$Report.Where{$_.Subject -notlike "Merge*"} |
			Sort-Object -Property Date |
			Export-Excel @exportExcelSplat -Show
		}
		Else {
			$Report.Where{$_.Subject -notlike "Merge*"} |
			Sort-Object -Property Date |
			Export-Excel @exportExcelSplat
		}
	}
}
END {
	Write-Verbose -Message "[END]Script Cleanup"
	Remove-Variable -Name Report, wksName, wksTabname, gitrepos
	[System.GC]::Collect()
}