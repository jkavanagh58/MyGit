[System.String]$ManagementServer = "WFM-OM12-MSM-03.wfm.wegmans.com"
Start-OperationsManagerClientShell -ManagementServerName: $ManagementServer -PersistConnection: $true -Interactive: $true
$groupname = "WFM - Windows-Svr-MW - Production - 1.Monday 04:00am-06:00am"
$SCOMGroup = get-scomgroup -DisplayName $groupname -ErrorAction Stop
$SCOMMP = get-scommanagementpack -DisplayName $groupname -ErrorAction Stop
# Create base parameters for remote execution of modifygroupmembership.ps1
$ManagementPackID = $SCOMMP.Name
$GroupID = $SCOMGroup.FullName
$objs = (get-scomgroup -DisplayName $GroupName).GetRelatedMonitoringObjects()
ForEach ($val in $agentIDs){
    $Instances += (get-scomclassinstance -DisplayName $val.id).ID
    #Write-Verbose -Message "[PROCESS]$($Instances.count) for $($machinename)"
}
$toremove = ($instances | ConvertTo-Csv -NoTypeInformation | select-object -Skip 1 ) -join ","
<#
    ForEach ($val in $objs) {
        $toremove += $val.id.Guid.ToString()
    }
#>
Invoke-Command -ScriptBlock {C:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToRemove $toremove} -OutVariable testout


# To test.. 
get-scomclassinstance -Name $val.Name | select ID