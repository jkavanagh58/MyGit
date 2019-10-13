<#
.SYNOPSIS
    Reports active MaintenanceMode information.
.DESCRIPTION
    Reports active MaintenanceMode information. Uses the currentTimeZone information
    to adjust the MaintenanceMode time information for local use.
.PARAMETER objSCOMAgent
    Specifies a computer name for Maintenance Mode Reporting
.PARAMETER objCalcMin
    Time offset in Minutes for displaying reported DateTime in output
.EXAMPLE
    C:\PS> .\get-maintmoderec.ps1 -servername yourserver
    Example of how to use this cmdlet to report when the current OpsMgr Maintenance Window started
    and when it will end or when the last window started and ended
.NOTES
    ===========================================================================
    Created with:	Visual Studio Code
    Created on:		10.23.2018
    Created by:		Kavanagh, John J.
    Organization:	TEKSystems
    Filename:		log-maintmoderec.ps1
    ===========================================================================
    10.23.2018 JJK:	DONE: Verify computer is in MaintenanceMode
    10.23.2018 JJK: DONE: Determine usability and provide option to read last entry even if not current
#>
[CmdletBinding()]
Param (
    [parameter(Mandatory = $True, ValueFromPipeline = $True,
        HelpMessage = "Name of SCOM Agent")]
    [Alias("ServerName")]
    [System.String]$objSCOMAgent,
    [parameter(Mandatory = $False, ValueFromPipeline = $False,
        HelpMessage = "TimeZone Offset in Minutes")]
    [System.Double]$objCalcMin = [System.TimeZone]::CurrentTimeZone.GetUtcOffset([datetime]::Now).TotalMinutes
)
BEGIN {
    $scomClass = Get-ScomClass -Name "Microsoft.Windows.Computer"
    $priInstance = get-scomclassinstance -Class $scomClass | where DisplayName -eq ([System.Net.DNS]::GetHostByName($objSCOMAgent).HostName)
}
PROCESS {
    if ($priInstance.InMaintenanceMode) {
        $curMM = Get-SCOMMaintenanceMode -Instance $priInstance
        "Maintenance Mode for {0} Started {1} and will end {2}" -f $objSCOMAgent, $curMM.StartTime.AddMinutes($objCalcMin), $curMM.ScheduledEndTime.AddMinutes($objCalcMin)
    } 
    Else {
        Write-Warning "Computer object is not currently in MaintenanceMode"
        $allMM = Get-SCOMMaintenanceMode -instance $priInstance -History
        $curMM = $allMM[$allMM.Count - 1]
        "Last Maintenance Mode for {0} Started {1} and ended {2}" -f $objSCOMAgent, $curMM.StartTime.AddMinutes($objCalcMin), $curMM.EndTime.AddMinutes($objCalcMin)
    }
}
END {
    <# 
        Clear variables from memory. ErrorAction set to SilentlyContinue as allmm only exists in
        certain instances.

    #>
    Remove-Variable -Name curmm, priInstance,allmm -ErrorAction SilentlyContinue
    [System.GC]::Collect()
    
}
