<#
.SYNOPSIS
	Short description
.DESCRIPTION
	Long description
.EXAMPLE
	C:\PS>
	Example of how to use this cmdlet
.OUTPUTS
	email of html table
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		07.18.2017
	Created by:		John Kavanagh
	Organization:	TekSystems
	Filename:		get-newserverrpt.ps1
	===========================================================================
	07.26.2017 JJK:	V2 add new data to report <OperatingSystem, virt platform>
	07.27.2017 JJK:	Fixed issue with platform switch statement
	08.10.2017 JJK:	Add IP Address to report
	09.01.2017 JJK: Added logic to exclude clusters from report
	11.09.2017 JJK:	Added logic for recording action to automation database
	11.09.2017 JJK:	Removed my email address from SMTP To field
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
Param(
		[Parameter(Mandatory=$false,
			ValueFromPipeline=$false,
			ValueFromPipelineByPropertyName=$false,
			HelpMessage = "Amount of days to report on.")]
		[String]$serverAge = 30
)
Begin {
	$clusterInfo = get-cluster -domain "wfm.wegmans.com"
	. C:\etc\scripts\new-automationdbentry.ps1
	$procStart = [System.Diagnostics.StopWatch]::StartNew()
	Function send-serverreport {
	param (
		[Parameter(Mandatory = $true,
			ValueFromPipeline = $true,
			Position = 1,
			HelpMessage = "HTML Formatted data")]
		[System.String]$report_data
	)
	$mailparams = @{
		To          = "ITSecOnCall@wegmans.com"
		From        = "john.kavanagh@wegmans.com"
		Subject     = "New Server Report"
		Body        = $report_data
		bodyAsHTML  = $True
		SMTPServer  = "smtp.wegmans.com"
		ErrorAction = "Stop"
	}
	Try {
		send-mailmessage @mailparams
	}
	Catch {
		"Unable to send message"
		"Reason: {0}:" -f $error[0].exception.message
	}
	} # end send-serverreport
	$Report = @()
$style = @'
<style type="text/css">
table {
	width: 100%;
}
th {
	background-color: darkBlue;
	color: yellow;
}
caption {
    background-color: #f5f5f0;
    font-family: Monospace;
    border: 1px solid black
}
table, th, td {
	border: 1px solid black;
    border-collapse:collapse;
}
tr:nth-child(even) {
    background-color: AliceBlue};
}
'@
}
Process {
	#Build list of servers
	If ((get-date).Month -eq 1){
		# Handle report run in January
		$serverlist = get-adcomputer -Filter {OperatingSystem -like "*Server*"} -Properties OperatingSystem, WhenCreated |
		where {(get-date($_.WhenCreated)).Month -eq 12 -And (get-date($_.WhenCreated)).Year -eq (get-date).AddYears(-1).Year} |
		Sort-Object -Property WhenCreated
	}
	Else {
		$serverlist = get-adcomputer -Filter {OperatingSystem -like "*Server*"} -Properties OperatingSystem, WhenCreated |
		where {(get-date($_.WhenCreated)).Month -eq (get-date).AddMonths(-1).Month -And (get-date($_.WhenCreated)).Year -eq (get-date).Year} |
		Sort-Object -Property WhenCreated
	}
	ForEach ($srv in $serverlist ){
		If ($srv.name -notin $clusterInfo){
			# Only include servers not listed as a cluster
			Try {
				$nslooktest = [System.Net.Dns]::GetHostAddresses($srv.DNSHostName)
				$DNSRec = $True
				$ipAddr = $nslooktest.IPAddressToString
			}
			Catch {
				$DNSRec = $False
				$ipAddr = "No Data"
			}
			if ($DNSRec){
				try {
					$machType = get-wmiobject -Class Win32_ComputerSystem -ComputerName $srv.DNSHostName -ErrorAction Stop
					Switch ($machType.Manufacturer) {
						"VMware, Inc." {$platform = "VMware"}
						"Microsoft Corporation" {$platform = "Hyper-V"}
						Default {$platform = "Physical"}
					}
				}
				Catch {
					$platform = "No Data"
				}
			}
			Else {
				$platform = "No Data"
			}
			$obj = [pscustomobject]@{
				ServerName  = $srv.Name
				IPAddress   = $ipAddr
				DateCreated = $srv.WhenCreated
				OS          = $srv.OperatingSystem
				InDNS       = $DNSRec
				Platform    = $platform
			}
			$Report += $obj
			remove-variable ipAddr, DNSRec
		}
	}
	"Found {0} new servers to report on" -f $serverlist.count
	$tblHeader = "Servers Created in Last {0} Days" -f $serverAge
	$headerString = "<table><caption> Servers Created in {0}</caption>" -f (Get-Culture).DateTimeFormat.GetMonthName((get-date).AddMonths(-1).Month)
    $closing = "<p align='center'><i>2017 TechWintel $(Get-Date -UFormat '%D %R')</i></p>"
	$htmParams = @{
		Body        = "<h1>Monthly New Server Report<h1>"
		Head        = $style
		Title       = "New Server Report"
		As          = "Table"
		PreContent  = $headerString
        PostContent = $closing
	}
	$reportData = $Report | ConvertTo-HTML @htmParams | out-string
	send-serverreport -report_data $reportData
	$writeautomationrecSplat = @{
		computername    = "New Server Report sent to IT Security"
		jobType       = "NewServerReport"
		app           = "Wintel"
		jobLocation   = "$($MyInvocation.MyCommand.Name) on $env:computername"
		jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
		jobReturnCode = 0
	}
	write-automationrec @writeautomationrecSplat
}
End {
	Remove-Variable -Name headerString, tblHeader, serverlist, reportData, serverage
	[System.GC]::Collect()
}