<#
.SYNOPSIS
	Report on SCOM Patching Related Groups
.DESCRIPTION
	Produces an Excel file of the SCOM Group Memberships for the SCOM Groups related to the Server Patching process.
.EXAMPLE
	C:\etc\scrits> .\getBlackOutGroupMembers.ps1
	Example of how to use this script.
.OUTPUTS
	BOGroupMembers.xlsx
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		08.07.2017
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		Get-BlackOutGroupMembers.ps1
	===========================================================================
	08.07.2017 JJK:	Create script
	08.07.2017 JJK:	Handle the report path and delete existing report file if exists
	09.11.2017 JJK: TODO: Format spreadsheet to create tabs for groups instead
	09.12.2017 JJK:	Output location for spreadsheet moved to TechWintel share.
	09.12.2017 JJK:	Added memory cleanup
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
Param(
	$rptFile = "\\wfm.wegmans.com\Departments\InformationTechnology\TechWintel\.Scripts\SCOM\MaintenanceMode\BOGroupMembers.xlsx"
)
Begin {
	$OpsMgr = New-Pssession -computername "WFM-OM12-MSM-01.wfm.wegmans.com" -Credential $admcreds -Name OpsMgr -Authentication Kerberos
	Invoke-Command -Session $opsMgr -ScriptBlock {Start-OperationsManagerClientShell -ManagementServerName: "wfm-om12-msm-01.wfm.wegmans.com" -PersistConnection: $true -Interactive: $true} | out-null
	# Get the SCOM groups that match the patching name convention, groups are returned as objects
	$patchGroups = Invoke-Command -Session $OpsMgr -ScriptBlock {get-scomgroup -DisplayName "WFM - Windows-SVR-MW - Production - *"}
	$Report = @()
}
Process {
	forEach ($grp in $patchGroups | Sort DisplayName){
		$grpObj = Invoke-Command -Session $OpsMgr -ScriptBlock {
			Param($icmgrp)
			Get-SCOMGroup -DisplayName $icmgrp.DisplayName | Get-SCOMClassInstance} -ArgumentList $grp
		ForEach ($val in $grpObj){
			$obj = [pscustomobject]@{
				GroupName  = $grp.DisplayName
				ObjectName = $val.FullName
			}
			$Report += $obj
		}
	}
}
End {
	# Validate Report location
	# Check for existing file

	If (test-path $rptFile){
		Try{
			"Deleting existing report"
			Remove-Item $rptFile -Force
		}
		Catch {
			"Unable to Delete existing Report"
		}
	}
	$excelparams = @{
		Path          = $rptFile
		WorkSheetName = "Patch Group Members"
		TableName     = "SCOMMMGroups"
		TableStyle    = "Medium1"
		AutoSize      = $True
	}
	$Report | export-Excel @excelparams
	Remove-Variable -Name rptFile, Report, patchGroups, grpObj
	get-pssession | remove-pssession
	[System.GC]::Collect()
}