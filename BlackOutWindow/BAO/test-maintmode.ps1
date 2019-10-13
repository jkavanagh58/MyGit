<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.PARAMETER srv
    Computer name for SCOM Maintenance Mode you want to report on
.PARAMETER omServer
    Name of OpsMgr Server to connect to for SCOM SDK access.
.EXAMPLE
    C:\PS> .\test-maintenancemode.ps1 -srv servername
    Will report the current maintenance window information or most recent maintenance
    window information.
.INPUTS
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    ===========================================================================
    Created with:	Visual Studio Code
    Created on:		12.10.2018
    Created by:		Kavanagh, John J.
    Organization:	TEKSystems
    Filename:		test-maintmode.ps1
    ===========================================================================
    12.19.2018 JJK:	Clarified report objects to provide better reporting.
    12.12.2018 JJK:	Fixed class reference to reflect correct variable name.
    12.20.2018 JJK:	Verify date information, may need ToLocalTime
#>
[CmdletBinding(ConfirmImpact = 'Low')]
Param(
    [parameter(Mandatory = $True, ValueFromPipeline = $True,
        HelpMessage = "Name of computer for testing")]
    [Alias("servername")]
    [System.String]$srv,
    [parameter(Mandatory = $False, ValueFromPipeline = $False,
        HelpMessage = "Name of OpsMgr Server to use for SCOM API Actions")]
    [System.String]$opsMgrServer = "wfm-om12-msm-03.wfm.wegmans.com"
)
BEGIN {
    $startOperationsManagerClientShellSplat = @{
        PersistConnection    = $true
        Interactive          = $true
        ManagementServerName = $opsMgrServer
    }
    Start-OperationsManagerClientShell @startOperationsManagerClientShellSplat | Out-Null
}
PROCESS {
    Try {
        $serverObject = get-scomagent -Name ([System.Net.DNS]::GetHostByName($srv).HostName) -ErrorAction Stop
    }
    Catch {
        Write-Error "No OpsMgr Agent found for $($srv)" -ErrorAction Stop
    }
    $opsMgrClass = get-scomclass -name ’Microsoft.Windows.Computer’
    $opsMgrcomputer = get-scomclassinstance -Class $opsmgrclass | Where-Object {$_.Name -eq $serverObject.DisplayName}
    If ($opsMgrcomputer.InMaintenanceMode){
        "Current MaintenanceMode Window Information"
        $opsMgrcomputer.GetMaintenanceWindow() | select-Object -Property StartTime, ScheduledEndTime, Comments
    }
    Else {
        "Last MaintenanceMode Window Information"
        $opsMgrcomputer.GetMaintenanceWindowHistory() | Select-Object -Last 1 -Property Comments, StartTime, EndTime, User
    }
}
END {
    Remove-Variable -Name opsMgrcomputer, opsMgrClass, serverObject, startOperationsManagerClientShellSplat, opsMgrServer -ErrorAction SilentlyContinue
    [System.GC]::Collect()
}