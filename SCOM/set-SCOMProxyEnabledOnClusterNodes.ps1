$rootMS = "MN1OPS01.corp.swagelok.lan"
$targetClass = "Microsoft.Windows.Cluster.Service";
Set-Location OperationsManagerMonitoring::
New-ManagementGroupConnection $rootMS
Set-Location $rootMS
$matches = Get-MonitoringClass -name $targetClass | Get-MonitoringObject | Select-Object
Foreach($object in $matches) {
	[string]$currentAgent = $object.Path 
	$agent = Get-Agent | Where-Object {$_.Name -eq $currentAgent}
	if($agent.proxyingEnabled -eq 'False') 
	{
		Write-Host "$currentAgent doesn't have proxying enabled yet, enabling now"
		$agent.proxyingEnabled = $true;
		$agent.applyChanges();
	}
	else
	{
		Write-Host "Proxying already enabled for $currentAgent, skipping..."
	}
} 


