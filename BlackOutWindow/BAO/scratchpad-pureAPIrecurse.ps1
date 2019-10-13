# Connect to OpsMgr
$omServer = "wfm-om12-msm-03.wfm.wegmans.com"
$startOperationsManagerClientShellSplat = @{
    PersistConnection    = $true
    Interactive          = $true
    ManagementServerName = $omServer
}
Start-OperationsManagerClientShell @startOperationsManagerClientShellSplat | Out-Null

# Test case
$srv = "wfm-wintel-02"
$serverObject = get-scomagent -Name ([System.Net.DNS]::GetHostByName($srv).HostName) -ErrorAction Stop
$endMaintWind = (Get-Date).AddMinutes(60)


$class = get-scomclass -name ’Microsoft.Windows.Computer’
$computer = get-scomclassinstance -Class $class | Where-Object {$_.Name -eq $serverObject.DisplayName}

eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
# API Method
$class = get-scomclass -name ’Microsoft.Windows.Computer’
$computer = get-scomclassinstance -Class $class | Where-Object {$_.Name -eq $serverObject.DisplayName}
$windowReason =  "ApplicationInstallation"
$windowComment = "Testing SCOM API Method"
$windowDuration = 30
$computer.ScheduleMaintenanceMode(
    [datetime]::Now.touniversaltime(), 
    ([datetime]::Now).addminutes($windowDuration).touniversaltime(),
     "$windowReason", 
     "$windowsComment" ,
      "Recursive"
)


# Quick Report
Get-SCOMClassInstance -DisplayName "*wfm-wintel-02*" | %{$_.GetMaintenanceWindowHistory()}
Get-SCOMClassInstance -DisplayName "*wfm-wintel-02*" | %{$_.GetMaintenanceWindow()}

# Test extending window
# 12.14.2018 JJK:	Value for adding to current window requires use of ToLocalTime()
$newEnd = $computer.GetMaintenanceWindow().scheduledEndTime.AddMinutes(15)
$computer.UpdateMaintenanceMode(
    $computer.GetMaintenanceWindow().ScheduledEndTime.ToLocalTime().addminutes(15).touniversaltime(),
    [Microsoft.EnterpriseManagement.Monitoring.MaintenanceModeReason]::PlannedOther,
    [System.string]::"Adding 15 minutes to the end time.",
    [Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive
)
$computer.StopMaintenanceMode([DateTime]::Now.ToUniversalTime(),[Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive)