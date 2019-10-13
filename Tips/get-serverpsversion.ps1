<#
.SYNOPSIS
	Report on servers not running WMF5.
.DESCRIPTION
	Long description
.PARAMETER Path
	Specifies a path to one or more locations.
.PARAMETER LiteralPath
	Specifies a path to one or more locations. Unlike Path, the value of LiteralPath is used exactly as it
	is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose
	it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
	characters as escape sequences.
.EXAMPLE
	C:\PS> .\get-serverpsversions.ps1
	Example of how to use this script
.LINK
	https://docs.microsoft.com/en-us/powershell/wmf/5.1/compatibility
.OUTPUTS
	Output from this cmdlet (if any)
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		12/03/2017
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		get-serverpsversion.ps1
	===========================================================================
	12.06.2017 JJK:	TODO: Include check for Exchange 2013 and 2010, Lync Server 2010, SMA 2012 R2
    12.06.2017 JJK: TODO: Formalize report creation
    03.05.2018 JJK: DONE: Add Authentication to address older versions of WSMAN
    03.05.2018 JJK: TODO: Expand Catch to elaborate Unable to Access
    03.05.2018 JJK: DONE: Change Report output to \\wfm.wegmans.com\departments\InformationTechnology\TechWintel\.Scripts\Automation\WMF5.1
#>
#Requires -Module ImportExcel,ActiveDirectory
Begin {
	$Report = @()
	$reportFile = "\\wfm.wegmans.com\departments\InformationTechnology\TechWintel\.Scripts\Automation\WMF5.1\WMF5Audit.XLSX"
	$wksName = get-date -f MMddyyy
	$serverList = get-adcomputer -filter {OperatingSystem -like "*windows Server*"} -Properties OperatingSystem | select-Object -Property Name, OperatingSystem
}
Process {
	ForEach ($srv in $serverList | sort-Object -Property Name){
		if (test-wsman -computername $srv.name -credential $admcreds -Authentication Negotiate -ErrorVariable wsmanEV -ErrorAction SilentlyContinue){
			Try {
				$psVer = Invoke-Command -command {($psversiontable).psversion} -computername $srv.Name -credential $admcreds
				"{0} : {1} is running PowerShell {2}" -f $srv.Name, $srv.OperatingSystem, $psVer
				If ($psver.Major -lt 4){
					If ($srv.OperatingSystem -like "*2003*" -or $srv.OperatingSystem -like "*2008 Standard"){
						$obj = [pscustomobject]@{
							Server    = $srv.Name
							OS        = $srv.OperatingSystem
							PSVersion = $psVer
							Notes     = "Only WMF 2 compatible"
						}
						$Report += $obj
					}
					Else {
						$obj = [pscustomobject]@{
							Server    = $srv.Name
							OS        = $srv.OperatingSystem
							PSVersion = $psVer
							Notes     = "WMF 5 compatible"
						}
						$Report += $obj
					}
				}
				Else {
					$obj = [pscustomobject]@{
						Server    = $srv.Name
						OS        = $srv.OperatingSystem
						PSVersion = $psVer
						Notes     = "Current or almost current"
					}
					$Report += $obj
				}
			}
			Catch {
				"Unable to access {0}" -f $srv.Name
				$obj = [pscustomobject]@{
					Server    = $srv.Name
					OS        = $srv.OperatingSystem
					PSVersion = "Not Available"
					Notes     = $error[0].Exception.Message
				}
				$Report += $obj
			}
		}
		Else {
			"Remoting for {0} not available" -f $srv.Name
			$obj = [pscustomobject]@{
				Server    = $srv.Name
				OS        = "{0} - from AD" -f $srv.OperatingSystem
				PSVersion = "Not Available"
				Notes     = "Remoting Not Available: $($Error[0].Exception.Message)"
			}
			$Report += $obj
		}
	}
}
END {
	If ($Report){
		if (test-path $reportFile){
			remove-item $reportFile -Force
		}
		$Report | export-excel $reportFile -WorkSheetName $wksName -AutoSize
    }
    Remove-Variable -Name Report, reportfile, wksname, serverlist
    [System.GC]::Collect()
}