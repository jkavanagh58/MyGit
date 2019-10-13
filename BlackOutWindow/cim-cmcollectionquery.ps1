# CIM versus WMI example
# Use CIMSession in order to pass alternate credentials
$session = New-CimSession -ComputerName wfm-cm12-ps-01 -Credential $admcreds
$collections = get-ciminstance -CimSession $session -Namespace "ROOT\SMS\Site_p12" -ClassName SMS_Collection -Filter "Name like 'svr-MW - Production%'"
# $collections.where{$_.Name -like "svr-MW - Production*"}
$OpsMgr = New-Pssession -computername "WFM-OM12-MSM-01.wfm.wegmans.com" -Credential $admcreds -Name OpsMgr -Authentication Kerberos
Invoke-Command -Session $OpsMgr -ScriptBlock {Start-OperationsManagerClientShell -ManagementServerName: "wfm-om12-msm-01.wfm.wegmans.com" -PersistConnection: $true -Interactive: $true}
ForEach ($ccmColl in $Collections ){
	"Processing {0} Collection" -f $ccmColl.Name
	<#
	// Conventional Method
	#Retrieve members of collection 
		$mbrqry = @{
				ComputerName = $SiteServer 
				Namespace    = "ROOT\SMS\site_$SiteCode" 
				Query        = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($ccmColl.CollectionID)' order by name"  
		}		
		$SMSMembers = Get-WmiObject @mbrqry
	#>
	$collMembers = Get-CimInstance -CimSession $session -Namespace "ROOT\SMS\Site_p12" -ClassName SMS_FullCollectionMembership -Filter "CollectionID='$($ccmColl.CollectionID)'"
	$SCGrpName = "WFM - Windows-$($ccmColl.Name)"
	$SCGrpMembers = Invoke-Command -Session $OpsMgr -ScriptBlock{get-SCOMGroup -DisplayName $using:SCGrpName | Get-SCOMClassInstance} 
	# Need data field to match ccm collection member
	$SCGrpMembers | select DisplayName, ID
}

# Test Code only
# $grp = Invoke-Command -Session $OpsMgr -ScriptBlock {get-SCOMGroup -DisplayName $using:SCGrpName}