function Disconnect-TerminalSessions {
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "Computer Name for terminating sessions.")]
	[String]$server,
	[String]$LogFileFolder = "\\wfm.wegmans.com\Departments\informationTechnology\TechWintel\.Scripts\Automation\Logs"
)
<#
.SYNOPSIS
	Function to terminate RDP sessions.
.DESCRIPTION
	Generic function that can be run against a server to terminate all RDP sessions.
.PARAMETER server
	Specifies a computer to query and terminate any RDP Sessions.
.EXAMPLE
	I ♥ PS >_ Disconnect-TerminalSessions -Server somecomputername
	Example of how to use this Function
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		07.11.2017
	Created by:		John Kavanagh
	Organization:	TekSystems
	Filename:		function-disconnectsessions.ps1
	===========================================================================
	07.11.2017 JJK: Converted to function
	07.11.2017 JJK: qwinsta does not support credential parameter object
	08.23.2017 JJK:	Added Logging for sessions disconnected and Errors
#>
begin {
	$sessStates = "Active","Disconnected"
	$LogFile = "$(get-date -UFormat %m%d%Y)Sessions.log"
}
process {
	try {
		$conns = (qwinsta /server:$server | foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv) 
		$varSessions = $conns | where-object {$_.State -in $sessStates -And $_.UserName -ne ""}
		ForEach ($obj in $varSessions){
			"Disconnecting {0} from {1}" -f $obj.UserName, $server
			logoff $obj.ID /Server:$server
			"{0}: {1} logged off {2}" -f (get-date -UFormat "%m/%d/%y %R"), $obj.UserName, $server | out-file (join-path $LogFileFolder -ChildPath $LogFile) -Append
		}
	}
	Catch {
			"Unable to query {0}" -f $server
			"{0}: Error {1}" -f (get-date -UFormat "%m/%d/%y %R"), $Error[0].Exception.Message | out-file (join-path $LogFileFolder -ChildPath $LogFile) -Append
	}
}
end {
	Remove-Variable server, obj, varSessions, conns, sessStates
	[System.GC]::Collect()
}
} # End Function
