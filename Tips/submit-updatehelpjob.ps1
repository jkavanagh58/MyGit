<#
	.LINK https://king.geek.nz/2018/06/18/powershell-orchestration-with-scheduled-jobs-the-start-of-a-series/
		Courtesy of this author
	.LINK https://king.geek.nz/2018/06/30/exploring-your-options/
		And make your scheduled job even more robust and error free
	07.07.2018 JJK: Changed job name removing spaces
	07.07.2018 JJK: Changed trigger time
	07.07.2018 JJK: Added Requires statement
#>
#Requires -RunAsAdministrator
$Option = New-ScheduledJobOption -RunElevated -RequireNetwork
$Trigger = New-JobTrigger -Daily -At 15:00
$JobSplat = @{
	Name               = 'psUpdateHelp'
	ScriptBlock        = {Update-Help}
	Trigger            = $Trigger
	ScheduledJobOption = $Option
}
Try {
	Register-ScheduledJob @JobSplat | Out-Null
	"Scheduled Job psUpdateHelp registered successfully"
}
Catch {
	Write-Error "Unable to register the psUpdateHelp Job"
}