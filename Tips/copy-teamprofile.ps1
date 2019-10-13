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
    Created on:		05.01.2019
    Created by:		Kavanagh, John J.
    Organization:	TEKSystems
    Filename:		Untitled-1
    ===========================================================================
    date initials: Enter first comment here
#>
[CmdletBinding()]
param(
    [parameter(Mandatory = $False, ValueFromPipeline = $False,
        HelpMessage = "Url to File in Repository")]
    [System.String]$urlProfile = "https://wegit.visualstudio.com/_git/ServiceDelivery?path=%2FTips%2Fsample-profile.ps1&version=GBmaster",
    [parameter(Mandatory = $False, ValueFromPipeline = $True,
        HelpMessage = "Destination for downloaded file")]
    [System.String]$destFolder = "$env:USERPROFILE\Documents\WindowsPowerShell",
    [parameter(Mandatory = $False, ValueFromPipeline = $True,
        HelpMessage = "HelpMessage")]
    [System.String]$destFile = "check.ps1"
)
BEGIN {
    $userProfile = Join-Path $destFolder -ChildPath $destFile
    If (Test-Path $userProfile) {
        # Backup the current file for ability to rollback
        Copy-Item $userProfile -Destination "$destFolder\profile.backup"
    }
}
PROCESS {
    $invokeWebRequestSplat = @{
        OutFile = $userProfile
        Uri     = $urlProfile
    }
    Invoke-WebRequest @invokeWebRequestSplat
}
END {
    Remove-Variable -Name dest*, userProfile, urlProfile
    [System.GC]::Collect()

}




