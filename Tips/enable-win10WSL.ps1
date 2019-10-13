#Requires -RunAsAdministrator
[CmdletBinding()]
Param (
    [System.String]$procFeatureName = "Microsoft-Windows-Subsystem-Linux"
)
If (!(Get-WindowsOptionalFeature -online -Featurename $procFeatureName)){
    "Enabling $($procFeatureName)"
    #Enable-WindowsOptionalFeature -Online -FeatureName $procFeatureName
}