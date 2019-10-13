<#
.SYNOPSIS
Process to update SCOM Windows for Patching Blackouts
.DESCRIPTION
Script reads Patching based CCM collections and takes members of collection and adds to the
appropriate SCOM Group.
.PARAMETER SiteServer
Used to target CfgMgr operations
.PARAMETER ManagementServer
Used to target OpsMgr operations
.PARAMETER SiteCode
Specifies the CfgMgr SiteCode
.Parameter logile
Points logging transactions to the designated file
.PARAMETER PatchWindow
Used to filter transactions to a specific DOW
.EXAMPLE
c:\etc\scripts\start-BlackOutSync.ps1 -PatchWindow Monday
.LINK https://blogs.msdn.microsoft.com/powershell/2011/06/03/invoke-expression-considered-harmful/
Documentaion regarding the effort to remove invoke-expression
.LINK https://blogs.msdn.microsoft.com/rslaten/2013/06/27/modifying-explicit-group-membership-in-scom-2012-with-powershell/
Documentation for script used to perform SCOM group actions
.NOTES
===========================================================================
Created with:	Visual Studio Code
Created on:		06.15.2017
Created by:		John Kavanagh
Organization:	TekSystems
Filename:		start-BlackOutSync.ps1
===========================================================================
11.10.2018 JJK:	Version 1.1 starts here
11.10.2018 JJK: TODO: Consider performing the clear and add functions inline
11.11.2018 JJK:	Sadly the version of PowerShell is not current enough for Write-Information
11.13.2018 JJK:	TODO: Handle output of modifygroupmembership for 'Script Complete' to implement better error handling
11.13.2018 JJK:	Commenting out process for scheduled tasks per conversation
11.21.2018 JJK: DONE:Instances array for clear function was not defined, causing errorwriting issues
11.21.2018 JJK:	DONE:Catch statement for add is kicking in as a false positive - invalid character in excel tablename
#>
[CmdletBinding(ConfirmImpact='Low')]
Param(
[Parameter(Mandatory=$false,
HelpMessage = "CFGMGR Server")]
[System.String]$SiteServer = 'wfm-cm12-PS-01',
[Parameter(Mandatory=$false,
HelpMessage = "CFGMGR Site Code")]
[System.String]$SiteCode = "P12",
[Parameter(Mandatory=$false,
HelpMessage = "OPSMGR Server")]
[System.String]$ManagementServer = "WFM-OM12-MSM-03.wfm.wegmans.com",
[Parameter(Mandatory=$false,
HelpMessage = "Log file for script transactions")]
[System.String]$LogFile = "C:\Jobs\SCOM\MaintenanceMode\Sync.txt",
[Parameter(Mandatory=$false,
ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true,
HelpMessage = "Enter Day of Patching to be processed")]
[ValidateSet("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")]
[System.String]$PatchWindow,
[parameter(Mandatory=$False, ValueFromPipeline=$False,
		HelpMessage = "Path to Synch Reports")]
[System.String]$xlsxFilePath = "\\wfm.wegmans.com\Departments\InformationTechnology\TechWintel\.Scripts\SCOM\MaintenanceMode",
[parameter(Mandatory=$False, ValueFromPipeline=$False,
		HelpMessage = "String Used for Excel WorkSheet Name reformatting and remove #.")]
[System.String]$numRegEx = '^\d.'
)
BEGIN {
	Function clear-scomgroup {
		<#
		.SYNOPSIS
		Clears all current members of the OpsMgr group
		.DESCRIPTION
		Function is called when the operations for the OpsMgr group starts. Members are cleared
		from OpsMgr group. This provides a clean slate before group membership is updated.
		.NOTES
		07.07.2017 JJK: Splatting does not work with modifygroupmembership.ps1
		Since not running via WinRM work on splatted version for ease of reading
		11.10.2018 JJK:	DONE: Create formal scriptblock
		11.10.2018 JJK: DONE: Need to add activity logging
		11.21.2018 JJK: DONE: Source of pain... had mistakenly referenced obj and not val
		#>
		Param(
			[parameter(Mandatory=$True, ValueFromPipeline=$True,
				HelpMessage = "Management Server")]
			[System.String]$ManagementServer = "WFM-OM12-MSM=03.wfm.wegmans.com",
			[parameter(Mandatory=$True, ValueFromPipeline=$True,
				HelpMessage = "Name of OpsMgr Group")]
			[System.String]$GroupName,
			[parameter(Mandatory=$True, ValueFromPipeline=$True,
				HelpMessage = "ManagementPack ID for the OpsMgr Group associated Management Pack")]
			[System.String]$ManagementPackID,
			[parameter(Mandatory=$True, ValueFromPipeline=$True,
				HelpMessage = "ID not name is used for OpsMgr operations")]
			[System.String]$GroupID
		)
		#Write-Verbose -Message "[Function]Clearing current group membership"
		# * Get current contents of SCOM Group
		"-----------------"
		$GroupName
		$objs = (get-scomgroup -DisplayName $GroupName).GetRelatedMonitoringObjects()
		$objs.count
		If ($objs.count -ge 1){
			If (get-variable -Name Instances -ErrorAction SilentlyContinue) {
				Remove-Variable -Name Instances -ErrorAction SilentlyContinue
			}
			$Instances = @()
			Try {
				#$objs = (get-scomgroup -DisplayName $GroupName).GetRelatedMonitoringObjects()
				ForEach ($val in $objs){
					# Source of pain... had mistakenly referenced obj and not val
					$toremove = $val.ID
					$instances += $toremove.ToString()
				}
				C:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $SCOMMP.Name -GroupID $GroupID -InstancesToRemove $Instances
				Write-Verbose -Message "[FUNCTION]$($objs.count) Members cleared from $($GroupName)"
				$logActivitySplat = @{
					entryType = "Success"
					LogMessage = "`t$($objs.Count) cleared from $($GroupName)"
					LogFile = $logFile
				}
				Log-Activity @logActivitySplat
			}
			Catch {
				Write-Error -Message "[FUNCTION]Unable to clear members from $($GroupName)" -ErrorAction Continue
				$logActivitySplat = @{
					entryType = "Error"
					LogMessage = "`t$Unable to clear existing objects from $($GroupName)"
					LogFile = $logFile
				}
				Log-Activity @logActivitySplat
			}
		}
		Else {
			Write-Verbose -Message "[Function]No current members in this OsMgr group"
			"$($GroupName) does not currently have any members."
			$logActivitySplat = @{
				entryType = "Information"
				LogMessage = "$($GroupName) does not currently have any members."
				LogFile = $logFile
			}
			Log-Activity @logActivitySplat
		}
	}
	# Load reference file for Scheduled Task interaction
	. c:\etc\scripts\function-MMTasks.ps1
	# Load function for writing transaction to automation db into memory
	. C:\etc\scripts\new-automationdbentry.ps1
	$cfgmgrCIM = New-CimSession -Name "CfgMgrCIM" -ComputerName $siteserver
	$logActivitySplat = @{
		entryType = "Information"
		LogMessage = "SCOM BlackOut Sync Process started"
		LogFile = $logFile
	}
	Log-Activity @logActivitySplat
	# Load OperationsManager SDK
	Start-OperationsManagerClientShell -ManagementServerName: $ManagementServer -PersistConnection: $true -Interactive: $true
}
PROCESS {
	# Retrieve List of Collections based on pipeline
	If ($PatchWindow){
		$logActivitySplat = @{
			entryType = "Information"
			LogMessage = "SCOM BlackOut Sync Process for $($PatchWindow)"
			LogFile = $logFile
		}
		Log-Activity @logActivitySplat
		"Querying for $($PatchWindow)"
		$collQuery = @{
			CimSession = $cfgmgrCIM
			NameSpace  = "ROOT\SMS\site_$SiteCode"
			ClassName  = "SMS_Collection"
			Filter     = "Name like 'svr-MW - Production%$PatchWindow%'"
		}
	}
	Else {
		"Gathering all CCM Groups"
		$collQuery = @{
			CimSession = $cfgmgtCIM
			NameSpace  = "ROOT\SMS\site_$SiteCode"
			ClassName  = "SMS_Collection"
			Filter     = "Name like 'svr-MW - Production -%'"
		}
	}
	Try {
		$ccmcollections = Get-CIMInstance @collQuery | sort-object -Property Name
		$xlsxFileName = "synccfgmgr.xlsx"
		$xlsxWkSheetName = "{0} run {1}" -f $PatchWindow, (get-date -f MMddyyyy)
		$tblName = "tbl{0}" -f (get-date -f MMddyyyyhhmmss)
        $exportExcelSplat = @{
            AutoSize      = $true
            WorksheetName = $xlsxWkSheetName
            TableName     = $tblName
            TableStyle    = 'Medium15'
            MoveToStart   = $true
            FreezeTopRow  = $true
            Path          = (Join-Path $xlsxFilePath -ChildPath $xlsxFileName)
        }
		$ccmCollections | Select-Object Name, CollectionID | 
			Export-Excel @exportExcelSplat
	}
	Catch {
		$Error[0].Exception.Message
		Write-Error -Message "Unable to query for Collection objects" -ErrorAction SilentlyContinue
	}
	# Consider an If statement
	ForEach ($ccmColl in $ccmcollections){
		# Match SCOM Group DisplayName to the CCM Collection Name
		$SCOMDisplay = "WFM - Windows-" + $ccmcoll.name.trim()
		$logActivitySplat = @{
			entryType = "Information"
			LogMessage = "Currently evaluating $($SCOMDisplay)"
			LogFile = $logFile
		}
		Log-Activity @logActivitySplat
		# Perform SCOM queries to generate base parameters
		$SCOMGroup = get-scomgroup -DisplayName $SCOMDisplay -ErrorAction Stop
		$SCOMMP = get-scommanagementpack -DisplayName $SCOMDisplay -ErrorAction Stop
		# Create base parameters for remote execution of modifygroupmembership.ps1
		$ManagementPackID = $SCOMMP.Name
		$GroupID = $SCOMGroup.FullName
		Write-Verbose -Message "[PROCESS]Processing $($ccmColl.Name) ID: $($ccmColl.CollectionID)"
		clear-scomgroup -ManagementServer $ManagementServer -GroupName $SCOMDisplay -ManagementPackID $ManagementPackID -GroupID $GroupID
		# Retrieve members of collection - pass parameter to Get-WMIObject
		$mbrqry = @{
			CimSession   = $cfgmgrCIM
			Namespace    = "ROOT\SMS\site_$SiteCode"
			Query        = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($ccmColl.CollectionID)' order by name"
		}
		# Look at using SCOM Class Instance to get all related objects in one pass
		If ($SMSMembers = Get-CIMInstance @mbrqry) {
			# For Each SMSMember find SCOM Agent
			$Instances = @() # Array used to collect SCOM Agents to be added to $SCOMDisplay Group
			Write-Verbose -Message "Creating a list of SCOM Agents to be added to group."
			ForEach ($member in $SMSMembers | Where {$_.Name -notlike "*-OM12-*"}){
				# Start timer for recording elapsed time to automation db
				$procStart = [System.Diagnostics.StopWatch]::StartNew()
				If ($scomagt = get-scomagent -DNSHostName ($member.Name + ".wfm.wegmans.com")){
					# OpsMgr object verified, gather all objects
					ForEach ($obj in get-scomclassinstance -DisplayName $scomagt.NetworkName){
						$toadd = $obj.ID
						$instances += $toadd.ToString()
					}
				}
			}
			#$agents = ($instances | ConvertTo-Csv -NoTypeInformation) -join ","
			Try {
				Write-Verbose -Message "[PROCESS]Adding $($Instances.count) members to $SCOMDisplay"
				c:\etc\scripts\modifygroupmembership.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GroupID -InstancesToAdd $instances
				$logActivitySplat = @{
					entryType = "Success"
					LogMessage = "`t$($Instances.Count) Added to $SCOMDisplay"
					LogFile = $logFile
				}
				Log-Activity @logActivitySplat
				$xlsxFileName = "SyncGroupsReport.xlsx"
				$grpShortName = $SCOMDisplay.Replace("WFM - Windows-Svr-MW - Production - ","").Replace(":","").Replace(" ","") -Replace ($numRegex,"")
				$xlsxWkSheetName = "{0}-{1}" -f (Get-Date -f MMddyyyy), $grpShortName
				$tblName = "tbl{0}{1}" -f (Get-Date -f MMddyyyy), $grpShortName
				# Need to remove hyphen seperating start and end times
				$tblName = $tblName.Replace("-","")
                $exportExcelSplat = @{
                    AutoSize      = $true
                    WorksheetName = $xlsxWkSheetName
                    TableStyle    = 'Medium12'
                    FreezeTopRow  = $true
                    Path          = (Join-Path $xlsxFilePath -ChildPath $xlsxFileName )
                }
				Get-SCOMGroup -DisplayName $SCOMDisplay | Get-SCOMClassInstance | Select-Object -Property DisplayName, fullname | Sort-Object -Property DisplayName |
				Export-Excel @exportExcelSplat -ErrorAction SilentlyContinue
			}
			Catch {
				write-error -Message "Unable to update $SCOMDisplay"
				$error[0].Exception.Message
				$logActivitySplat = @{
					entryType = "Error"
					LogMessage = "`t$($Instances.Count) count not be added to $($GroupName)"
					LogFile = $logFile
				}
				Log-Activity @logActivitySplat
			}
		}
		Else {
			Write-Verbose "There are no changes to be made for $($SCOMDisplay)"
			$logActivitySplat = @{
				entryType = "Information"
				LogMessage = "No members to be added to $($SCOMDisplay)"
				LogFile = $logFile
			}
			Log-Activity @logActivitySplat
			Continue
		}
	}
	$logActivitySplat = @{
		entryType = "Information"
		LogMessage = "SCOM BlackOut $PatchWindow Sync Process end"
		LogFile = $logFile
	}
	Log-Activity @logActivitySplat
}
END {
	Get-CimSession | Remove-CIMSession
	Remove-Variable -Name siteCode, SiteServer, ccmcollections, mbrqry, PatchWindow, LogFile, ManagementServer -ErrorAction SilentlyContinue
	Remove-Variable -Name SCOMDisplay, SCOMGroup, SCOMMP, procStart -ErrorAction SilentlyContinue
	[System.GC]::Collect()
}