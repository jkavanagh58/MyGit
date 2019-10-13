<#
.SYNOPSIS
	Update all Patching Maintenance Syncs for window creation.
.DESCRIPTION
	Update all Patching Maintenance Syncs for window creation.
.PARAMETER numberWeek
	Specifies the object to be processed.  You can also pipe the objects to this command.
.EXAMPLE
	I ♥ PS # .\update-patchweek.ps1
.INPUTS
	Inputs to this cmdlet (if any)
.OUTPUTS
	Output from this cmdlet (if any)
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		01/12/2018
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		update-patchweek.ps1
	===========================================================================
	02.13.2018 JJK: Code worked but needs to adjust RunAs settings
#>
Param(
	[Parameter(Mandatory = $true,
		ValueFromPipeline = $true,
		HelpMessage = "Week to be used for Scheduled Task Trigger")]
	[ValidateSet("First","Second","Third","Fourth")]
	[System.String]$patchWeek
)
Begin {
	$02CIM = New-CIMSession -computername wfm-wintel-02 -Credential $admcreds
	$tgtTasks = Get-ScheduledTask -CimSession $02CIM -TaskName "SCOM*"
}
Process {
	# Test Code
	$trythis = New-ScheduledTaskTrigger -Weekly -WeeksInterval 3 -DaysOfWeek Sunday -At 2PM
	Write-output "Updating $($tgtTasks.Name)"
	Register-ScheduledTask -TaskName $tgtTasks.Name -Settings $trythis -CimSession $02CIM
}
End {
	Remove-Variable -Name pathWeek
	[System.GC]::Collect()
}