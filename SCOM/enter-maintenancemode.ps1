#=============================================================================#
#                                                                             #
# Start-MaintenanceMode.ps1                                                   #
# Powershell Script to put a SCOM agent into maintenance mode. If the server  #
# is a member of a cluster, it will put the rest of the cluster into          #
# maintenance mode as well.                                                   #
# Author: Jeremy Engel                                                        #
# Date: 04.13.2011                                                            #
# Version: 1.1.0                                                              #
#                                                                             #
#=============================================================================#

Param([Parameter(Mandatory = $true,Position = 1)][string]$Server,
      [Parameter(Mandatory = $true,Position = 2)][string]$Comment = "Unknown",
      [Parameter(Mandatory = $false)][string]$RootMS = "mn1ops01.corp.swagelok.lan",
      [Parameter(Mandatory = $false)][int]$Minutes = 30
      
      )

Add-PSSnapin "Microsoft.EnterpriseManagement.OperationsManager.Client" -ErrorAction SilentlyContinue

$originalPath = Get-Location

$eventLog = New-Object System.Diagnostics.EventLog("Operations Manager")
$eventLog.Source = "Maintenance Mode"

Set-Location "OperationsManagerMonitoring::" -ErrorVariable errSnapin
$null = New-ManagementGroupConnection -ConnectionString $RootMS -ErrorVariable errSnapin 
Set-Location $RootMS -ErrorVariable errSnapin

$agent = Get-Agent | Where-Object { $_.DisplayName –eq $Server -or $_.ComputerName -eq $Server -or $_.PrincipalName -eq $Server }
if(!$agent) { Write-Host "ERROR: $Server is not a monitored system in SCOM." -ForeGroundColor Red; Set-Location $originalPath; return }
$Server = $agent.PrincipalName
$startTime = (Get-Date).ToUniversalTime()
$endTime = $startTime.AddMinutes($Minutes)

if(($clusters = $agent.GetRemotelyManagedComputers())) {
  $clusterNodeClass = Get-MonitoringClass -Name Microsoft.Windows.Cluster.Node
  foreach($cluster in $clusters) {
    $clusterObj = Get-MonitoringClass -Name Microsoft.Windows.Cluster | Get-MonitoringObject -Criteria "Name='$($cluster.ComputerName)'"
    if($clusterObj) {
      $clusterObj.ScheduleMaintenanceMode($startTime,$endTime,"PlannedOther",$Comment,"Recursive")
      $nodes = $clusterObj.GetRelatedMonitoringObjects($clusterNodeClass)
      if($nodes) {
        foreach($node in $nodes) {
          Write-Host "Putting $node into maintenance mode." -ForeGroundColor Green
          $eventLog.MachineName = $node.Name
          $eventLog.WriteEntry("The server entered into maintenance mode $(if($Server -notcontains $node.Name){"on behalf of $Server"}).`r`n`r`nDuration:`t$Minutes minutes`r`nReason:`t$Comment","Information",42)
          }
        }
      }
    Write-Host "Putting $($cluster.Computer) into maintenance mode." -ForeGroundColor Green
    New-MaintenanceWindow -StartTime $startTime -EndTime $endTime -MonitoringObject $cluster.Computer -Reason PlannedOther -Comment $Comment
    }
  }
else {
  Write-Host "Putting $Server into maintenance mode." -ForeGroundColor Green
  $eventLog.WriteEntry("The server entered into maintenance mode.`r`n`r`nDuration:`t$Minutes minutes`r`nReason:`t$Comment","Information",42)
  New-MaintenanceWindow -StartTime $startTime -EndTime $endTime -MonitoringObject $agent.HostComputer -Reason PlannedOther -Comment $Comment
  }

Set-Location $originalPath