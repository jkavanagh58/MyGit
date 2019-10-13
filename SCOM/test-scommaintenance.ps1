Start-OperationsManagerClientShell -ManagementServerName: "" -PersistConnection: $true -Interactive: $true;
cd \
# -groupName: 'SW - Production Servers' -minutes:600 -comment: 'Prod server patching' -reason: 'PlannedOther' -startMM:$true
$mInstance = get-scomgroup -DisplayName "SW - Domain Controllers - INFONET"
$etime = ((Get-Date)).AddMinutes(10)
Start-SCOMMaintenanceMode -EndTime $etime -Comment "Prod server patching" -Reason PlannedOther -Instance $mInstance