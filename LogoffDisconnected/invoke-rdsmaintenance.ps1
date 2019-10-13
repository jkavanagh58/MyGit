<#
	.SYNOPSIS
		Clear all idle RDS Sessions

    .DESCRIPTION
		Reads current RDS sessions and evaluatues idles sessions. If session idle for more than a
		certain period of time the session will be gracefully terminated. Written to run as scheduled task
		so no paramters or examples need to be noted.

	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.134
	 Created on:   	1/26/2017 10:50 AM
	 Created by:   	John Kavanagh
	 Organization: 	Sparks IT Group
	 Filename:     	invoke-rdsmaintenance.ps1
	===========================================================================
	01.26.2017 JJK: Seperated into host based script due to  no connection broker.
	01.26.2017 JJK: Upgraded to Advanced function
#>
Function logoff-idlesessions {
	[CmdLetBinding()]
	Param([string]$rptFile)
	BEGIN {
		$rptFile = "\\clvprdinfs001\IT_FileSRV\reports\RDOptimize\CMSMFA.txt"
		# Only get the disconnected sessions from both hosts
		$hosts = "cleintrdsapp001.cgicleve.com", "cleintrdsapp002.cgicleve.com"
		# Array for collection disconnected sessions
		$wkgset = @()
		foreach ($h in $hosts) {
			$wkgSet += Get-RDUserSession -CollectionName CMS -ConnectionBroker $h | where{ $_.DisconnectTime }
		} # End collection
		$i = 0
	}
	PROCESS
	{
		ForEach ($obj in $wkgset) {
			$truetime = (get-date) - (get-date($obj.DisconnectTime))
			if ($truetime.TotalMinutes -gt 60) {
				$i++ # incremental counter
				# "Logging {0} off due to extended idle time" -f $obj.UserName
				Try {
					Invoke-RDUserLogoff -UnifiedSessionID $obj.UnifiedSessionId -HostServer $obj.HostServer -Force
					"Logged {0} off due to extended idle time of {1} minutes" -f $obj.UserName, $truetime.TotalMinutes | out-file $rptFile -Append
				} # Log off the session
				Catch {
					"Unable to Log {0} off" -f $obj.UserName | out-file $rptfile -Append
				} # Unable to log the session off
			}
		}
	}
	END
	{
		"Evaluated {0} sessions on {1}" -f $i, $rds | out-file $rptfile -Append
	}
}
Import-Module RemoteDesktop
$rptFile = "\\clvprdinfs001\IT_FileSRV\reports\RDOptimize\CMSMFA.txt"
"---- CMS MFA RDS Session Monitor Start {0}" -f (get-date -f "MM/dd/yy HH:mm") | out-file $rptFile -Append
logoff-idlesessions
"---- CMS MFA RDS Session Monitor Complete {0}" -f (get-date -f "MM/dd/yy HH:mm") | out-file $rptFile -Append