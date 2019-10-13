<#
.SYNOPSIS
	Start MaintenanceMode based on SCOM Group Name
.DESCRIPTION
	Start MaintenanceMode based on SCOM Group Name
.LINK get-scomgroup
	https://docs.microsoft.com/en-us/powershell/systemcenter/systemcenter2016/OperationsManager/vlatest/Get-SCOMGroup
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		07.14.2017
	Created by:		John Kavanagh
	Organization:	TekSystems
	Filename:		schedule-maintenancemode.ps1
	===========================================================================
	07.14.2017 JJK:	COMPLETE: Need to come up with method for reading DOW and time with inconsistent names
	07.25.2017 JJK:	TODO: Use reconnect method versus the function connect-scgroup
	08.02.2017 JJK:	Added DOW function for scheduling ahead
	08.02.2017 JJK:	Updated memory cleanup
	08.02.2017 JJK:	TODO: Error handling for ScheduleMaintenanceMode
	08.02.2017 JJK:	TODO: Validate need for touniversaltime
	08.02.2017 JJK:	Added evaluation to add days for start and end times
	08.02.2017 JJK:	Changed output to only report shortdate on day it will start
	08.02.2017 JJK: BUG: Working with end on same day as start incorrect logic
	08.20.2017 JJK: Sketched out code for enabling existing scheduled tasks for scheduling maintenance mode
	08.20.2017 JJK:	TODO: Find scheduled task verify next run
#>
Param(
	[Parameter(Mandatory=$false,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "Select the reason for placing the SCOM Object in MaintenanceMode")]
	[ValidateSet("SecurityIssue","UnplannedOther","PlannedHardwareMaintenance","UnplannedHardwareMaintenance","PlannedHardwareInstallation","UnplannedHardwareInstallation",
		"PlannedOperatingSystemReconfiguration","UnplannedOperatingSystemReconfiguration", "PlannedApplicationMaintenance", "ApplicationInstallation", "ApplicationUnresponsive",
		"ApplicationUnstable", "SecurityIssue", "LossOfNetworkConnectivity")]
	[Alias("Reason")]
	[String]$maintReason = "SecurityIssue",
	[Parameter(Mandatory=$false,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "Amount of time, in minutes, for the maintenance window")]
	[Alias("WindowLength")]
	[Double]$DurationinMin,
	$maintComment 	= "Testing scripted process for starting Maintenance Mode for Security Patching"
)
Begin {
	Start-OperationsManagerClientShell -ManagementServerName: "wfm-om12-msm-01.wfm.wegmans.com" -PersistConnection: $true -Interactive: $true | out-null
	$patchGroups = get-scomgroup -DisplayName "WFM - Windows-SVR-MW - Production - *"
	Function get-windowtimes {
	# Function that extracts the times for maintenance window based on group name
	Param(
		$val,
		$pattern =[regex]'(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)'
	)
	$Return = @{} # Hash table for returning start and end time
	# 08.03.2017 JJK: casted [DateTime] for each value added
	$times = select-string -InputObject $val -Pattern $pattern -AllMatches | ForEach {$_.matches} | ForEach{[DateTime]$_.Value}
	If ($times[1].TimeOfDay.Hours -eq 0){
        # Timespan for window spans that end at midnight
		$Return.MMStart = get-Date($times[0])
		$Return.MMEnd = (get-date($times[1])).AddDays(1)
	}
	Else{
		switch (New-timespan -Start $times[0] -End $times[0]){
			{$_.TotalHours -lt 1}	{
										$Return.MMStart = get-Date($times[0])
										$Return.MMEnd = (get-date($times[1])).AddDays(1)
									}
			default 				{
										$Return.MMStart = get-Date($times[0])
										$Return.MMEnd = get-date($times[1])
									}
		}
	}
	<# 08.03.2017 Commented out to test new eval logic
	#If ($times.count -ne 2){
		"Unable to continue with {0} times values" -f $times.count
		Break
	}
	If ((new-timespan $times[0] -End $times[1]).TotalHours -lt 1){
		# testing 08.03.2017
		$Return.MMStart = get-Date($times[0])
		$Return.MMEnd = (get-date($times[1])).AddDays(1)
	}
	If ($times[0].Hour -gt $times[1].Hour){
		# Timespan for same day
		$Return.MMStart = get-Date($times[0])
		$Return.MMEnd = get-date($times[1])
	}
    ElseIf ($times[1].TimeOfDay.Hours -eq 0){
        # Timespan for window spans that end at midnight
		$Return.MMStart = get-Date($times[0])
		$Return.MMEnd = (get-date($times[1])).AddDays(1)
	}
	ElseIf ($times[0].TimeOfDay.Hours -eq 0){
        # Timespan for window starts at midnight
		$Return.MMStart = get-Date($times[0])
		$Return.MMEnd = get-date($times[1])
	}
	Else {
		# Timespan for window spans multiple days
		$Return.MMStart = get-Date($times[0])
		$Return.MMEnd = (get-date($times[1])).AddDays(1)
	}
	#>
	Return $Return
	} # end of windowtimes function
	Function get-windowDOW {
	# Function that extracts the Day of the Week for maintenance window based on group name
	Param(
		$val,
		$DOWpattern =[regex]'(Mo(n(day)?)?|Tu(e(sday)?)?|We(d(nesday)?)?|Th(u(rsday)?)?|Fr(i(day)?)?|Sa(t(urday)?)?|Su(n(day)?)?)'
	)
	#$Return = @{}
	Try{
		$val -match $DOWpattern | out-Null
		$windowdow = $matches[0]
		# Determine date based on DOW
		$MMdate = Get-Date
		If ($MMDate.DayOfWeek -eq $windowdow){
			Return $MMdate
		}
		Else {
			while ($MMDate.DayOfWeek -ne $windowdow) {$MMdate = $MMdate.AddDays(1)}
			Return $MMDate
		}
	}
	Catch {
		#"Unable to get Day of Week Value from {0}" -f $val
	}
	} # End of windowDOW function
}
Process {
ForEach ($groupObj in $patchGroups | sort-object -Property DisplayName){
	# $groupObj.DisplayName // Just used for testing
	If ($groupObj.InMaintenanceMode -eq $False){
		try {
			# I will need to come up with method for reading DOW and time with inconsistent names
			# will include code if it has not been recently modified run full sync from ccm
			#"This group was last modified at {0}" -f $groupObj.LastModified
			# Values for Start
			"Maintenance Window Information for {0}" -f $groupObj.DisplayName
			$mmDOW = get-windowDOW -val $groupObj.DisplayName
			$mmTimes = get-windowtimes -val $groupObj.DisplayName
			# Formalize Maintenance Mode Window times
			# Set start time based on DOW found
			$diffVal = $mmDOW - $mmTimes.MMStart
			If ($diffVal.Days -gt 0){
				$mmActualStart = $mmTimes.MMStart.AddDays($diffVal.Days)
			}
			Else {
				$mmActualStart = $mmTimes.MMStart
			}
			# Set end time based on DOW found
			$diffVal = $mmDOW - $mmTimes.MMEnd
			If ($diffVal.Days -gt 0){
				$mmActualEnd = $mmTimes.MMEnd.AddDays($diffVal.Days)
			}
			Else {
				$mmActualEnd = $mmTimes.MMEnd
			}
			$DurationinMin = (new-timespan -Start $MMActualStart -End $mmActualEnd).TotalMinutes
			"`tWindow will start on {0} at {1} and  end {2} for {3} minutes." -f ($mmDOW).ToShortDateString(), $mmActualStart, $mmActualEnd, $DurationinMin
			# Use CIM to enable existing scheduled tasks on
			# $taskCIM = new-cimsession -Computer "WFM-OM12-MSM-03.wfm.wegmans.com"
			# get-scheduledtask -CimSession $taskCIM -TaskName $groupObj.DisplayName | enable-scheduledtask -cimsession $taskCIM
			# Try {
			#	$groupObj.ScheduleMainateMode($MMActualStart,$MMActualEnd,$MaintReason,$MaintComment)
			#}
			#Catch {
			#	"Unable to start MaintenanceMode for {0}" -f  $groupObj.DisplayName
			#}
		}
		catch [System.Exception] {
			"Message: {0}" -f $_.Exception.Message
		}
	}
}
}
End {
	#Remove-Variable -Name mmTimes, mmDOW, groupObj, patchGroups, maintcomment, maintReason, DurationinMin, DOWPattern
	#[System.GC]::Collect()
}