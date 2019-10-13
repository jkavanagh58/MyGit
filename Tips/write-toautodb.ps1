Begin {
	# Load database function into memory
	Try {
		. "\\wfm.wegmans.com\Departments\InformationTechnology\TechWintel\.Scripts\Automation\new-automationdbentry.ps1"
	}
	Catch {
		# Write Log entry
		"{0}: {1} was unable to load the automation database function, please check execution policy" -f (Get-Date -UFormat '%x-%X'), $myinvocation.MyCommand.Name |
			Out-File c:\temp\automation.log -Append
	}
}
Process {
	ForEach ($action in $process){
		# Start Stopwatch
		$procStart = [System.Diagnostics.StopWatch]::StartNew()
		# This is where you goodness goes
		Try {
			# Perform an action, for example disconnect one of the terminal sessions from process
			# Now lets write this  action to the automation database
			# I use the format operator because it is flexible and quicker than concatenation
			# This string will record the action performed in the name of automation
			$dbText = "{0} logged off from {1}: Session State {2}" -f $obj.User, $server, $obj.State
			# For readability I use a splat to pass all parameters to the function
			$writeautomationrecSplat = @{
				procAction    = $dbText
				jobType       = "DisconnectTerminalSessions"
				app           = "Wintel"
				jobLocation   = "$($MyInvocation.MyCommand.Name) on $env:computername"
				jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
				jobReturnCode = 0
			}
			# Call the function from new-automationdbentry.ps1 passing all parameters from the splat
			write-automationrec @writeautomationrecSplat
		}
		Catch {
			# Even failures should be recorded, it is still part of automation
			# This is the same as the previous approach but we change the descriptive text and the ReturnCode
			$dbText = "Failed to logoff {0} from {1}" -f $obj.User, $server
			$writeautomationrecSplat = @{
				procAction    = $dbText
				jobType       = "DisconnectTerminalSessions"
				app           = "Wintel"
				jobLocation   = "$($MyInvocation.MyCommand.Name) on $env:computername"
				jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
				jobReturnCode = 1
			}
			write-automationrec @writeautomationrecSplat
		}
	} # Done processing all actions in process
}