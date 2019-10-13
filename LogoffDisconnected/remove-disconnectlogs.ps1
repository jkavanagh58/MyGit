$logDir = "\\wfm.wegmans.com\Departments\InformationTechnology\Techwintel\.Scripts\Automation\logs"
# Use get-childitem to find log files older than 30 days
$logFiles = (get-childitem *.log -Path $logDir).Where{((get-date) - $_.LastWriteTime).TotalDays -ge 30}
If ($logFiles){
	ForEach ($file in $LogFiles){
		Try {
			Remove-Item $file.fullname -Force
		}
		Catch {
			"Unable to delete {0}" -f $file.fullname
		}
	}
	Remove-variable logDir, logFiles
}