#Requires -Modules ImportExcel
<#
.SYNOPSIS
	Report for verifying SCOM Patching groups.
.DESCRIPTION
	Produces a report of the Patching related SCOM groups. Identifying the group name, the LastModified and
	Number of members of the group. This report would be used to verify that the Synch process completed
	with expected results. Will be called upon completion of the synch script.
.PARAMETER Report
	Array of objects built from each group and accumulated into this array.
.PARAMETER patchGroups
	Variable used to store all group objects returned from SCOM matching the naming pattern.
.PARAMETER rptFile
	Full path including file name for the created Excel file.
.PARAMETER grpMembers
	Process collects the Group Members for each group to report the count of members.
.OUTPUTS
	Excel File
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		08.08.2017
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		get-scomBOgroupInfo.ps1
	===========================================================================
	08.09.2017 JJK:	Report file cleanup process
	08.09.2017 JJK:	TODO: Expand memory cleanup process
	08.10.2017 JJK:	Added report files process
	08.10.2017 JJK:	TODO: Add CCM group members dataset to report
	08.20.2017 JJK:	Replaced replace with trim to form Name of Group in CCM
	08.22.2017 JJK: Adjusted report file cleanup since sync being run for indiv days
	08.23.2017 JJK: Trying to determine why script is not honoring rptName variable as passed from sync script
	08.23.2017 JJK: Properly format SCOM Group query with using when formatting query string
	09.25.2017 JJK: Dynamically create report filename to create library of reports.
	06.07.2018 JJK: TODO:Modify report into single file with tabs for report run
	11.08.2018 JJK:	TODO: Change copy-item to move-item
#>

[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
Param(
	[String]$SiteServer = 'wfm-cm12-PS-01',
	[String]$rptName
)
Begin {
	$OpsMgr = New-Pssession -computername "WFM-OM12-MSM-01.wfm.wegmans.com" -Credential $admcreds -Name OpsMgr -Authentication Kerberos
	Invoke-Command -Session $opsMgr -ScriptBlock {Start-OperationsManagerClientShell -ManagementServerName: "wfm-om12-msm-01.wfm.wegmans.com" -PersistConnection: $true -Interactive: $true} | out-null
	# Get the SCOM groups that match the patching name convention, groups are returned as objects
	# Need to filter for groups using rptName variable
	$patchGroups = Invoke-Command -Session $OpsMgr -ScriptBlock {get-scomgroup -DisplayName "WFM - Windows-Svr-MW - Production*$using:rptName*"}
	$rptFile = "c:\jobs\SCOM\MaintenanceMode\BlackOutWindowGroups{0}.xlsx" -F (get-date -Format "MMyyyy")
	$Report = @()
}
Process {
	ForEach ($grp in $patchGroups | sort-object -Property DisplayName){
		$grpMembers = Invoke-Command -Session $OpsMgr -ScriptBlock {(Get-SCOMGroup -DisplayName $using:grp.DisplayName).GetRelatedMonitoringObjects()}
		$modFromUTC = [System.TimeZone]::CurrentTimeZone.ToLocalTime($grp.LastModified)
		# Query CCM group for member count
		$ccmgrpName = $grp.DisplayName.Trim("WFM - Windows-")
		$collQuery = @{
			Computername = $siteServer
			NameSpace    = "ROOT\SMS\site_P12"
			Class        = "SMS_Collection"
			Filter       = "Name='$ccmgrpName'"
		}
		$ccmColl = Get-WmiObject @collQuery
		$obj = [pscustomobject]@{
			GroupName      = $grp.DisplayName
			Modified       = $modFromUTC
			TotalObjects   = $grpMembers.Count
			CCMMemberCount = $ccmColl.MemberCount
		}
		$Report += $obj
	}
}
End {
	# Remove existing report file if it exists
	If (test-path $rptFile -PathType Leaf){
		If (((get-date)-(gci $rptFile).LastWriteTime).TotalDays -gt 7){
			Remove-Item -$rptFile -Force
		}
	}
	# Splat the parameters to be sent to the export-excel cmdlet
	$excelParams = @{
		Path = $rptFile
		WorkSheetName = "GroupStats "
		AutoSize      = $True
		FreezeTopRow  = $True
	}
	# Create report file using the splatted parameters
	$Report | Export-Excel @excelParams
	# Archive report
	copy-item $rptFile -Destination "\\wfm.wegmans.com\Departments\InformationTechnology\TechWintel\.Scripts\SCOM\MaintenanceMode\BlackOutWindowReport.xlsx" -Force
	# End WinRM session
	$OpsMgr | Remove-PSSession
	# Clear variables from memory and initiate memory garbage collection
	Remove-Variable -Name patchgroups, rptFile, Report, obj,grpMembers
	[System.GC]::Collect()
}