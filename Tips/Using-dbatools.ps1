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
    I ♥ PS >_
    Example of how to use this cmdlet
.EXAMPLE
    I ♥ PS >_
    Another example of how to use this cmdlet
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    ===========================================================================
    Created with:	Visual Studio Code
    Created on:		04.03.2018
    Created by:		Kavanagh, John J.
    Organization:	TEKSystems
    Filename:		Using-dbatools.ps1
    ===========================================================================
    date initials: Enter first comment here
#>

BEGIN{
    $Report = @()
}
PROCESS {
    $servers =  get-adcomputer -Filter {OperatingSystem -like "*Windows Server*" -and Name -like "*sql*"} -Properties PasswordLastSet |
                    Where {((get-date)-$_.PasswordLastSet).TotalDays -le 31} |
                    Select-Object -Property Name, PasswordLastSet, @{N="DaysElapsed";e={((get-date)-$_.PasswordLastSet).TotalDays}} |
                    Sort-Object -Property Name
    ForEach ($srv in $servers){
        $dbainst = Find-DbaInstance -computername $srv.name | select-object  *
        If ($dbainst){
            $obj = [pscustomobject]@{
                ServerName   = $dbaInst.ComputerName
                SQLInstance  = $dbainst.SqlInstance
                InstanceName = $dbainst.InstanceName
            }
            $Report += $obj
        }
    }
}
END {
    $Report
}
