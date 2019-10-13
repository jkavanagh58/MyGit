# List all maintenance window related SCOM groups a computer is a member of
Start-OperationsManagerClientShell -ManagementServerName: "wfm-om12-msm-01.wfm.wegmans.com" -PersistConnection: $true -Interactive: $true
$SCOMGroups = get-scomgroup -DisplayName "WFM - Windows-Svr-MW - Production - *"
$machine = "rdc-spo-db-01.wfm.wegmans.com"
ForEach($Group in $SCOMGroups | sort DisplayName){
	$memberlist = $Group.GetRelatedMonitoringObjects()
#	"Reviewing {0} members" -f $memberlist.count - Debug only
	If ($memberlist.DisplayName -contains $machine ){
			"`t{0} is a member of {1}" -f $machine, $Group.DisplayName
	}
}