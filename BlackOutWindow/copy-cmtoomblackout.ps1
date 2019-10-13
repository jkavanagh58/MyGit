[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
Param(
	$SiteServer = 'wfm-cm12-PS-01',
	$SiteCode = 'P12',
	$CollectionName
)
Begin {
	# Setup remote session
	$OpsMgr = New-Pssession -computername "WFM-OM12-MSM-01.wfm.wegmans.com" -Credential $admcreds -Name OpsMgr -Authentication Kerberos
	"Gathering Collection information"
	$collections = get-wmiobject -Computername $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection -Filter "Name like 'svr-MW - Production%Wednesday%'" | sort Name
}
Process {
ForEach ($coll in $collections){
	$collectionname = $coll.name
	#Retrieve SCCM collection by name
	$Collection = get-wmiobject -ComputerName $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection  | where {$_.Name -eq "$CollectionName"}
	#Retrieve members of collection
	$SMSMembers = Get-WmiObject -ComputerName $SiteServer -Namespace  "ROOT\SMS\site_$SiteCode" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($Collection.CollectionID)' order by name"  -credential $admcreds
	$SCOMDisplay = "WFM - Windows-" + $CollectionName
	$SCOMGroup = invoke-command -Session $OpsMgr -ScriptBlock {get-scomgroup -DisplayName $using:SCOMDisplay -ErrorAction Stop}
	$SCOMMP = invoke-command -Session $OpsMgr -ScriptBlock {get-scommanagementpack -DisplayName $using:SCOMDisplay -ErrorAction Stop}
	ForEach ($member in $SMSMembers){
		if ($member.domain = "Wegmans"){
			[String]$machinename = "{0}.wfm.wegmans.com" -f $member.name
			$agentID = invoke-command -Session $OpsMgr -ScriptBlock {get-scomagent -Name $using:machinename -ErrorAction Stop}
			If ($agentID) {
				# SCOM Agent found - add to SCOM Group
				$ManagementServer = "WFM-OM12-MSD-02.wfm.wegmans.com"
				$ManagementPackID = $SCOMMP.Name
				$GroupID = $SCOMGroup.FullName
				$InstancesToAdd = $agentID.ID

				# .\ModifyGroupMembership.ps1 @groupvars
				# Form the scriptblock to pass to the OpsMgr session
				$sb = "D:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToAdd $InstancesToAdd"
				#invoke-command -Session $OpsMgr -ScriptBlock {$sb}
				"Will call modigygroupmembership.ps1 for {0} with the following parameters to add to {1}" -f $machinename, $SCOMGroup.DisplayName | out-file -filePath c:\etc\ccmtoom.txt -append
				"`tManagementServer: {0}" -f $ManagementServer | out-file -filePath c:\etc\ccmtoom.txt -append
				"`tManagementPackID: {0}" -f $ManagementPackID | out-file -filePath c:\etc\ccmtoom.txt -append
				"`tGroupID: {0}" -f $GroupID | out-file -filePath c:\etc\ccmtoom.txt -append
				"`tInstancesToAdd: {0}" -f $InstancesToAdd | out-file -filePath c:\etc\ccmtoom.txt -append
			}
			Else {
				"No SCOM agent found for {0}" -f $member.name | out-file -filePath c:\etc\ccmtoom.txt -append
			}
		}
	}
} # end ForEach of CCM Collections
}
End {
	# Terminate remote session
	get-pssession | remove-pssession
}