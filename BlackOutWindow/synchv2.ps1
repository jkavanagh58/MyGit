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
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$false,
		HelpMessage = "CFGMGR Server")]
	[String]$SiteServer = 'wfm-cm12-PS-01',
	[Parameter(Mandatory=$false,
		HelpMessage = "OPSMGR Server")]
	[String]$ManagementServer = "WFM-OM12-MSM-03.wfm.wegmans.com",
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
			[String]$ManagementServer = "WFM-OM12-MSM-03.wfm.wegmans.com",
			[String]$GroupName,
			$ManagementPackID,
			$GrpID,
			$Instances
		)
		"================="
			$ManagementPackID
			$GroupID
			$GrpID
		"================="
		Try {
			# add-scomgroup -GroupName $SCOMDisplay.DisplayName -ManagementPackID $ManagementPackID -GroupID $SCOMGroup.FullName -Instances $agents
			Invoke-Command -ScriptBlock {c:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GrpID -InstancesToAdd $Instances}
			$logActivitySplat = @{
				entryType = "Information"
				LogMessage = "$($instances.count) Added to $($GroupName)"
				LogFile = $logFile
			}
			Log-Activity @logActivitySplat
		}
		Catch [System.Management.Automation.RuntimeException] {
			$logactivitySplat = @{
				logMessage = "Update/Enable Failed Check $($SCOMGroup) - Error: $($Error[0].Exception.Message)"
				entryType  = "Error"
				logFile    = $LogFile
			}
			log-activity @logactivitySplat
		}
		Catch {
			$logactivitySplat = @{
				$errMsg = $error[0].Exception.Message.Substring(0,120)
				logMessage = "Update/Enable Failed Check $($SCOMGroup) - Error: $errMsg"
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
			[String]$ManagementServer = "WFM-OM12-MSM-03.wfm.wegmans.com",
			[String]$GroupID,
			$ManagementPackID,
			$GroupName
		)
		$ManagementPackID
		"Clearing current group membership for {0}" -f $GroupName
		# * Get current contents of SCOM Group
		$objs = (get-scomgroup -DisplayName $GroupName).GetRelatedMonitoringObjects()
		If ($objs){
			$agents = ($objs.ID | ConvertTo-Csv -NoTypeInformation | select-object -Skip 1 ) -join ","
			
			Try {
				Invoke-Command -ScriptBlock {C:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToRemove $agents}
				$logActivitySplat = @{
					entryType  = "Information"
					LogMessage = "Removed $($agents.count) items from $($GroupName)"
					LogFile    = $logFile
				}
				Log-Activity @logActivitySplat
			}
			Catch {
				$logactivitySplat = @{
					logMessage = "Unable to Clear $($GroupName) Error $error[0].Exception.Message"
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
	ForEach ($ccmColl in $ccmcollections){
		Try {
			
			$mbrqry = @{
				CIMSession = $cimsess
				Namespace  = "ROOT\SMS\site_$SiteCode"
				Query      = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($ccmColl.CollectionID)' order by name"
			}
			$SMSMembers = Get-CIMInstance @mbrqry
			$logactivitySplat = @{
				logMessage = "Starting to process $($ccmcoll.Name) with $($SMSMembers.count) mmembers"
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
		$SCOMGroup = Get-Scomgroup -DisplayName $SCOMDisplay -ErrorAction Stop
		$SCOMMP = Get-Scommanagementpack -DisplayName $SCOMDisplay -ErrorAction Stop
		If ($SCOMGroup -eq $Null -or $SCOMMP -eq $Null){
			$logactivitySplat = @{
				logMessage = "Unable to find corresponding SCOM Objects matching: Group $($SCOMGroup) from MP: $($SCOMMP)"
				entryType  = 'Information'
				logFile    = $LogFile
			}
			log-activity @logactivitySplat
			Continue
		}
		If ($SCOMGroup.DisplayName -like "*Orchestrator") {
			# Only action for Orchestrator is enable the task on MSM-03
			enable-mmtask -groupName $SCOMDisplay
			$logactivitySplat = @{
				Message   = "Enabled Scheduled Task for $($SCOMDisplay)"
				entryType = "Information"
				logFile   = $logFile
			}
			log-activity @logactivitySplat
			Continue
		}
		# Create base parameters for remote execution of modifygroupmembership.ps1
		$ManagementPackID = $SCOMMP.Name
		$GroupID = $SCOMGroup.FullName
		Write-Verbose -Message "[PROCESS]Names"
		Write-Verbose -Message "[PROCESS]`t$SCOMDisplay"
		Write-Verbose -Message "[PROCESS]`t$SCCOMGroup"
		Write-Verbose -Message "[PROCESS]`t$SCOMMP"
		# * Clear SCOM Group members
		clear-scomgroup -ManagementServer $ManagementServer -GroupID $GroupID -ManagementPackID $ManagementPackID -GroupName $SCOMDisplay
		# Create list of objects to add the SCOM Group
		if ($SMSMembers){
			#"Processing $($SMSMembers)"
			# For Each SMSMember find SCOM Agent if possible
			# Start timer for recording elapsed time to automation db
			$procStart = [System.Diagnostics.StopWatch]::StartNew()
			"Creating a list of SCOM Agents to be added to group."
			$SMSInstances = @()
			ForEach ($member in $SMSMembers | Where {$_.Name -notlike "*-OM12-*"}){
				# Formulate a SCOM searchable name
				if ($member.domain = "Wegmans"){
					[String]$machinename = "{0}.wfm.wegmans.com" -f $member.name
					# Verify there is a SCOM agent
					If (get-scomAgent | Where-Object {$_.DisplayName -eq $machinename}){
						"Searching $($machinename)"
						# Get-scomclassinstance -DisplayName  "*RDC-WPAY-WEB-01.wfm.wegmans.com*" | select DisplayName, Id
						$agentIDs = Get-SCOMClassInstance -DisplayName "*$($machinename)*" -ErrorAction Stop | Select-Object -Property Id
						If ($agentIDs) {
							# $agentIDs | select ID, FullName
							ForEach ($val in $agentIDs) {
								# $Instances.Add($val.ID) > $Null
								$SMSInstances += $val.ID
							}
						}
						Else {
							"No ID found for $($member.name)"
						}
					} # end SCOM Agent verification
				} # End processing wegmans domain
			} # end processing SMSMembers
		} # end processing if members of collection are found
		# Process all monitoring obects
		log-activity -logmessage "Collected Instances $($SMSInstances.count)" -LogFile $logFile -entryType "Information"
		If ($SMSInstances.Count -ge 1){
				$addInstances = ($SMSinstances | ConvertTo-Csv -NoTypeInformation | select-object -Skip 1 ) -join ","
				Try {
					Invoke-Command -ScriptBlock {c:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToAdd $addInstances}
					$logactivitySplat = @{
						logMessage = "Update/Enable Successfull"
						entryType  = "Information"
						logFile    = $LogFile
					}
					log-activity @logactivitySplat
				}
				Catch [System.Management.Automation.RuntimeException] {
					$logactivitySplat = @{
						logMessage = "Update/Enable Failed - Error: $Error[0].Exception.Message.ToString(0,120) - $addInstances.count"
						entryType  = "Error"
						logFile    = $LogFile
					}
					log-activity @logactivitySplat
				}
				Catch {
					log-activity -LogMessage "Update failed Error:$error[0].Exception.Message.Substring(0,120)" -LogFile $logfile -EntryType "Error"
				}
				#add-scomgroup -GroupName $SCOMDisplay.DisplayName -ManagementPackID $ManagementPackID -GroupID $SCOMGroup.FullName -Instances $agents
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
	Remove-Variable -Name PatchWindow, SiteCode, SiteServer, Instances, SMSInstances
	Get-CimSession | Remove-CimSession
	[System.GC]::Collect()
}
