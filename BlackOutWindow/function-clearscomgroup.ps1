Function clear-scomgroup {
Param(
	[String]$ManagementServer = "WFM-OM12-MSD-02.wfm.wegmans.com",
	$ManagementPackID,
	$GroupID
)
	# Get current contents of SCOM Group
	$objs = (get-scomgroup -ID $GroupID).GetRelatedMonitoringObjects()
	$agents = ($objs.ID | ConvertTo-Csv -NoTypeInformation | select -Skip 1 ) -join ","
	<#
	# 07.07.2017 JJK: Splatting does not work with modifygroupmembership.ps1
	# Since not running via WinRM work on splatted version for ease of reading
	$params = @{
		ManagementServer  = $ManagementServer
		ManagementPackID  = $ManagementPackID
		GroupID           = $GroupID
		InstancesToRemove = $agents
	}
	D:\etc\scripts\modifygroupmembership.ps1 @params
	#>
	$sb = "D:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToRemove $agents"
	invoke-expression $sb
}