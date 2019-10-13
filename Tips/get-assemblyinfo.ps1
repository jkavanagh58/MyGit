<#
.SYNOPSIS
	Get version information for DLL files
.DESCRIPTION
	Long description
.PARAMETER Chech
	Specifies file or file path to check for.
.PARAMETER LiteralPath
	Specifies a path to one or more locations. Unlike Path, the value of LiteralPath is used exactly as it
	is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose
	it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
	characters as escape sequences.
.EXAMPLE
	I ♥ PS # .\get-assemblyinfo.ps1 -check c:\windows
	Another example of how to use this cmdlet
.INPUTS
	Inputs to this cmdlet (if any)
.OUTPUTS
	Output from this cmdlet (if any)
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		02.21.2018
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		get-assemblyinfo.ps1
	===========================================================================
	02.21.2018 JJK:	Using PSIsContainter equals false to allow backward compatability
	02.21.2018 JJK:	Currently only intended for local access
	02.21.2018 JJK:	Provide two input paramers to designate file or folder
    02.21.2018 JJK: TODO: Allow for specifying computername for remote operations
    02.22.2018 JJK: TODO: Validate Script to test-path for dllfile and folder using join
#>
Param(
    [Parameter(Mandatory = $false,
        ParameterSetName = "File",
		ValueFromPipeline = $true,
		HelpMessage = "File or File Path to report on.")]
    [String]$dllfile,
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
		HelpMessage = "File or File Path to report on.")]
	[ValidateScript({ Test-path $_ })]
    [System.String]$folder
)
Begin {
$Report = @()
}
Process {
    if ($dllfile){"Looking at a file"
        If (Test-Path (join-path -Path $folder -ChildPath $dllfile)){"File and Path are valid"}
        Else {
            Write-error -Message "You have entered a file that cannot be found"
            Exit
        }
        $files = get-childitem $dllfile -Path $folder -recurse -force -ErrorAction SilentlyContinue | Where-Object -Property PSIsContainer -EQ -Value PSIsContainer
        ForEach ($file in $files){
            $obj = [pscustomobject]@{
                "File Name"       = $file.BaseName
                Location          = $file.DirectoryName.Split("\")[-1]
                Product           = $file.VersionInfo.ProductName
                "Product Version" = $file.VersionInfo.ProductVersion
                "File Version"    = $file.VersionInfo.FileVersion
            }
            $Report += $obj
        }
        $Report
    }
    Else {"Looking at a folder"}
    <#
    $files = get-childitem *.dll -Path c:\windows -recurse -force -ErrorAction SilentlyContinue | Where {$_.PSIsContainer -eq $False}
	ForEach ($file in $files){
		$obj = [pscustomobject]@{
			"File Name" = $file.BaseName
			Product = $file.VersionInfo.ProductName
			"Product Version" = $file.VersionInfo.ProductVersion
			"File Version" = $file.VersionInfo.FileVersion
		}
		$Report += $obj
	}
    $Report
    #>
}