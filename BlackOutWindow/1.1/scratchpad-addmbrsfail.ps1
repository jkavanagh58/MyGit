# All of the sudden add functionality is failing
[Parameter(Mandatory=$false,
HelpMessage = "CFGMGR Server")]
[System.String]$SiteServer = 'wfm-cm12-PS-01'
[Parameter(Mandatory=$false,
HelpMessage = "CFGMGR Site Code")]
[System.String]$SiteCode = "P12"
[Parameter(Mandatory=$false,
HelpMessage = "OPSMGR Server")]
[System.String]$ManagementServer = "WFM-OM12-MSM-03.wfm.wegmans.com"
[Parameter(Mandatory=$false,
HelpMessage = "Log file for script transactions")]
[System.String]$LogFile = "C:\Jobs\SCOM\MaintenanceMode\Sync.txt"
[Parameter(Mandatory=$false,
ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true,
HelpMessage = "Enter Day of Patching to be processed")]
[ValidateSet("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")]
[System.String]$PatchWindow
$PatchWindow = "Monday"
$cfgmgrCIM = New-CimSession -Name "CfgMgrCIM" -ComputerName $siteserver
#If ($PatchWindow){
#		$collQuery = @{
#			CimSession = $cfgmgrCIM
#			NameSpace  = "ROOT\SMS\site_$SiteCode"
#			ClassName  = "SMS_Collection"
#			Filter     = "Name like 'svr-MW - Production%$PatchWindow%'"
#		}
#}
$ccmcollections = Get-CIMInstance @collQuery | sort-object -Property Name
$testcollection = "P12004E9"
$SCOMDisplay = "WFM - Windows-Svr-MW - Production - 1.Monday 08:00pm-10:00pm"
$SCOMGroup = get-scomgroup -DisplayName $SCOMDisplay -ErrorAction Stop
$SCOMMP = get-scommanagementpack -DisplayName $SCOMDisplay -ErrorAction Stop
# Create base parameters for remote execution of modifygroupmembership.ps1
$ManagementPackID = $SCOMMP.id
$GroupID = $SCOMGroup.FullName
$mbrqry = @{
			CimSession   = $cfgmgrCIM
			Namespace    = "ROOT\SMS\site_$SiteCode"
			Query        = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($testcollection)' order by name"
		}

If ($SMSMembers = Get-CIMInstance @mbrqry) {
    # For Each SMSMember find SCOM Agent
			$Instances = @() # Array used to collect SCOM Agents to be added to $SCOMDisplay Group
			Write-Verbose -Message "Creating a list of SCOM Agents to be added to group."
			ForEach ($member in $SMSMembers | Where {$_.Name -notlike "*-OM12-*"}){
				# Start timer for recording elapsed time to automation db
				$procStart = [System.Diagnostics.StopWatch]::StartNew()
				$Instances = @()
				If ($scomagt = get-scomagent -DNSHostName ($member.Name + ".wfm.wegmans.com")){
					# OpsMgr object verified, gather all objects
					ForEach ($obj in get-scomclassinstance -DisplayName $scomagt.NetworkName){
						#$obj.FullName
						$Instances += $obj.id
					}
				}
			}
			$agents = ($instances | ConvertTo-Csv -NoTypeInformation | select-object -Skip 1 ) -join ","
}
c:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToAdd $agents
c:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $SCOMMP.Name -GroupID $GroupID -InstancesToAdd $testadd

& C:\etc\scripts\ModifyGroupMembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID.Name -GroupID "UINameSpace77422945432847ef965ad6511e56452c.Group" -InstancesToAdd $testadd 
# Issue seems to be with variables being sent, suspect MP ID
C:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $SCOMMP.Name -GroupID $GroupID -InstancesToAdd $test -ErrorAction SilentlyContinue
# Debugging - hard coding the agent works
C:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $SCOMMP.Name -GroupID $GroupID -InstancesToAdd "4ee91786-3867-c7c1-06ec-bc385c9ddf87"