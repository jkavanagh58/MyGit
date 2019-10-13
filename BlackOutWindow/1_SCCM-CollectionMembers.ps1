[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
Param(
	$SiteServer = 'wfm-cm12-PS-01',
	$SiteCode = 'P12',
	$Report = @(),
	$CollectionName = 'Svr-MW - Production - 2.Tuesday 02:00pm-04:00pm'
)
Begin {
	$OpsMgr = New-Pssession -computername "WFM-OM12-MSM-01.wfm.wegmans.com" -Credential $admcreds -Name OpsMgr -Authentication Kerberos
}
Process {
#Retrieve SCCM collection by name 
$Collection = get-wmiobject -ComputerName $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection  | where {$_.Name -eq "$CollectionName"} 
#Retrieve members of collection 
$SMSMembers = Get-WmiObject -ComputerName $SiteServer -Namespace  "ROOT\SMS\site_$SiteCode" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($Collection.CollectionID)' order by name"  -credential $admcreds
#$SMSMembers | export-csv "\\wfm.wegmans.com\departments\InformationTechnology\TechWintel\.Scripts\SCOM\MaintenanceMode\Lists\Svr-MW - Production - 2.Tuesday 0200pm-0400pm.csv"
#$wfmMgmtServer = invoke-command -Session $opsmgr -ScriptBlock {get-scommanagementserver | select -First 1}
#$mgmtPack = invoke-command -Session $OpsMgr -Script {get-scommanagementpack -Name "WFM.WindowsSvrMW.Production.Tuesday.pmpm3"  }
ForEach ($member in $SMSMembers){
	if ($member.domain = "Wegmans"){
		[String]$machinename = "{0}.wfm.wegmans.com" -f $member.name 
		$agentID = invoke-command -Session $OpsMgr -ScriptBlock {get-scomagent -Name $using:machinename -ErrorAction Stop} 
		If ($agentID) {
			$groupvars = @{
				ManagementServer = "WFM-OM12-MSD-02.wfm.wegmans.com"
				ManagementPackID = "WFM.WindowsSvrMW.Production.Tuesday.pmpm3"
				GroupID = "UINameSpacecd8429fd66244c7d9053be8ede330c26.Group"
				InstancesToAdd = $agentID.ID
			}
			.\ModifyGroupMembership.ps1 @groupvars
            
        }
        Else {
            "No SCOM agent found for {0]" -f $member.name
        }
	}
}
}
End {
	get-pssession | remove-pssession
}