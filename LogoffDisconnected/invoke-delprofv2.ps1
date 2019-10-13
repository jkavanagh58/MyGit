Function clean-localprofiles {
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "Computer Name for removing profiles.")]
	[String]$server,
	[Parameter(Position = 0)]
		[ValidateNotNullorEmpty()]
	[int]$Days = 15,
	[String]$LogFileFolder = "\\wfm.wegmans.com\Departments\informationTechnology\TechWintel\.Scripts\Automation\Logs"
	)
BEGIN {
		$LogFile = "$(get-date -UFormat %m%d%Y)Profiles.log"
		"---- {0} Profile Monitor Start {1}" -f $server, (get-date -f "MM/dd/yy hh:mm") | out-file (join-path $LogFileFolder -ChildPath $LogFile) -Append
		Write-Warning "Filtering for user profiles older than $Days days"
		$profs = Get-CimInstance win32_userprofile -ComputerName $server  |
		Where { $_.LastUseTime -lt $(Get-Date).Date.AddDays(- $days) -AND $_.SID.Length -gt 8 -AND $_.Loaded -eq $False }
}
PROCESS	{
	ForEach ($obj in $profs) {
		$uname = $obj.LocalPath.Split("\") | select -Last 1
		Try {
			Remove-CimInstance -InputObject $obj -ComputerName $obj.pscomputername
               "Removed profile for {0} from {1} which was last used {2}" -f $uname, $obj.pscomputername, $obj.LastUseTime |
		    out-file (join-path $LogFileFolder -ChildPath $LogFile) -Append
		}
		Catch {
			"Unable to remove (0) profile" -f $uname | out-file (join-path $LogFileFolder -ChildPath $LogFile) -Append
		}
	}
		# Complete
}
END	{
	"---- CMS MFA RDS Profile Monitor Complete {0}" -f (get-date -f "MM/dd/yy hh:mm") |
		out-file $rptFile -Append
}
}
# Call functon
Clean-localprofiles -server $ts