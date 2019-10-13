<#
.SYNOPSIS
	List SCOM alerts during the week of patching.
.DESCRIPTION
	List SCOM alerts during the week of patching.
.EXAMPLE
	C:\PS> .\get-windowalerts.ps1
	Example of how to use this script
.LINK get-SCOMAlert
	https://docs.microsoft.com/en-us/powershell/systemcenter/systemcenter2016/OperationsManager/vlatest/Get-SCOMAlert
.OUTPUTS
	Excel xlsx
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		08.28.2017
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		get-windowalerts.ps1
	===========================================================================
	08.28.2017 JJK:	DONE: set dates assuming run Sunday after patching
	08.28.2017 JJK:	DONE: use export-excel to create report
	08.28.2017 JJK:	Modified export-excel and added alertList to variable remove
	08.29.2017 JJK:	FIXED: Export-Excel Table naming issues
	08.29.2017 JJK: Done: Convert TimeRaised to LocalTime
	08.31.2017 JJK: FIXME: Resolve method used to determine start and end of query
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
Param(
	[DateTime]$winstart,
	[DateTime]$winend
)
Begin {
	$winstart = (Get-Date).ToUniversalTime()
	$winend   = Get-Date
	# need to get better range for alert report
	$i = 0
	do {
		$winstart = (get-date).AddDays($i)
		$i--
	} until ($winstart.DayofWeek -eq "Monday")
	$i = 0
	do {
		$winend = (get-date).AddDays($i)
		$i--
	} until ($winend.DayofWeek -eq "Thursday")
	$OpsMgr = New-Pssession -computername "WFM-OM12-MSM-01.wfm.wegmans.com" -Credential $admcreds -Name OpsMgr -Authentication Kerberos
	Invoke-Command -Session $opsMgr -ScriptBlock {Start-OperationsManagerClientShell -ManagementServerName: "wfm-om12-msm-01.wfm.wegmans.com" -PersistConnection: $true -Interactive: $true} | out-null
	$alertList = Invoke-Command -Session $OpsMgr -ScriptBlock {
			Param($start,$end)
			$start
			get-SCOMalert | where {$_.TimeRaised -gt $start -And $_.TimeRaised -lt $end}
		} -ArgumentList $winstart, $winend
}
Process {
	if ($alertList.count -ge 1){
		$excelParams = @{
			Path          = "c:\etc\reports\windowalerts.xlsx"
			WorksheetName = "$(get-date -f "MMyyyy") Alerts"
			TableName     = "Alerts$((get-date -f "MMyyyy").toString())"
			TableStyle    = "Medium1"
			AutoSize      = $True
		}
		$alertList | select-Object @{Label="TimeDate";e={$_.TimeRaised.ToLocalTime()}}, NetBIOSComputerName, Name, Severity, Category, MaintenanceModeLastModified, MonitoringObjectPath |
		Sort-Object -Property TimeRaised |
		export-excel @excelParams
	}
}
End {
	get-pssession | Remove-PSSession
	Remove-Variable -Name winstart, winend, alertList
	[System.GC]::Collect()
}