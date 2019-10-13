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
    Created on:		10.28.2018
    Created by:		Kavanagh, John J.
    Organization:	TEKSystems
    Filename:		Untitled-1
    ===========================================================================
    date initials: Enter first comment here
#>

# Simple process to delete older files/folders from users Temp folder
$filesTemp = get-childitem *.* -Path $env:TEMP | Where-Object {((get-date) - ($_.LastWriteTime)).TotalDays -gt 30}
ForEach ($filesItem in $filesTemp) {
    If ($filesItem.PSIsContainer) {
        Try {
            Remove-Item $filesItem.FullName -Recurse -Force -WhatIf
        }
        Catch {
            $Error[0].exception.message
        }
    }
    Else {
        Try {
            Remove-Item $filesItem.FullName -Force -WhatIf
        }
        Catch {
            $Error[0].Exception.Message
        }
    }
}