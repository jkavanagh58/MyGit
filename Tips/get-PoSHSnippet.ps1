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
    Created on:		datecreated
    Created by:		Kavanagh, John J.
    Organization:	TEKSystems
    Filename:		get-PoSHSnippet.ps1
    ===========================================================================
    date initials: Enter first comment here
#>
[CmdlEtBinding()]
Param (
    # Specifies a path to one or more locations.
    [Parameter(Mandatory=$False,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true,
               HelpMessage="Path to VSCode Snippet Folder.")]
    [Alias("SnippetPath")]
    [ValidateNotNullOrEmpty()]
    [string[]]$pathVSCodeSnippet = Join-Path $env:APPDATA -ChildPath "\Code\User\snippets"
    $wrResults = 'powershell1.json'
)
BEGIN {

}
PROCESS {
    $invokeWebRequestSplat = @{
        Headers = @{"Accept-Encoding"="gzip, deflate, br"; "Accept-Language"="en-US,en;q=0.9"; "Upgrade-Insecure-Requests"="1"; "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36"; "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"; "Referer"="https://github.com/jkavanagh58/slackgroup/blob/master/Snippets/vscode/powershell.json"}
        Uri = "https://raw.githubusercontent.com/jkavanagh58/slackgroup/master/Snippets/vscode/powershell.json"
        OutFile = $wrResults
        UseBasicParsing = $True
    }
    Invoke-WebRequest @invokeWebRequestSplat
    get-content $wrResults | ConvertFrom-JSON
}
END {
    Remove-Variable -Name pathVSCodeSnippet, wrResults
    [System.GC]::Collect()
    
}

