function Invoke-SCCMSchedule
{
    [CmdletBinding()]
    Param(
        [String]$ComputerName = ".",
        [Parameter(Mandatory = $true)]
        [string]$ScheduleID
    )            

    $ScheduleIds = @{
        HardwareInventory    = "{00000000-0000-0000-0000-000000000001}"; # Hardware Inventory Collection Task             
        SoftwareInventory    = "{00000000-0000-0000-0000-000000000002}"; # Software Inventory Collection Task             
        HeartbeatDiscovery    = "{00000000-0000-0000-0000-000000000003}"; # Heartbeat Discovery Cycle             
        SoftwareInventoryFileCollection    = "{00000000-0000-0000-0000-000000000010}"; # Software Inventory File Collection Task             
        RequestMachinePolicy    = "{00000000-0000-0000-0000-000000000021}"; # Request Machine Policy Assignments             
        EvaluateMachinePolicy    = "{00000000-0000-0000-0000-000000000022}"; # Evaluate Machine Policy Assignments             
        RefreshDefaultMp    = "{00000000-0000-0000-0000-000000000023}"; # Refresh Default MP Task             
        RefreshLocationServices    = "{00000000-0000-0000-0000-000000000024}"; # Refresh Location Services Task             
        LocationServicesCleanup    = "{00000000-0000-0000-0000-000000000025}"; # Location Services Cleanup Task             
        SoftwareMeteringReport    = "{00000000-0000-0000-0000-000000000031}"; # Software Metering Report Cycle             
        SourceUpdate            = "{00000000-0000-0000-0000-000000000032}"; # Source Update Manage Update Cycle             
        PolicyAgentCleanup        = "{00000000-0000-0000-0000-000000000040}"; # Policy Agent Cleanup Cycle             
        RequestMachinePolicy2    = "{00000000-0000-0000-0000-000000000042}"; # Request Machine Policy Assignments             
        CertificateMaintenance    = "{00000000-0000-0000-0000-000000000051}"; # Certificate Maintenance Cycle             
        PeerDistributionPointStatus    = "{00000000-0000-0000-0000-000000000061}"; # Peer Distribution Point Status Task             
        PeerDistributionPointProvisioning    = "{00000000-0000-0000-0000-000000000062}"; # Peer Distribution Point Provisioning Status Task             
        ComplianceIntervalEnforcement    = "{00000000-0000-0000-0000-000000000071}"; # Compliance Interval Enforcement             
        SoftwareUpdatesAgentAssignmentEvaluation    = "{00000000-0000-0000-0000-000000000108}"; # Software Updates Agent Assignment Evaluation Cycle             
        UploadStateMessage    = "{00000000-0000-0000-0000-000000000111}"; # Send Unsent State Messages             
        StateMessageManager    = "{00000000-0000-0000-0000-000000000112}"; # State Message Manager Task             
        SoftwareUpdatesScan    = "{00000000-0000-0000-0000-000000000113}"; # Force Update Scan            
        AMTProvisionCycle    = "{00000000-0000-0000-0000-000000000120}"; # AMT Provision Cycle            
    }

    if(Test-Connection -Computer $ComputerName) {
        Try {
            $SmsClient = [wmiclass]"\\$ComputerName\root\ccm:SMS_Client"
            $SmsClient.TriggerSchedule($ScheduleIds.$ScheduleID)
          }
        Catch {
            Write-Host "Trigger Schedule Method failed" -ForegroundColor RED
        }
    }
    else {
        Write-Host "Computer may be offline or please check Windows Firewall settings" -ForegroundColor Red
    }

}# End of Function Invoke-SCCMSchedule
#Invoke-SCCMSchedule "sw5779" SoftwareInventory
#Sleep 10
#Invoke-SCCMSchedule "sw9709" RequestMachinePolicy
Invoke-SCCMSchedule "sw9709" SoftwareUpdatesScan
# SIG # Begin signature block
# MIIEJQYJKoZIhvcNAQcCoIIEFjCCBBICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMUEdzjXGAzHETWO8XNVI2Ja6
# 6kWgggI5MIICNTCCAZ6gAwIBAgIQGq1CBDjqRrBNCLQW3sYq4jANBgkqhkiG9w0B
# AQUFADAiMSAwHgYDVQQDExdLYXZhbmFnaCAtIENvZGUgU2lnbmluZzAeFw0xMjAx
# MDEwNDAwMDBaFw0xODAxMDEwNDAwMDBaMCIxIDAeBgNVBAMTF0thdmFuYWdoIC0g
# Q29kZSBTaWduaW5nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDdu7E99Cy9
# dlw4zluinlt2/r0ykhDj/ESaCxvKVgQED5tWut7C93BP0lKyW+2ViiRhhakqEVhL
# 0IhMhoeiAo7rQF0gk6vcxmaoVGOUWl9E1u0PzmBaAXrklDqeGuStm58mGm4B9E/O
# TLvVsd7eo/oCpvQsfk99ob1doMfDh+0ZdQIDAQABo2wwajATBgNVHSUEDDAKBggr
# BgEFBQcDAzBTBgNVHQEETDBKgBClD17LyCFrvK2jan5T6A2OoSQwIjEgMB4GA1UE
# AxMXS2F2YW5hZ2ggLSBDb2RlIFNpZ25pbmeCEBqtQgQ46kawTQi0Ft7GKuIwDQYJ
# KoZIhvcNAQEFBQADgYEAsVWgTlRIgfu7uYMhujAE7pWI7uMhjmtk5l4jdxQN168O
# Er0DIg/7RFnIU+XXixENL4JPpHBahheLe0RsVTnW2OrZOZUTKLHLsjo/bKjSjbtQ
# SJKq+jrYcTY5hTl1CQEeim39k2hpxqSl+GQdWOwtynEKLIAHWIW+uYDFfH/FKokx
# ggFWMIIBUgIBATA2MCIxIDAeBgNVBAMTF0thdmFuYWdoIC0gQ29kZSBTaWduaW5n
# AhAarUIEOOpGsE0ItBbexiriMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQow
# CKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcC
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSLUXIR1vkZEEONn0Ja
# sG9XfiEmXjANBgkqhkiG9w0BAQEFAASBgLxWBAVS7zdXjZa/bHw3K9PKjBkaKjlM
# prxaYX9r7RCaeG7r0v1IMsMtvuSH73ASbweg0TZxwTaJ/WeF5y7X/CIcqcHnzpDM
# hDAhWAUvBPPXuH5pXOMxx38PGPVHWN/dwB8twpgRrqyixMXEN10zsxJQgqa1mbat
# UPLAkqb2Uziz
# SIG # End signature block
