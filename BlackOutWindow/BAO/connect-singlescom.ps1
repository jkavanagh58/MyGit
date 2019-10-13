# Connect to OpsMgr
$omServer = "wfm-om12-msm-03.wfm.wegmans.com"
$startOperationsManagerClientShellSplat = @{
    PersistConnection    = $true
    Interactive          = $true
    ManagementServerName = $omServer
}
Start-OperationsManagerClientShell @startOperationsManagerClientShellSplat | Out-Null

# Test case
# Using admin server
$srv = "wfm-wintel-02"
$serverObject = get-scomagent -Name ([System.Net.DNS]::GetHostByName($srv).HostName) -ErrorAction Stop

# API Method
$class = get-scomclass -name ’Microsoft.Windows.Computer’
$computer = get-scomclassinstance -Class $class | Where-Object {$_.Name -eq $serverObject.DisplayName}
$windowReason =  "ApplicationInstallation"
$windowComment = "Testing SCOM API Method"
$windowDuration = 30
$computer.ScheduleMaintenanceMode([datetime]::Now.touniversaltime(),([datetime]::Now).addminutes($windowDuration).touniversaltime(), "$windowReason", "$windowsComment" , "Recursive")

# Verify Results
$others = Get-SCOMClassInstance -DisplayName "*wfm-wintel-02*"
$others | %{$_.GetMaintenanceWindow()}
# Handling extending an existing Maintenace Window

If ($computer.InMaintenanceMode){
    $windowsDetailsMaintWindow = $computer.GetMaintenanceWindow()
    $windowExtTo = $windowsDetailsMaintWindow.ScheduledEndTime.AddMinutes($windowDuration)
}
Else {
    # Some Code Here
}
# Quick Report
Get-SCOMClassInstance -DisplayName "*wfm-wintel-02*" | %{$_.GetMaintenanceWindowHistory()}
Get-SCOMClassInstance -DisplayName "*wfm-wintel-02*" | %{$_.GetMaintenanceWindow()}