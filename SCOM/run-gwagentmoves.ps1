$updGW = Get-ManagementServer | where {$_.Name –eq 'is1ops04.swagelok.com'} 
$newGW = Get-ManagementServer | where {$_.Name –eq 'is1ops05.swagelok.com'} 
$agents = Get-Agent | where {$_.PrimaryManagementServerName –eq 'is1ops04.swagelok.com'} 
Set-ManagementServer -AgentManagedComputer: $agents -PrimaryManagementServer: $newGW