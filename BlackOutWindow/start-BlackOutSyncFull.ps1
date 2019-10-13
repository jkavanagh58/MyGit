<#
.SYNOPSIS
	Process to update SCOM Windows for Patching Blackouts
.DESCRIPTION
	Script reads Patching based CCM collections and takes members of collection and adds to the
	appropriate SCOM Group.
.EXAMPLE
	c:\etc\scripts\start-BlackOutSync.ps1 -PatchWindow Monday
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		06.15.2017
	Created by:		John Kavanagh
	Organization:	TekSystems
	Filename:		start-BlackOutSync.ps1
	===========================================================================
	06.15.2017 JJK: Determine if multiple domains need to be accounted for, if so change if to switch
	06.15.2017 JJK: Fixed issue with acquiring ManagementPack and Group information due to faulty SCOMDisplay
	06.15.2017 JJK:	Error handling for issues where no corresponding SCOM object is found
	06.16.2017 JJK: Testing Friday run
	06.21.2017 JJK: SDK limitation prevents from running via PSRemoting - writing to run on wfm-wintel-02
	06.21.2017 JJK: Convert ccmcollections to use Splat format
	06.21.2017 JJK: Add parameter to allow calling of script referencing DOW
	06.21.2017 JJK: DONE: Error handling and logging
	06.21.2017 JJK: Test for agents to prevent wasted invoke-expression statements
	07.13.2017 JJK: Filter for all non OM12 servers
	07.13.2017 JJK: Added if statement to hand SCOM Groups with no members to be cleared
	08.10.2017 JJK:	Add full sync, no DOW
	08.10.2017 JJK:	DONE: Run reporting script once sync completed.
	08.16.2017 JJK:	Added call to reporting script
	08.16.2017 JJK:	Added reporting for no SCOM Group error handling
	08.18.2017 JJK: Modified no match for Group or MP.
	08.21.2017 JJK: DONE: Change report process to account for running with PatchWindow specified
	08.23.2017 JJK: Changed invoke-expression statement
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
Param(
	$SiteServer = 'wfm-cm12-PS-01',
	$ManagementServer = "WFM-OM12-MSD-02.wfm.wegmans.com",
	$SiteCode = "P12",
	[String]$LogFile = "c:\etc\logs\Sync.txt",
	[Parameter(Mandatory=$false,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        HelpMessage = "Enter Day of Patching to be processed")]
        [ValidateSet("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")]
    [String]$PatchWindow

)
Begin {
	Function clear-scomgroup {
		Param(
			[String]$ManagementServer = "WFM-OM12-MSD-02.wfm.wegmans.com",
			[String]$GroupName,
			$ManagementPackID,
			$GroupID
		)
		"Clearing current group membership for {0}." -f $GroupName
		# Get current contents of SCOM Group
		$objs = (get-scomgroup -DisplayName $GroupName).GetRelatedMonitoringObjects()
		If ($objs){
			$agents = ($objs.ID | ConvertTo-Csv -NoTypeInformation | select -Skip 1 ) -join ","
			<#
				07.07.2017 JJK: Splatting does not work with modifygroupmembership.ps1
				Since not running via WinRM work on splatted version for ease of reading
			#>
			$sb = "C:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToRemove $agents"
			invoke-expression $sb
		}
		Else {
			"{0} does not currently have any members." -f $GroupName
		}
	}
	# Load OperationsManager SDK
	Start-OperationsManagerClientShell -ManagementServerName: "wfm-om12-msm-01.wfm.wegmans.com" -PersistConnection: $true -Interactive: $true
	# Retrieve List of Collections
	If ($PatchWindow){
		"Querying for {0}" -f $PatchWindow
		$collQuery = @{
			Computername = $siteServer
			NameSpace    = "ROOT\SMS\site_$SiteCode"
			Class        = "SMS_Collection"
			Filter       = "Name like 'svr-MW - Production%$PatchWindow%'"
		}
	}
	Else {
		"Gathering all CCM Groups"
		$collQuery = @{
			Computername = $siteServer
			NameSpace    = "ROOT\SMS\site_$SiteCode"
			Class        = "SMS_Collection"
			Filter       = "Name like 'svr-MW - Production -%'"
		}
	}
	$ccmcollections = get-wmiobject @collQuery  | sort Name
}
Process {
	ForEach ($ccmColl in $ccmcollections){
		"Processing {0} ID: {1}" -f $ccmColl.Name, $ccmColl.CollectionID
		"=" * 62
		# Retrieve members of collection
		$mbrqry = @{
				ComputerName = $SiteServer
				Namespace    = "ROOT\SMS\site_$SiteCode"
				Query        = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($ccmColl.CollectionID)' order by name"
		}
		$SMSMembers = Get-WmiObject @mbrqry
		# "Found {0} members of {1} Collection" -f $SMSMembers.count, $ccmcoll.name
		$SCOMDisplay = "WFM - Windows-" + $ccmcoll.name.trim()
		# Perform SCOM queries to generate base parameters
		$SCOMGroup = get-scomgroup -DisplayName $SCOMDisplay -ErrorAction Stop
		$SCOMMP = get-scommanagementpack -DisplayName $SCOMDisplay -ErrorAction Stop
		If ($SCOMGroup -eq $Null -or $SCOMMP -eq $Null){
			"{0}:Unable to find corresponding SCOM Objects matching Group: {1} from MP: {2}" -f (get-date -Format MMddyyyhhmmss), $SCOMDisplay, $ccmcollname |
			out-file -FilePath $LogFile -Append
			Continue
		}
		# Create base parameters for remote execution of modifygroupmembership.ps1
		$ManagementPackID = $SCOMMP.Name
		$GroupID = $SCOMGroup.FullName
		# Clear SCOM Group members
		clear-scomgroup -GroupName $SCOMDisplay -ManagementPackID $ManagementPackID -GroupID $GroupID
		if ($SMSMembers){
			# Formulate a SCOM searchable name
			# For Each SMSMember find SCOM Agent if possible
			$Instances = @() # Array used to collect SCOM Agents to be added to Group
			"Creating a list of SCOM Agents to be added to group."
			ForEach ($member in $SMSMembers | Where {$_.Name -notlike "*-OM12-*"}){
				if ($member.domain = "Wegmans"){
					[String]$machinename = "{0}.wfm.wegmans.com" -f $member.name
					# Verify there is a SCOM agent
					If (get-scomAgent -Name $machinename){
						$agentIDs = Get-SCOMClassInstance -Name "*$($member.name)*" -ErrorAction Stop
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
		If ($Instances.Count -ge 1){
			try {
				$agents = ($instances | ConvertTo-Csv -NoTypeInformation | select -Skip 1 ) -join ","
				$sb = "c:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToAdd $agents"
				# Execute scriptblock
				invoke-expression $sb
			}
			catch  {
				# Handle the failure
				"Unable to process {0} ID: {1}" -f $ccmColl.Name, $ccmColl.CollectionID
				"{0}:{1}:{2}" -f (get-date -Format MMddyyyhhmmss),$ccmColl.Name, $error[0].Message | out-file -FilePath $LogFile -Append
			}

		}
	} # end processing CCM Collection
	# Run the report
	$callreport = "c:\etc\scripts\get-SCOMBOgroupinfo.ps1 -rptName {0}" -f $PatchWindow
    Invoke-Expression -Command $callreport
} # end of Process
End{
	Remove-variable -Name ManagementServer, ccmcoll, sb, ManagementPackID, GroupID, SMSMembers, agents, Instances, mbrqry, collquery -ErrorAction SilentlyContinue
	[System.GC]::Collect()
}