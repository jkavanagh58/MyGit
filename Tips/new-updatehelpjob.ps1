#Requires -RunAsAdministrator
<#
.SYNOPSIS
	Short description
.DESCRIPTION
	Long description
.EXAMPLE
	PS C:\> <example usage>
	Explanation of what the example does
.INPUTS
	Inputs (if any)
.OUTPUTS
	Output (if any)
.NOTES
	07.15.2018 JJK: TODO: Extract Job Name from splat array
	07.15.2018 JJK: TODO: Add run paramater to launch job upon registration
#>
[CmdletBinding()]
Param (
	#$runJob=$False
)
BEGIN {
	$Option = New-ScheduledJobOption -RunElevated -RequireNetwork
	$Trigger = New-JobTrigger -Daily -At 09:00
}
PROCESS {
	# Test formalizing the jobsplat as an array
	$JobSplat = @{
		Name               = 'PSUpdateHelp'
		ScriptBlock        = {Update-Help}
		Trigger            = $Trigger
		ScheduledJobOption = $Option
	}
	Try {
		$regJob = Register-ScheduledJob @JobSplat
	}
	Catch {
		# Need to pull job name from Splat array
		"Unable to Register Scheduled job $"
	}
}