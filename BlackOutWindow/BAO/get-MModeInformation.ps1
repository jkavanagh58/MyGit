<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.PARAMETER Path
    Specifies a path to one or more locations.
.PARAMETER LiteralPath
    Specifies a path to one or more locations. Unlike Path, the value of LiteralPath is used exactly as it
    is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose
    it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
    characters as escape sequences.
.PARAMETER InputObject
    Specifies the object to be processed.  You can also pipe the objects to this command.
.EXAMPLE
    C:\PS>
    Example of how to use this cmdlet
.EXAMPLE
    C:\PS>
    Another example of how to use this cmdlet
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    ===========================================================================
    Created with:	Visual Studio Code
    Created on:		09.26.2018
    Created by:		Kavanagh, John J.
    Organization:	TEKSystems
    Filename:		get-MModeInformation.ps1
    ===========================================================================
    date initials: Enter first comment here
#>

[CmdletBinding()]
Param (
    [parameter(Mandatory=$True, ValueFromPipeline=$True,
            HelpMessage = "The computer name for the Maintenance Mode Report")]
    [System.String]$computerName,
    [parameter(Mandatory=$False, ValueFromPipeline=$False,
            HelpMessage = "Variable used to ensure object is the server/computer object")]
    $scomClass
)
BEGIN {
    <#
    Try {
        # Unable to use in Wegmans environment
        Test-NetConnection -ComputerName $computerName -InformationLevel Quiet
    }
    Catch {
        $Error[0].Exception.Message
        Write-Error -Message "Unable to contact the computer you are requesting a report on" -RecommendedAction "Verify the server name" 
        Start-Sleep -Seconds 3
        EXIT
    }
    #>
    Write-Verbose -Message "[BEGIN]Establishing SCOM API library"
    $startOperationsManagerClientShellSplat = @{
        PersistConnection    = $true
        Interactive          = $true
        ManagementServerName = $omServer
    }
    Start-OperationsManagerClientShell @startOperationsManagerClientShellSplat | Out-Null
    Write-Verbose -Message "[BEGIN]Establishing Class Type"
    $scomClass = Get-ScomClass -Name "Microsoft.Windows.Computer"
}
PROCESS {
    $computerObject = get-scomclassinstance -Class $scomClass | where-Object {$_.DisplayName -eq $computerName}
    $computerObject.GetMaintenanceModeHistory()
}
END {
    Remove-Variable -Name computerName, scomClass, computerObject
    [System.GC]::Collect()
}