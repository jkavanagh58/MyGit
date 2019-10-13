# Code submitted via Automation Group not TechWintel
param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("start","stop")]
  [String]$StartStopMM,
  [Parameter(Mandatory=$true)]
  [ValidateNotNull()]
  [String]$Servers,
  [Parameter(Mandatory=$false)]
  [String]$Duration
)

# Why line continuation in a script
$RC=0; $Node = $null
# Why not just set a default value in Param statement
if (-not $Duration) {$Duration=15}

$startTime = [DateTime]::Now

$endTime = $startTime.AddMinutes($Duration)
#Requires -Module OperationsManager
#Import-Module OperationsManager

# Why is Servers variable being split? what is the variable receiving? Since Return code is being
# defined it is safe to assume another application or script is calling this
foreach ($Node in $Servers.split(',') ) {
	$DT = get-date -format G
	$Node = $Node.Trim()

	if ( ($Node).Length ) {
		try
		{
			$Server = [System.Net.Dns]::GetHostByName(($Node)).hostname

			$Instances = Get-SCOMClassInstance -Name "*$Server*"

			$allreadyInMM = $false
			# Just thinking $Instances.Where{$_.inMaintenanceMode} might be quicker
			foreach ( $t in $Instances) {
				if ($t.InMaintenanceMode) {
					$allreadyInMM = $true
				}
			}
			# Curious about this... checking all instances but not processing each instance, how does this handle
			# a single instance or if one is in maintenance mode we perform the same step
			# after meeting this is for expediency so understood
			# why not combine your if statement if ($startStopmm -eq "Start" -And !($t.InMaintenanceMode))
			# all use of DT variable here is inaccurate as it was written to
			if ($StartStopMM -like "start") {
				if (-not $allreadyInMM) {
					$startSCOMMaintenanceModeSplat = @{
						Instance    = $Instances
						EndTime     = $endTime
						Comment     = "Scheduled SCOM Maintenance Window"
						Reason      = "PlannedOther"
						ErrorAction = 'Continue'
					}
					Start-SCOMMaintenanceMode @startSCOMMaintenanceModeSplat
					write-output "$DT - $Server put in Maintenance Mode for $Duration Mins. MM end time $endTime"
				}
				else {
					write-output "$DT - $Server all ready in MM"
					$MMEntry = Get-SCOMMaintenanceMode -Instance $Instances
					$setSCOMMaintenanceModeSplat = @{
						MaintenanceModeEntry = $MMEntry
						EndTime              = $endTime
						Comment              = "Reset Maintenance Mode added $Duration Mins. End time now $endTime."
					}
					Set-SCOMMaintenanceMode @setSCOMMaintenanceModeSplat
					write-output "$DT - $Server MM extended $Duration Mins. End time now $endTime"
				}
			} else {
				$setSCOMMaintenanceModeSplat = @{
					EndTime     = (get-date)
					Comment     = "Removed from maintenance mode"
					ErrorAction = 'Continue'
				}
				Get-SCOMMaintenanceMode -Instance $Instances | Set-SCOMMaintenanceMode @setSCOMMaintenanceModeSplat
				# But DT was established at run time, not when the set-scommaintenanceMode cmdlet was run
				write-output "$DT - $Server taken out of Maintenance Mode"
				# why not something like this for example
				write-output "$(get-date -Format -G) - $Server taken out of Maintenance Mode"
			}
		}
		catch
		{
			$RC=1
			write-output "$DT - $Node" $Error[0].Exception
		}
	}
}

$endTime = [DateTime]::Now

write-output " "
write-output "Script startTime - $startTime"
write-output "Script endTime   - $endTime"
write-output " "

write-output "rc=$RC"

exit $RC
