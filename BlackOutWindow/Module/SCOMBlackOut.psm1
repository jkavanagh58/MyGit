# Implement your module commands in this script.
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
		Write-LogEntry @logActivitySplat
	}
	Catch {
		#"Check {0}" -f $SCOMGroup | out-file -FilePath $LogFile -Append
		#$error[0].Exception.Message | out-file -FilePath $LogFile -Append
		$logactivitySplat = @{
			logMessage = "Update/Enable Failed Check $($SCOMGroup) - Message: $($Error[0].Exception.Message)"
			entryType  = "Error"
			logFile    = $LogFile
		}
		Write-LogEntry @logactivitySplat
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
			Write-LogEntry @logActivitySplat
		}
		Catch {
			$logactivitySplat = @{
				logMessage = "Unable to Clear $($GroupName) Message $($Error[0].Exception.Message)"
				entryType  = "Error"
				logFile    = $LogFile
			}
			Write-LogEntry @logactivitySplat
		}
	}
	Else {
		"{0} does not currently have any members." -f $GroupName
		$logactivitySplat = @{
			logMessage = "$($GroupName) does not currently have members"
			entryType  = "Information"
			logFile    = $LogFile
		}
		Write-LogEntry @logactivitySplat
	}
}
Function log-activity {
	[CmdletBinding()]
	Param (
		[parameter(Mandatory=$False, ValueFromPipeline=$True,
				HelpMessage = "Date of Log Entry")]
		[DateTime]$logDateFormat = (get-date -format g),
		[parameter(Mandatory=$False, ValueFromPipeline=$True,
				HelpMessage = "Name of logfile")]
		[System.String]$logFile,
		[parameter(Mandatory=$True, ValueFromPipeline=$True,
				HelpMessage = "Classify Entry")]
		[ValidateSet("Information","Error","Success")]
		[System.String]$entryType,
		[parameter(Mandatory=$True, ValueFromPipeline=$True,
				HelpMessage = "Log Message")]
		[System.String]$logMessage
	)
	BEGIN {
		Write-Verbose -Message "[BEGIN]If file does not exist create."
		if (!(Test-Path $logFile)) {
			New-Item $logFile -ItemType File -Force
		}
	}
	PROCESS {
		Write-Verbose -Message "[PROCESS]Writing message to $($logFile)"
		"{0}: {1} - {2}" -f $logDateFormat, $entryType, $logMessage | out-file -FilePath $logFile -Append
	}
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
