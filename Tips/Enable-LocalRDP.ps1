Function Enable-RDPAccess {
[CmdletBinding()]
Param (

)
    # Enable RDP
    $setItemPropertySplat = @{
        Path = 'HKLM:System\CurrentControlSet\Control\Terminal Server'
        Name = "fDenyTSConnections"
        Value = 0
    }
    set-ItemProperty @setItemPropertySplat
    # Open Firewall Rule for Remote Desktop
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    # Enforce Secure Connections
    $setItemPropertySplat = @{
        Path = 'HKLM:System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
        Name = "UserAuthentication"
        Value = 1
    }
    # Adds security level to RDP
    set-ItemProperty @setItemPropertySplat
}
Function Enable-WinHyperV {
[cmdletBinding()]
Param (
    [CIMInstnace]$hdwrCheck
)
    $getCimInstanceSplat = @{
        Property = 'Name', 'SecondLevelAddressTranslationExtensions', 'VirtualizationFirmwareEnabled', 'VMMonitorModeExtensions'
        ClassName = 'win32_processor'
    }
    $hdwrCheck = Get-CimInstance @getCimInstanceSplat
    If ($hdwrCheck.SecondLevelAddressTranslationExtensions){
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    }
    Else {
        Write-Error -Message "Unable to enable Hyper-V; SLAT is not enabled."
        Exit
    }
}