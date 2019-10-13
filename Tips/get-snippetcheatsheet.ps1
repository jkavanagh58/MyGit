#Requires -Modules ImportExcel, psWriteWord # @{ ModuleName="PSWriteWord"; ModuleVersion="0.4.3"}
<#
.SYNOPSIS
	Creates Cheat Sheets for PowerShell Snippets
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
	Filename:		get-snippetcheatsheet.ps1
	===========================================================================
	07.06.2018 JJK:	TODO:Create process to report on ISE Snippets
	07.06.2018 JJK:	TODO:Determine how to handle output location
	07.06.2018 JJK:	Create function for exporting Cheat Sheet to Excel worksheet
	07.06.2018 JJK:	TODO:Method to determine source JSON does not have comments
	07.06.2018 JJK: TODO: work with ISE Snippet files $env:USERPROFILE\Documents\WindowsPowerShell\Snippets
#>
[CmdletBinding()]
Param(
    [parameter(Mandatory = $False, ValueFromPipeline = $True,
        HelpMessage = "Output Desired")]
    [ValidateSet("Excel", "Word", "Both")]
    [System.String]$OutPutType = "Both",
    [parameter(Mandatory = $False, ValueFromPipeline = $True,
        HelpMessage = "Location for output")]
    [ValidateScript( { Test-Path $_ })]
    [System.String]$OutPutLocation = "$env:userprofile\Documents",
    [parameter(Mandatory = $False, ValueFromPipeline = $True,
        HelpMessage = "Code to verify Source File")]
    [ValidateSet( { Test-Path $_ })]
    [System.String]$snipSourceFile = "C:\Users\vndTekJXK\.vscode-insiders\extensions\ms-vscode.powershell-1.12.1\snippets\powershell.json"

)
BEGIN {
    Function New-ExcelCheatSheet {
        [CmdletBinding()]
        Param (
            [parameter(Mandatory = $True, ValueFromPipeline = $True,
                HelpMessage = "Data to be written to Excel file")]
            [System.Array]$tblData
        )
        # Create cheatsheet in Excel
        $exportExcelSplat = @{
            BoldTopRow    = $True
            FreezeTopRow  = $True
            Path          = "c:\etc\PSSnippets.xlsx"
            AutoSize      = $true
            WorkSheetname = "VSCode PowerShell Snippets"
            ClearSheet    = $true
        }
        $snippetList | export-Excel @exportExcelSplat
    }
    Function New-WordCheatSheet {
        [CmdletBinding()]
        Param (
            [parameter(Mandatory = $True, ValueFromPipeline = $True,
                HelpMessage = "Data to be written to Excel file")]
            [System.Array]$tblData
        )

        # Create Word doccument
        $snippetDoc = New-WordDocument -FilePath "c:\etc\Snippets.docx"

        $addWordTextSplat = @{
            WordDocument = $snippetDoc
            FontFamily   = "Fira Code"
            Text         = "Snippet CheatSheet For VSCode PowerShell"
            FontSize     = 14
            CapsStyle    = "SmallCaps"
        }
        $openPara = Add-WordText @addWordTextSplat
        #Set-WordParagraph -Paragraph $openPara -WordDocument $snippetDoc -Alignment center

        Add-WordParagraph -WordDocument $snippetDoc
        $addWordTableSplat = @{
            AutoFit      = 'Contents'
            WordDocument = $snippetDoc
            DataTable    = $tbldata
            Design       = "LightShadingAccent5"
            Titles       = "Prefix", "Name", "Description"
        }
        <#
			Removed from splat for formatting questions
			FontSize     = 12, 12, 8
            Color        = 'Blue', 'Green', 'Red'
			FontFamily   = 'Arial', 'Tahoma'
			Columns      = "What" - add-wordtable returns no such parameter
		#>
        $tbl1 = Add-WordTable @addWordTableSplat


        Save-WordDocument -WordDocument $snippetDoc
    }
    # Determine version of Visual Studion Code
    If ($vscodeInstall = Get-Command -Name "code*" -CommandType Application -ErrorAction SilentlyContinue) {
        # Process how to handle each version
        If ($vscodeInstall.count -eq 1) {
            "Working with {0}" -f $vscodeinstall.Name.Replace(".cmd", "")
            # Set location of VSCode snippet folder
            switch ($vscodeinstall.name) {
                "*insider*" { $vscodeFolder = Join-Path -Path $env:APPDATA -ChildPath "\Code - Insider'\User\Snippets" }
                Default { $vscodeFolder = Join-Path -Path $env:APPDATA -ChildPath "\Code\User\Snippets" }
            }
        }
        Else {
            "Really need to determine best way to handle"
        }
    }
    Else {
        "Unable to determine Visual Studio Code is installed"
        Start-Sleep -Seconds 5
        Write-Error -Message "Unable to determine Visual Studio Code is installed"
    }
}
PROCESS {

    $snippetInfo = New-Object System.Collections.ArrayList
    $snipSource = get-content $snipSourceFile -raw
    $jsonObj = $snipSource | ConvertFrom-Json
    $hash = @{ }
    foreach ($property in $jsonObj.PSObject.Properties) {
        #$property.Prefix
        #$hash = @{$property.Name = $property.Value;$property.Prefix = $property.Prefix}
        $newrow = [PSCustomObject]@{
            Name        = $property.Name.Trim()
            Prefix      = $property.Value.prefix.Trim()
            Description = $property.Value.Description
        }
        $snippetInfo.Add($newrow) | Out-Null
    }
    # Create dataset for cheat sheet output
    $snippetList = $snippetInfo | Sort-Object -Property Name
    # New-ExcelCheatSheet -tblData $snippetList
    New-WordCheatSheet -tbldata $snippetList

}
END {
    Remove-Variable -Name OutputType, OutPutLocation
    [System.GC]::Collect()
}