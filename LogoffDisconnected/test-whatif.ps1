<#
.SYNOPSIS
	Performs graceful logoff for Disconnected terminal sessions
.DESCRIPTION
	Performs graceful lofoff for Disconnected terminal sessions. Script was previously established to be run on
	demand by Operations. Script adds support for WhatIf as well as logging.
.PARAMETER rptFile
	Specifies the path to log the logoff attempts.
.PARAMETER servers
	Specifies a list of servers to check for disconnected user terminal sessions
.EXAMPLE
	C:\PS>.\run-logoffsess.ps1
	Runs the script and will attempt to logoff disconnected sessions.
.EXAMPLE
	C:\PS>.\run-logoffsess.ps1 -WhatIf
	Runs the script but will only report (to console) the sessions that would be effected.
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		07.28.2017
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		scratchpad-sessions.ps1
	===========================================================================
	07.31.2017 JJK:	Removed tst-tools-ts-01 from servers list
	09.05.2017 JJK:	Added WhatIf statement
	09.26.2017 JJK: # results are errorneous, reports on remove-variable
	10.03.2017 JJK: Added debug output
	10.05.2017 JJK:	Removed from the foreach loop that evaluates conns - duplicate filter
#>
[CmdletBinding(SupportsShouldProcess=$true)]
Param(
	[String]$LogFileFolder = "\\wfm.wegmans.com\Departments\informationTechnology\TechWintel\.Scripts\Automation\Logs",
	$LogFile = "$(get-date -UFormat %m%d%Y)Sessions.log"
)
Begin {
	$servers = "wfm-tools-ts-01", "wfm-tools-ts-02", "wfm-rae-ts-01", "wfm-rae-ts-02"
}
Process{
	ForEach ($server in $servers){
		$conns = qwinsta /SERVER:$server | select-string "Disc" | select-string -notmatch "services"
		# Removed from following foreach loop
		# | Where {$_.ID -eq "Disc" -and $_.Username -ne "services"}
		ForEach ($s in $conns ){
			# Format into a field object
			$obj = @{}
			$obj.user	= ($s.tostring() -split ' +')[1]
			$obj.id		= ($s.tostring() -split ' +')[2]
			$obj.State	= ($s.tostring() -split ' +')[3]
			if ($PSCmdlet.ShouldProcess($obj.user, "Disconnecting")) {
				Try {
					"Disconnecting {0} from {1}" -f $obj.user, $server
					& logoff $obj.ID /Server:$server
					"{0}: {1} logged off {2}" -f (get-date -UFormat "%m/%d/%y %R"), $obj.user, $server | out-file (join-path $LogFileFolder -ChildPath $LogFile) -Append
				}
				Catch {
					"Writing error to logfile"
					"{0}: {1} Error {2}" -f (get-date -UFormat "%m/%d/%y %R"), $obj.user, $Error[0].Exception.Message | out-file (join-path $LogFileFolder -ChildPath $LogFile) -Append
				}
			}
		}
	}
}
End {
	[System.GC]::Collect()
}