#################################################################################################################################
#
# Servers an be comma delimited or space delimited 
# ie: server1,server2
#     server1 server2
#
# Example #1
# & \\crt-bao-ap-01\d$\Scripts\AutomationTeam\UniversalSCOM_MW.ps1 -StartStopMM 'start' -Servers 'blx3011,bdc-orc12-db-01' -Duration '90'
#    or
# & \\crt-bao-ap-01\d$\Scripts\AutomationTeam\UniversalSCOM_MW.ps1 -StartStopMM 'start' -Servers 'blx3011 bdc-orc12-db-01' -Duration '90'

# Example #2
# & \\crt-bao-ap-01\d$\Scripts\AutomationTeam\UniversalSCOM_MW.ps1 -StartStopMM 'start' -Servers 'blx3011,bdc-orc12-db-01' 
#    or
# & \\crt-bao-ap-01\d$\Scripts\AutomationTeam\UniversalSCOM_MW.ps1 -StartStopMM 'start' -Servers 'blx3011 bdc-orc12-db-01' 
#
# Example #4
# & \\crt-bao-ap-01\d$\Scripts\AutomationTeam\UniversalSCOM_MW.ps1 -StartStopMM 'stop'  -Servers 'blx3011,bdc-orc12-db-01' 
#    or
# & \\crt-bao-ap-01\d$\Scripts\AutomationTeam\UniversalSCOM_MW.ps1 -StartStopMM 'stop'  -Servers 'blx3011 bdc-orc12-db-01' 
#
#
#################################################################################################################################

param( 
  [Parameter(Mandatory=$true)]
  [ValidateSet("start","stop")]
  [String]$StartStopMM,
  [Parameter(Mandatory=$true)]
  [ValidateNotNull()]
  [String]$Servers,
  [Parameter(Mandatory=$false)]
  [int]$Duration
)
   

$RC=0; $Node = $null

if (-not $Duration) 
{
    $Duration=15
}
else 
{
    if ($Duration -gt 1440) 
    {
        $Duration = 1440
    }
} 
$Duration

$startTime = [DateTime]::Now 

$endTime = $startTime.AddMinutes($Duration) 

Import-Module OperationsManager 


# See if comma delimiter or space delimiter
if ($Servers -like '*,*') {
    $delim = ","
} else {
    $delim = " "
}

foreach ($Node in $Servers.split("$delim") ) {

    $DT = get-date -format G
    
    $Node = $Node.Trim()
            
    if ( ($Node).Length ) {

        
        try
        {
        $Server = [System.Net.Dns]::GetHostByName(($Node)).hostname
        }
        catch
        {
            $Server = $null
        }

        if ($Server) 
        {

            try
            {

	            $Instances = Get-SCOMClassInstance -Name "*$Node*"; 

                if ($Instances) 
                {
                    # have to put sub objects in MM before the actual server else errors out
                    $InstancesInMM          = $Instances | Where-Object {$_.InMaintenanceMode -like "True"} | Get-Unique
                    $InstancesNotInMM       = $Instances | Where-Object {$_.InMaintenanceMode -like "False" -and $_.DisplayName -notlike $Server} | Get-Unique
                    $InstancesNotInMMServer = $Instances | Where-Object {$_.InMaintenanceMode -like "False" -and $_.DisplayName    -like $Server} | Get-Unique

                    if ($StartStopMM -like "start") 
                    {
                        if ($InstancesNotInMM) 
                        {
                            Start-SCOMMaintenanceMode -Instance $InstancesNotInMM -Reason "PlannedOther"    -EndTime $endTime   -Comment "Scheduled SCOM Maintenance Window"  -ErrorAction Continue #-WhatIf
                            write-host "$DT - $Server put in Maintenance Mode for $Duration Mins. MM end time $endTime"
                        } 
                        if ($InstancesNotInMMServer) 
                        {
                            Start-SCOMMaintenanceMode -Instance $InstancesNotInMMServer -Reason "PlannedOther"    -EndTime $endTime   -Comment "Scheduled SCOM Maintenance Window"  -ErrorAction Continue #-WhatIf
                            write-host "$DT - $Server put in Maintenance Mode for $Duration Mins. MM end time $endTime"
                        } 

                        if ($InstancesInMM) 
                        {
                            Set-SCOMMaintenanceMode -MaintenanceModeEntry $InstancesInMM -EndTime $endTime -Comment "Reset Maintenance Mode added $Duration Mins. End time now $endTime."
                            write-host "$DT - $Server MM will now end in $Duration Mins. End time now $endTime"
                        }
                    } else {
                        Get-SCOMMaintenanceMode   -Instance $Instances | Set-SCOMMaintenanceMode -EndTime (get-date) -Comment "Auto removed from maintenance mode" -ErrorAction Continue #-WhatIf
                        write-host "$DT - $Server taken out of Maintenance Mode" 
                    }
                }
            }
            catch
            {
                $RC=1
                write-host "$DT - $Node" $Error[0].Exception
            }

        }
    }
}

$endTime = [DateTime]::Now 
write-host " "
$elapsedTime = $endTime-$startTime
$totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
write-host "Script Execution Time = $totalTime"
write-host " "

write-host rc=$RC

exit $RC