Import-Module operationsmanager
New-SCOMManagementGroupConnection -ComputerName FQDNSCOMMgmtServer

$MMGroup = Get-SCOMGroup -DisplayName "WFM - Windows-Svr-MW - Production - 1.Monday 01:30am-03:00am"
$Time = ((Get-Date).AddMinutes(150))
$Comment = 'Server Patching'
$Reason = 'PlannedOther'
Start-SCOMMaintenanceMode -Instance $MMGroup -EndTime $Time -Comment "$Comment" -Reason "$Reason"