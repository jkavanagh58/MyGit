<#
.SYNOPSIS
	Process to update SCOM Windows for Patching Blackouts
.DESCRIPTION
	Script reads Patching based CCM collections and takes members of collection and adds to the 
	appropriate SCOM Group.
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		06.15.2017
	Created by:		John Kavanagh
	Organization:	TekSystems
	Filename:		Untitled-6
	===========================================================================
	06.15.2017 JJK: TODO: Convert WMI calls to use Filter versus Where or the Query statement
	06.15.2017 JJK: TODO: Determine if multiple domains need to be accounted for, if so change if to switch
	06.15.2017 JJK: Fixed issue with acquiring ManagementPack and Group information due to faulty SCOMDisplay
	06.15.2017 JJK:	TODO: Error handling for issues where no corresponding SCOM object is found
	06.16.2017 JJK: Testing Friday run
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
Param(
	$SiteServer = 'wfm-cm12-PS-01',
	$ManagementServer = "WFM-OM12-MSD-02.wfm.wegmans.com",
	$SiteCode = "P12"
)
Begin {
Function format-scriptblock {
	[CmdletBinding()]
	Param(
		$ms,
		$packID,
		$gid,
		$inst
	)
$var = @"
$([char]36)args = @{
ManagementServer = '$ms'
ManagementPackID = '$packID'
GroupID = '$gid'
InstancesToAdd = $inst
}
d:\etc\scripts\modifygroupmembership.ps1 @args
"@
	Return $var
}
	"Setting up remote session"
	$OpsMgr = New-Pssession -computername "WFM-OM12-MSM-01.wfm.wegmans.com" -Name OpsMgr 
	invoke-command -Session $OpsMgr -ScriptBlock {Import-Module -Name OperationsManager}
	invoke-command -Session $OpsMgr -ScriptBlock {Add-PSSnapin -Name Microsoft.EnterpriseManagement.OperationsManager.Client}
	# Retrieve List of Collections
	$ccmcollections = get-wmiobject -Computername $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection -Filter "Name like 'svr-MW - Production%Thursday%'" | sort Name
	# Load Function for building ScriptBlock for execution
	#. C:\Users\vndtekjxk\Documents\GitHub\ServiceDelivery\BlackOutWindow\format-scriptblock.ps1
}
Process {
	"Found {0} collections" -f $ccmcollections.count
	ForEach ($ccmColl in $ccmcollections){
		"Processing {0} ID: {1}" -f $ccmColl.Name, $ccmColl.CollectionID
		"=" * 62
		#Retrieve members of collection 
		$mbrqry = @{
				ComputerName = $SiteServer 
				Namespace    = "ROOT\SMS\site_$SiteCode" 
				Query        = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($ccmColl.CollectionID)' order by name"  
				credential   = $admcreds
		}
		$SMSMembers = Get-WmiObject @mbrqry
		# "Found {0} members of {1} Collection" -f $SMSMembers.count, $ccmcoll.name
		$SCOMDisplay = "WFM - Windows-" + $ccmcoll.name
		# Perform SCOM queries to generate base parameters 
		$SCOMGroup = invoke-command -Session $OpsMgr -ScriptBlock {get-scomgroup -DisplayName $using:SCOMDisplay -ErrorAction Stop} 
		$SCOMMP = invoke-command -Session $OpsMgr -ScriptBlock {get-scommanagementpack -DisplayName $using:SCOMDisplay -ErrorAction Stop} 
		If ($SCOMGroup -eq $Null -or $SCOMMP -eq $Null){
			"Unable to find corresponding SCOM Objects matching {0} " -f $SCOMDisplay
			Continue
		}
		# Create base parameters for remote execution of modifygroupmembership.ps1
		$ManagementPackID = $SCOMMP.Name
		$GroupID = $SCOMGroup.FullName
		if ($SMSMembers){
			# Formulate a SCOM searchable name
			# For Each SMSMember find SCOM Agent if possible
			$Instances = @() # Array used to collect SCOM Agents to be added to Group
			ForEach ($member in $SMSMembers){
				if ($member.domain = "Wegmans"){
					[String]$machinename = "{0}.wfm.wegmans.com" -f $member.name
					# Verify there is a SCOM agent
					If (invoke-command -Session $OpsMgr -ScriptBlock {get-scomAgent -Name $using:machinename}){
						$sbQuery = {Param($val)Get-SCOMClassInstance -Name "*$val*" -ErrorAction Stop} 
						$agentIDs = invoke-command -Session $OpsMgr -ScriptBlock $sbQuery -ArgumentList $member.name
						If ($agentIDs) {
							# SCOM Agent found - add to Instances array
							# $agentIDs | select ID, FullName
							ForEach ($val in $agentIDs){
								$Instances += $val.ID
							}
						} # end adding agent ID to list of instances
					} # end SCOM Agent verification
				} # End processing wegmans domain
			} # end processing SMSMembers
		} # end processing if members of collection are found
		#"{0} Instances to add" -f $instances.count
		$agents = ($instances | ConvertTo-Csv -NoTypeInformation | select -Skip 1 ) -join ","
		<#
		# Single line ScriptBlock
		$sb = "d:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToAdd $agents"
		#>
		$sb = format-scriptblock -ms $ManagementServer -packID $ManagementPackID -gid $GroupID -inst $agents
		# Execute scriptblock
		$results = invoke-command -Session $opsmgr -ScriptBlock {Param($ms, $packID,  $gid, $inst )d:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ms -ManagementPackID $packID -GroupID $gid -InstancesToAdd $inst} -ArgumentList $ManagementServer, $ManagementPackID, $GroupID, $agents
		$results
	} # end processing CCM Collection
} # end of Process
End{
	get-pssession | remove-pssession
}