<#
.SYNOPSIS
	Demo - SCOM PowerShell without console installed
.DESCRIPTION
	Demo - SCOM PowerShell without console installed
.EXAMPLE
	C:\etc\scripts>.\test-omremoting.ps1
	Example of how to use this script
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		05.24.2017
	Created by:		John Kavanagh
	Organization:	TekSystems
	Filename:		test-omremoting.ps1
	===========================================================================
	05.24.2017 JJK: Just demo against test SCOM. Creates session, imports session with module 
					runs some basic cmdlets.
#>
$remotecall = @"
Import-Module OperationsManager
Get-ScomAgent -Name "*" | Select-Object -Property Name, Version, HealthState, ManuallyInstalled | Format-Table -AutoSize
"@
$scomgrey = @"
	$WCC = get-SCOMclass -name "Microsoft.SystemCenter.Agent"
	# Query agents for Non-Reporting
	$MO = Get-SCOMMonitoringObject -monitoringclass:$WCC | where-object {$_.IsAvailable -eq $false} 
	$MO | sort-object -Property DisplayName | where-object {
    $curobj = New-Object PSObject -Property @{
        Server          = $_.DisplayName
        MaintenanceMode = $_.inMaintenanceMode
        Online          = "Won't perform ping"
    }
    # Copy current object to cumulative report
    $Report += $curobj
}
# Export resulting report
$Report
"@
If (!($admcreds)){
	# Store admin account credentials
	$admcreds = Get-Credential
}
# Need loop to clear any PSSession
if (get-pssession){get-pssession | remove-pssession}
#$OpsMgr = New-Pssession -computername "tst-om12-msm-02.test.wfm.local" -Credential $admcreds -Name OpsMgr -Authentication Kerberos
$OpsMgr = New-Pssession -computername "WFM-OM12-MSM-02.wfm.wegmans.com" -Credential $admcreds -Name OpsMgr -Authentication Kerberos
# Simple query for all Agent Managed Objects
<#
invoke-command -Session $opsMgr -ScriptBlock{
	"Connected to SCOM"
	import-module OperationsManager
	Get-SCOMManagementServer
	get-scomagent -Name "*" | Select-Object -Property Name, Version, HealthState, ManuallyInstalled | Format-Table -AutoSize
}
#>
invoke-command -Session $OpsMgr -ScriptBlock {$scomgrey}
