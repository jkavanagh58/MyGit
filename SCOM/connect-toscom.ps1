add-pssnapin "Microsoft.EnterpriseManagement.OperationsManager.Client"
$rmsserver = "mn1ops01.corp.swagelok.lan"
new-managementGroupConnection $rmsserver 
set-location "OperationsManagerMonitoring::" | out-null
#C:\"Program Files"\"System Center Operations Manager 2007"\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Functions.ps1;
"C:\Program Files\System Center Operations Manager 2012\Powershell\OperationsManager\functions.ps1"
Start-OperationsManagerClientShell -ManagementServerName: "mn1ops01.corp.swagelok.lan" -PersistConnection: $true -Interactive: $true;