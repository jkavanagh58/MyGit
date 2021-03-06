$VerbosePreference = 'continue'
Function Get-Server {
    $strCategory = "computer"
    $strOS = "Windows*Server*"
    $objSearcher = [adsisearcher]""
    $objSearcher.Filter = ("(&(objectCategory=$strCategory)(OperatingSystem=$strOS))")
    $objSearcher.pagesize = 10
    $objsearcher.sizelimit = 5000
    $objSearcher.PropertiesToLoad.Add("dnshostname") | Out-Null
    $objSearcher.Sort.PropertyName = "dnshostname"
    $colResults = $objSearcher.FindAll()
    foreach ($objResult in $colResults) {
        $objComputer = $objResult.Properties
        $objComputer.dnshostname
    }
}

###User Defined Parameters
Write-Verbose ("[{0}] Reviewing user defined parameters" -f (Get-Date))
#SCOM Management Server
$SCOMMgmtServer = ''
#SCOM RMS Server
$SCOMRMS = 'mn1ops01.corp.swagelok.lan'
#Systems to Exempt from SCOM
$Exempt = ''
$Emailparams = @{
    To = 'SysMon-SCOMAdmins@Swagelok.Com'
    From = 'SCOM-AgentAudit@swagelok.com'
    SMTPServer ='smtp.swagelok.com'
    Subject = "SCOM Agent Audit" 
    BodyAsHTML = $True
}

#Get list of AD Servers
Write-Verbose ("[{0}] Getting list of servers from Active Directory" -f (Get-Date))
$ADServers = Get-Server | Where {$Exempt -NotContains $_}

#Initialize SCOM SnapIn
Write-Verbose ("[{0}] Loading SCOM SnapIn" -f (Get-Date))
Add-PSSnapin Microsoft.EnterpriseManagement.OperationsManager.Client -ErrorAction SilentlyContinue

#Make SCOM Connection
Write-Verbose ("[{0}] Connecting to SCOM RMS Server: {1}" -f (Get-Date),$SCOMRMS)
New-ManagementGroupConnection -ConnectionString $SCOMRMS | Out-Null

#Connect to SCOM Provider
Write-Verbose ("[{0}] Connecting to SCOM Provider" -f (Get-Date))
Push-Location ‘OperationsManagerMonitoring::’
Write-Verbose ("[{0}] Connecting to SCOM Server: {1}" -f (Get-Date),$SCOMMgmtServer)
$MgmtServer = Get-ManagementServer | Where {$_.Name -eq $SCOMMgmtServer}

#Get all SCOM Agent Servers
Write-Verbose ("[{0}] Gathering all SCOM managed systems" -f (Get-Date))
$SCOMServers = Get-Agent | Select -Expand NetworkName | Sort

#Compare list to find servers not in SCOM
Write-Verbose ("[{0}] Filtering out all Non SCOM managed systems to audit" -f (Get-Date))
$NonSCOMTEMP = @(Compare-Object -ReferenceObject $SCOMServers -DifferenceObject $ADServers | Where {
    $_.SideIndicator -eq '=>'
} | Select -Expand Inputobject)

#Attempt to Discover Systems
Write-Verbose ("[{0}] Configuring SCOM discovery prior to use" -f (Get-Date))
$Discover = New-WindowsDiscoveryConfiguration -ComputerName $NonSCOM -PerformVerification -ComputerType "Server"
$Discover.ComputerNameDiscoveryCriteria.getComputernames() | ForEach {Write-Verbose ("{0}: Attempting to discover" -f $_)}
Write-Verbose ("[{0}] Beginning SCOM discovery" -f (Get-Date))
$DiscResults = Start-Discovery -WindowsDiscoveryConfiguration $Discover -ManagementServer $MgmtServer

#Check Alert history for failed Discoveries
Write-Verbose ("[{0}] Checking for failed Discoveries" -f (Get-Date))
$alerts = @(Get-Alert -Criteria "PrincipalName = '$SCOMMgmtServer' AND MonitoringClassId='ab4c891f-3359-3fb6-0704-075fbfe36710'`
AND Name='An error occurred during computer verification from the discovery wizard'") | Where {    
    #Look for unresolved alerts
    $_.ResolutionState -eq 0
}

If ($Alerts.count -gt 0) {
    #Start processing the failed discovery alerts
    $alert = $alerts  | Select -Expand Parameters
    $Pattern = "Machine Name: ((\w+|\.)*)\s"
    $FailedDiscover = $alert | ForEach {    
        $Server = ([regex]::Matches($_,$Pattern))[0].Groups[1].Value
        Try {
            $ServerIP = ([net.dns]::Resolve($Server).AddressList[0])
        } Catch {
            $ServerIP = $Null
        }
        If (-Not ([string]::IsNullOrEmpty($Server))) {
            New-Object PSObject -Property @{
                Server = $Server
                Reason = $_
                IP = $ServerIP
            }
        }
    }
    <#
    Resolve the alerts for failed discoveries, otherwise we will have false positives that there were no failed discoveries.
    #>
    Write-Verbose ("[{0}] Resolving active alerts" -f (Get-Date))
    $Alerts | ForEach {
        Resolve-Alert -Alert $_ | Out-Null
    }
}

#Only push agent out if there is a system that needs it
If ($DiscResults.custommonitoringobjects -gt 0) {
    #Install Agent on Discovered Servers
    Write-Verbose ("[{0}] Beginning installation of SCOM Agent on discovered systems" -f (Get-Date))
    $DiscResults.custommonitoringobjects | ForEach {Write-Verbose ("{0}: Attempting Agent Installation" -f $_.Name)}
    $Results = Install-Agent -ManagementServer $MgmtServer -AgentManagedComputer: $DiscResults.custommonitoringobjects

    #Check for failed installations
    $FailedInstall = @{}
    $SuccessInstall = @{}
    Write-Verbose ("[{0}] Checking for Failed and Successful installations" -f (Get-Date))
    $Results.MonitoringTaskResults | ForEach {

        If (([xml]$_.Output).DataItem.ErrorCode -ne 0) {
            #Failed Installation
            $FailedInstall[([xml]$_.Output).DataItem.PrincipalName] = `
            (([xml]$_.output).DataItem.Description."#cdata-section" -split "\s{2,}")[0]
        } Else {
            #Successful Installation
            $SuccessInstall[([xml]$_.Output).DataItem.PrincipalName] = `
            Get-Date ([xml]$_.output).DataItem.Time
        }
    }
}

$head = @"
<style>
    TABLE{background-color:LightYellow;border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
    TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;}
    TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;}
</style>
"@

If ($SuccessInstall.Count -gt 0) {
Write-Verbose ("[{0}] Adding {1} Successful installations to report" -f $SuccessInstall.Count,(Get-Date))
$html1 = @"
<html>
    <body>
        <h5>
            <font color='white'>
                Please view in html!
            </font>
        </h5>
        <h2> 
            The following servers were found in Active Directory and had the SCOM Agent successfully installed: 
        </h2>
    $($SuccessInstall.GetEnumerator() | Select Name, Value | Sort Name | ConvertTo-HTML -head $head)
    </body>
</html>
"@
} Else {
    $html1 = $Null
}

If ($FailedInstall.Count -gt 0) {
Write-Verbose ("[{0}] Adding {1} Failed installations to report" -f $FailedInstall.Count,(Get-Date))
$html2 = @"
<html>
    <body>
        <h5>
            <font color='white'>
                Please view in html!
            </font>
        </h5>
        <h2> 
            The following servers are Active Directory and were discovered, but Failed to install the SCOM Agent:
        </h2>
    $($FailedInstall.GetEnumerator() | Select Name,Value | Sort Name | ConvertTo-HTML -head $head)
    </body>
</html>
"@
} Else {
    $html2 = $Null
}

If ($FailedDiscover.Count -gt 0) {
Write-Verbose ("[{0}] Adding {1} Failed Discoveries to report" -f $FailedDiscover.Count,(Get-Date))
$html3 = @"
<html>
    <body>
        <h5>
            <font color='white'>
                Please view in html!
            </font>
        </h5>
        <h2> 
            The following servers are Active Directory but Failed to be Discovered by SCOM:
        </h2>
    $($FailedDiscover | Sort Server | ConvertTo-HTML -head $head)
    </body>
</html>
"@
} Else {
    $html3 = $Null
}

If ($html1 -OR $html2 -OR $html3) {
    $Emailparams['Body'] = "$($Html1,$Html2,$Html3)"
} Else {
    $Emailparams['Body'] = @"
<html>
    <body>
        <h5>
            <font color='white'>
                Please view in html!
            </font>
        </h5>
        <h2> 
            All servers in Active Directory are currently being managed by SCOM Agents.
        </h2>
    </body>
</html>
"@
}
Write-Verbose ("[{0}] Sending Audit report to list of recipients." -f (Get-Date))
Send-MailMessage @Emailparams
#Back to starting location
Pop-Location