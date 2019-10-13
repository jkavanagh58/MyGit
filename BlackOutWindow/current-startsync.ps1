<#
	.SYNOPSIS
		Process to update SCOM Windows for Patching Blackouts
	.DESCRIPTION
		Script reads Patching based CCM collections and takes members of collection and adds to the
		appropriate SCOM Group.
	.EXAMPLE
		c:\etc\scripts\start-BlackOutSync.ps1 -PatchWindow Monday
	.LINK https://blogs.msdn.microsoft.com/powershell/2011/06/03/invoke-expression-considered-harmful/
		Documentaion regarding the effort to remove invoke-expression
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
		06.21.2017 JJK: FIXME: Error handling and logging
		06.21.2017 JJK: Test for agents to prevent wasted invoke-expression statements
		07.13.2017 JJK: Filter for all non OM12 servers
		07.13.2017 JJK: Added if statement to hand SCOM Groups with no members to be cleared
		08.10.2017 JJK:	Add full sync, no DOW
		08.10.2017 JJK:	DONE: Run reporting script once synch completed.
		08.16.2017 JJK:	Added call to reporting script
		08.16.2017 JJK:	Added reporting for no SCOM Group error handling
		08.22.2017 JJK: Formally call reporting script based on PatchWindow
		08.23.2017 JJK:	Updated process to launch Patch Group Report.
		09.25.2017 JJK: Added process to run script to enable the MaintenanceMode tasks on MSM-03
		10.11.2017 JJK: Added load of MMTask script for scheduled task function
		10.11.2017 JJK: DONE: Add enable-MMTask function in foreach group loop
		11.15.2017 JJK: Moved log file now that script is pending approval.
		01.22.2018 JJK:	Updated JobLocation and jobDuration verbiage
		02.08.2018 JJK: Checking Management server
		04.20.2018 JJK: TODO: Formalize process lifecycle
		05.21.2018 JJK:	TODO: Create a better process for interacting with tasks on MSM-03
		05.21.2018 JJK:	FIXME: replace Invoke-Expression
		05.14.2018 JJK:	WMI Query for ccmcollections to CIM
		06.08.2018 JJK:	Convert SMSMembers to CIM
		06.16.2018 JJK: TODO: Ensure all scheduled tasks, including orchestrator get enabled
		06.16.2018 JJK: TODO: ensure process to clean group is more comprehensive, collection process is limited currently.
		06.16.2018 JJK:	FIXME: Add safegaurd to process that runs if PatchWindow is null, needs to be limited to Production Windows
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$false,
		HelpMessage = "CFGMGR Server")]
	[String]$SiteServer = 'wfm-cm12-PS-01',
	[Parameter(Mandatory=$false,
		HelpMessage = "OPSMGR Server")]
	[String]$ManagementServer = "WFM-OM12-MSM-03.wfm.wegmans.com",
	[String]$MgmtDBServer = "WFM-OM12-MSD-02",
    [String]$DataServer = "WFM-OM12-MSD-02.wfm.wegmans.com",
	[Parameter(Mandatory=$false,
		HelpMessage = "CFGMGR Site Code")]
	[String]$SiteCode = "P12",
	[Parameter(Mandatory=$false,
		HelpMessage = "Log file for script transactions")]
	[String]$LogFile = "C:\Jobs\SCOM\MaintenanceMode\Sync.txt",
	[Parameter(Mandatory=$false,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "Enter Day of Patching to be processed")]
		[ValidateSet("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")]
	[String]$PatchWindow
)
BEGIN {
	Function add-scomgroup {
		Param(
			[String]$ManagementDBServer = "WFM-OM12-MSD-02.wfm.wegmans.com",
			[String]$GroupName,
			$ManagementPackID,
			$GroupID,
			$Instances
		)
		$Instances
        "============"
		Try {
			
			Invoke-Command -ScriptBlock {c:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $DataServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToAdd $Instances}
			$logActivitySplat = @{
				entryType = "Information"
				LogMessage = "Instances Added to $($SCOMGroup)"
				LogFile = $logFile
			}
			Log-Activity @logActivitySplat
		}
		Catch {
			#"Check {0}" -f $SCOMGroup | out-file -FilePath $LogFile -Append
			#$error[0].Exception.Message | out-file -FilePath $LogFile -Append
			$logactivitySplat = @{
				logMessage = "Update/Enable Failed Check $($SCOMGroup) - Message: $($Error[0].Exception.Message)"
				entryType  = "Error"
				logFile    = $LogFile
			}
			log-activity @logactivitySplat
			<#
			"Writing Automation db Log entry for {0}" -f $SCOMDisplay
			$dbtext = "SCOM Group {0} Failed: {1}" -f $SCOMDisplay, $error[0].Exception.Message
			$writeautomationrecSplat = @{
				procAction    = $dbText
				jobType       = "SCOMPatchingBlackOut"
				app           = "Wintel"
				jobLocation   = "Script:{0} on Host:{1}" -f $MyInvocation.MyCommand.Name, $env:computername
				jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
				jobReturnCode = 1
			}
			write-automationrec @writeautomationrecSplat
			#>
		}
	}	
	Function clear-scomgroup {
		Param(
			[String]$ManagementServer = "WFM-OM12-MSD-02.wfm.wegmans.com",
			[String]$GroupName,
			$ManagementPackID,
			$GroupID
		)
		
		"Clearing current group membership for {0}." -f $GroupName
		# * Get current contents of SCOM Group
		$objs = (get-scomgroup -DisplayName $GroupName).GetRelatedMonitoringObjects()
		If ($objs){
			$agents = ($objs.ID | ConvertTo-Csv -NoTypeInformation | select-object -Skip 1 ) -join ","
			"Removing $($agents.count)"
			Try {
				Invoke-Command -ScriptBlock {C:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $DataServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToRemove $agents}
				$logActivitySplat = @{
					entryType  = "Information"
					LogMessage = "Removed $($agents.count) items from $($GroupName)"
					LogFile    = $logFile
				}
				Log-Activity @logActivitySplat
			}
			Catch {
				$logactivitySplat = @{
					logMessage = "Unable to Clear $($GroupName) Message $($Error[0].Exception.Message)"
					entryType  = "Error"
					logFile    = $LogFile
				}
				log-activity @logactivitySplat
			}
		}
		Else {
			"{0} does not currently have any members." -f $GroupName
			$logactivitySplat = @{
				logMessage = "$($GroupName) does not currently have members"
				entryType  = "Information"
				logFile    = $LogFile
			}
			log-activity @logactivitySplat
		}
	}
	# Load reference file for Scheduled Task interaction
	. c:\etc\scripts\function-MMTasks.ps1
	# Load OperationsManager SDK
	Start-OperationsManagerClientShell -ManagementServerName: $ManagementServer -PersistConnection: $true -Interactive: $true
	# Load function for writing transaction to automation db into memory
	. C:\etc\scripts\new-automationdbentry.ps1
	$cimsess = New-CimSession -ComputerName $siteserver
	# Retrieve List of Collections
	If ($PatchWindow){
		Write-Verbose -Message "[BEGIN]Querying for $($PatchWindow)"
		$collQuery = @{
			CIMSession = $cimsess
			NameSpace  = "ROOT\SMS\site_$SiteCode"
			ClassName  = "SMS_Collection"
			Filter     = "Name like 'svr-MW - Production%$PatchWindow%'"
		}
	}
	Else {
		"Gathering all CCM Groups"
		$collQuery = @{
			CIMSession = $cimsess
			NameSpace  = "ROOT\SMS\site_$SiteCode"
			ClassName  = "SMS_Collection"
			Filter     = "Name like 'svr-MW - Production -%'"
		}
	}
	$ccmcollections = Get-CIMInstance @collQuery  | sort-object -Property Name
	$logactivitySplat = @{
		logMessage = "CCMCollectons Query $($ccmcollections.count)"
		entryType = "Information"
		logFile = $LogFile
	}
	log-activity @logactivitySplat

}
PROCESS {
	ForEach ($ccmColl in $ccmcollections | sort-object -Property Name ){
		Try {
			
			$mbrqry = @{
				CIMSession = $cimsess
				Namespace  = "ROOT\SMS\site_$SiteCode"
				Query      = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($ccmColl.CollectionID)' order by name"
			}
			$SMSMembers = Get-CIMInstance @mbrqry
			$SMSMembers.Count
			$logactivitySplat = @{
				logMessage = "Starting to process $($ccmcoll.Name) with $($SMSMembers.count) SMS mmembers"
				entryType  = "Information"
				logFile    = $LogFile
			}
			log-activity @logactivitySplat
		}
		Catch {
			$logactivitySplat = @{
				logMessage = "Failed CIM Query - Message: $($Error[0].Exception.Message)"
				entryType  = "Error"
				logFile    = $LogFile
			}
			log-activity @logactivitySplat
			Exit
		}
		# Match SCOM Group DisplayName to the CCM Collection Name
		$SCOMDisplay = "WFM - Windows-" + $ccmcoll.name.trim()
		# Perform SCOM queries to generate base parameters
		$SCOMGroup = get-scomgroup -DisplayName $SCOMDisplay -ErrorAction Stop
		$SCOMMP = get-scommanagementpack -DisplayName $SCOMDisplay -ErrorAction Stop
		If ($SCOMGroup -eq $Null -or $SCOMMP -eq $Null){
			$logactivitySplat = @{
				logMessage = "Unable to find corresponding SCOM Objects matching: Group $($SCOMGroup) from MP: $($SCOMMP)"
				entryType  = 'Information'
				logFile    = $LogFile
			}
			log-activity @logactivitySplat
			Continue
		}
		<# 11.08.2018 JJK: Removing as Orchestrator groups should be included in synch process
		If ($SCOMGroup.DisplayName -like "*Orchestrator") {
			# Only action for Orchestrator is enable the task on MSM-03
			enable-mmtask -groupName $SCOMDisplay
			$logactivitySplat = @{
				logMessage   = "Enabled Scheduled Task for $($SCOMDisplay)"
				entryType = "Information"
				logFile   = $logFile
			}
			log-activity @logactivitySplat
			Continue
		}
		#>
		# Create base parameters for remote execution of modifygroupmembership.ps1
		$ManagementPackID = $SCOMMP.Name
		$GroupID = $SCOMGroup.FullName
		Write-Verbose -Message "[PROCESS]Names"
		Write-Verbose -Message "[PROCESS]`t$SCOMDisplay"
		Write-Verbose -Message "[PROCESS]`t$SCCOMGroup"
		Write-Verbose -Message "[PROCESS]`t$SCOMMP"
		# * Clear SCOM Group members
		clear-scomgroup -ManagementServer $ManagementServer -GroupID $SCOMGroup.FullName -GroupName $SCOMDisplay -ManagementPackID $ManagementPackID
		if ($SMSMembers){
			# Formulate a SCOM searchable name
			# For Each SMSMember find SCOM Agent if possible
			# Start timer for recording elapsed time to automation db
			$procStart = [System.Diagnostics.StopWatch]::StartNew()
			$Instances = New-Object System.Collections.ArrayList # Array used to collect SCOM Agents to be added to Group
			"Creating a list of SCOM Agents to be added to group."
			ForEach ($member in $SMSMembers | Where {$_.Name -notlike "*-OM12-*"}){
				if ($member.domain = "Wegmans"){
					[String]$machinename = "{0}.wfm.wegmans.com" -f $member.name
					# Verify there is a SCOM agent
					If (get-scomAgent -Name $machinename){
						# Find all monitored objects matching computer name
						$agentIDs = Get-SCOMClassInstance -Name "*$($member.name)*" -ErrorAction Stop
						If ($agentIDs) {
							# $agentIDs | select ID, FullName
							ForEach ($val in $agentIDs){
								$Instances.Add($val.ID) > $Null
							}
						} # end adding agent ID to list of instances
					} # end SCOM Agent verification
				} # End processing wegmans domain
			} # end processing SMSMembers
		} # end processing if members of collection are found
		# Process all monitoring obects
		log-activity -logmessage "Collected Instances $($Instances.count)" -LogFile $logFile -entryType "Information"
		If ($Instances.Count -ge 1){
				$agents = ($instances | ConvertTo-Csv -NoTypeInformation | select-object -Skip 1 ) -join ","
				# Execute scriptblock for adding instances to SCOM Group
				<#
				add-scomgroup -GroupName $SCOMDisplay -ManagementPackID $ManagementPackID -GroupID $SCOMGroup.FullName -Instances $Instances
				$logActivitySplat = @{
					entryType  = "Information"
					LogMessage = "Added $($agents.count) to $($SCOMDisplay)"
					LogFile    = $logFile
				}
                $agents = ($instances | ConvertTo-Csv -NoTypeInformation | select -Skip 1 ) -join ","
				#>
                $sb = "c:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $DataServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToAdd $agents"
				# Execute scriptblock to add members to SCOM group
				invoke-expression $sb
				#Log-Activity @logActivitySplat
				# Enable the scheduled task that creates the maintenance window for this group
				Write-Verbose -Message "[PROCESS]Enabling the Scheduled Task for $($SCOMDisplay)"
				"Enabling {0} Task" -f $SCOMDisply
				enable-mmtask -groupName $SCOMDisplay
				# Write record to automation database
				"Writing Automation db Log entry for {0}" -f $SCOMDisplay
				$dbtext = "SCOM Group {0} Updated, Scheduled Task enabled" -f $SCOMDisplay
				$writeautomationrecSplat = @{
					procAction    = $dbText
					jobType       = "SCOMPatchingBlackOut"
					app           = "Wintel"
					jobLocation   = "Script:{0} on Host:{1}" -f $MyInvocation.MyCommand.Name, $env:computername
					jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
					jobReturnCode = 0
				}
				write-automationrec @writeautomationrecSplat
				# TODO: Remove instances and smsmembers
		}
		Else {
			"`tNo instances to process"
			$logactivitySplat = @{
				logMessage = "Check $($SCOMGroup) - Message: No instances to process"
				entryType  = "Information"
				logFile    = $LogFile
			}
			log-activity @logactivitySplat
		}
	} # end processing CCM Collection
	# Run the report 
	Invoke-Command -ScriptBlock {c:\etc\scripts\get-SCOMBOgroupinfo.ps1 -rptName $PatchWindow}
} # end of Process
END {
	Remove-Variable -Name PatchWindow, SiteCode, SiteServer
	Get-CimSession | Remove-CimSession
	[System.GC]::Collect()
}
