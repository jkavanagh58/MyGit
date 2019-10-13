<#
.SYNOPSIS
    Quick Server Report for MSMQ servers
.DESCRIPTION
    Basic system information report with inclusion of MSMQ elements. Can be run locally or remotely
.PARAMETER rptMachineName
    Specifies the computer to report on.
.PARAMETER rptEmail
    Switch parameter, if specified the report will be sent via email.
.PARAMETER rptRemote
    Switch parameter used to establish how data is gathered.
.EXAMPLE
    C:\PS> C:\etc\scripts\get-msmqsrvinfo.ps1
    Generates report for the local machine, output to console
.EXAMPLE
    C:\PS> C:\etc\scripts\get-msmqsrvinfo.ps1 -ServerName wfm-msmq-sp-01
    Generates report for a specific server, output to console
.EXAMPLE
    C:\PS> C:\etc\scripts\get-msmqsrvinfo.ps1 -ServerName wfm-msmq-sp-01 -rtpEmail
    Generates report for specific server. Operator will be prompted for email address for 
    the report to be sent via email.
.EXAMPLE
    C:\PS> C:\etc\scripts\get-msmqsrvinfo.ps1 -ServerName wfm-msmq-sp-01 -rtpEmail -emailaddress youremail@wegmans.com
    Generates report for specific server. The process will use the value entered for emailaddress parameter
    the report to be sent via email,
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    ===========================================================================
    Created with:	Visual Studio Code
    Created on:		02.19.2018
    Created by:		Dan Pirro
    Organization:	Wegmans
    Filename:		get-msmqinfo.ps1
    ===========================================================================
    02.21.2019 JJK: TODO: Allow for script to detect and run commands locally or remotely
    02.21.2019 JJK: DONE: Modify Services output to append string where StartName is null
    02.27.2019 JJK: DONE: Limit disk report to DriveType 3
#>
[CmdletBinding()]
Param (
    [parameter(Mandatory=$False, ValueFromPipeline=$True,
        HelpMessage = "Computer name for System Output")]
    [Alias("ServerName")]
    [System.String]$rptMachineName,
    [parameter(Mandatory=$False, ValueFromPipeline=$True,
        HelpMessage = "Run mode for this report")]
    [Switch]$rptRemote = $False,
    [parameter(Mandatory = $False, ValueFromPipeline = $True,
        HelpMessage = "Specify you would like Report emailed")]
    [Alias("SendEmail")]
    [Switch]$rptEmail,
    [parameter(Mandatory=$False, ValueFromPipeline=$True,
        HelpMessage = "Email Address ")]
    [System.String]$emailAddress
)
BEGIN {
    Function send-rptemail {
        [CmdletBinding()]
        Param (
            [parameter(Mandatory = $True, ValueFromPipeline = $True,
                HelpMessage = "Report File to be attached")]
            [System.String]$emailAttachment
        )
        If (!($emailAddress)) {
            $emailAddress = Read-Host -Prompt "E-Mail Address to send the report"
        }
        $emailBody = get-content $emailAttachment | Out-String
        $mailparams = @{
            To          = $emailAddress
            From        = "techadminjxk@wegmans.com"
            Subject     = "MSMQ Server Report"
            Body        = $emailBody
            bodyAsHTML  = $False
            SMTPServer  = "smtp.wegmans.com"
        }
        Try {
            Send-MailMessage @mailparams -ErrorAction SilentlyContinue
        }
        Catch {
            write-error -Message "Unable to send mail message"
            $error[0].Exception.Message
        }
    }
    If ($rptMachineName -And $rptMachine -ne $env:COMPUTERNAME){
        Write-Verbose -Message "[BEGIN]Script running remotely"
        $rptRemote = $True
        # Establish PSSessiion
        Try {
            $compPSsession = New-PSSession -Name $rptMachineName -ComputerName $rptMachineName
            $compCIMSession = New-CIMSession -ComputerName $rptMachineName
        }
        Catch {
            Write-Error -Message "Unable to establish Secure Session" -ErrorAction Continue
            $Error[0].Exception.Message
            Exit
        }
    }
    Else {
        Write-Verbose -Message "[BEGIN]Script running locally"
    }
# Here String used to prevent injection attach
$sbMSMQQuery = @"
Get-MsmqQueue -Name '*' -QueueType Private
"@
    # $rptFile = [System.IO.Path]::Combine($env:TEMP, [GUID]::NewGuid().ToString("N") + '.txt')
    $rptFile = New-Item -Name msmqrpt.txt -Path $env:temp -Force
    Set-Content $rptfile "MSMQ Report Generated $(Get-Date -Format 'MM.dd.yyyy HH:mm')"
}
PROCESS {
    If ($rptRemote){
        $retHostName = Invoke-Command -Session $compPSsession -ScriptBlock {$env:COMPUTERNAME}
    }
    Else {
        $retHostName = $env:COMPUTERNAME
    }
    # "Report for Hostame: {0}" -f $retHostName | Out-File $rptFile
    "Report for Hostame: {0}" -f $retHostName | Add-Content $rptFile
    If ($rptRemote){
        $retOSInfo = Get-CimInstance -CimSession $compCIMSession -ClassName Win32_OperatingSystem
    }
    Else {
        $retOSInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    }
    "{0} Build {1}" -f $retOSInfo.Caption, $retOSInfo.BuildNumber | Add-Content -Path $rptFile
    # Domain Information
    If ($rptRemote) {
        $retCompInfo = Get-CimInstance -CimSession $compCIMSession -ClassName Win32_ComputerSystem
    }
    Else {
        $retCompInfo = Get-CimInstance -ClassName Win32_ComputerSystem
    }
    "Domain: {0}" -f $retCompInfo.Domain | Add-Content -Path $rptFile
    # MSMQ information
    #$scriptBlock = [Scriptblock]::Create($sbMSMQQuery)
    If ($rptRemote){
        $retMSMQ = Invoke-Command -Session $compPSsession -Scriptblock {$sbMSMQQuery}
    }
    Else {
        $retMSMQ = Invoke-Command -Scriptblock {$sbMSMQQuery}
    }
    "Message Queues" | Add-Content -Path $rptFile
    If ($retMSMQ){
        $retMSMQ | Add-Content -Path $rptFile
    }
    Else {
        "`tNo Data Returned" | Add-Content -Path $rptFile
    }
    # Physical Memory Report
    If ($rptRemote){
        $retMemory = Get-CIMInstance -CimSession $compCIMSession -ClassName Win32_PhysicalMemory
    }
    Else {
        $retMemory = Get-CIMInstance -ClassName Win32_PhysicalMemory
    }
    $totalmemory = $retMemory | Measure-Object -Property capacity -Sum
    "Total Physical Memory: {0}GB" -f [Math]::Round(($totalmemory.Sum / 1GB), 2) | Add-Content -Path $rptFile
    # Disk Report
    "Disks" | Add-Content -Path $rptFile
    If ($rptRemote){
        $retDisks = Get-CimInstance -CimSession $compCIMSession -ClassName Win32_LogicalDisk -Filter "DriveType = 3"
    }
    Else {
        $retDisks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3"
    }
    ForEach ($retDisk in $retDisks){
        "`t{0} - {1}GB" -f $retDisk.DeviceID, [Math]::Round(($retDisk.Size / 1GB), 2) | Add-Content -Path $rptFile
    }
    # Services
    If ($rptRemote){
        $retServices = Get-CimInstance -CimSession $compCIMSession -ClassName Win32_Service
    }
    Else {
        $retServices = Get-CimInstance -ClassName Win32_Service
    }
    "Services" | Add-Content -Path $rptFile
    ForEach ($svc in $retServices | select-Object -Property Name, StartName) {
        If ($svc.StartName) {
            "`t{0} - {1}" -f $svc.Name, $svc.startName | Add-Content -Path $rptFile
        }
        Else {
            "`t{0} - No Account Attached" -f $svc.Name | Add-Content -Path $rptFile
        }
    }
    # Data Gathered - Provide Output
    Add-Content -Path $rptFile -Value "-- End of Report --"
    If ($rptEmail){
        Send-rptEmail -emailAttachment $rptFile
    }
    Else {
        # Display in Console
        Get-Content $rptFile
    }
}
END {
    Remove-Variable -Name rpt*, ret*
    remove-item Function:\send-rptemail
    remove-item $rptFile.FullName
    if ($rpRemote){
        Get-CimSession | Remove-CimSession
        Get-PSSession | Remove-PSSession
    }
    [System.GC]::Collect()
}