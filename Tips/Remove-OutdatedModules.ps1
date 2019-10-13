#Requires -RunAsAdministrator
Param (
    [parameter(Mandatory=$False, ValueFromPipeline=$True,
        HelpMessage = "Name of PowerShell Module")]
    [ValidateScript({Get-InstalledModule -Name $_ })] 
    [System.String]$modRequested,
    [System.Array]$modInventory,
    [System.Array]$modOutDated
)
Function Remove-ModuleVersions {
    [CmdletBinding()]
    param(
        $moduleInformation
    )
    $modLatestVersion = $moduleInformation | Measure-Object -Property Version -Maximum
    #"Current baseline for {0} is {1}" -f $moduleName, $modLatestVersion.Maximum
    $modOutdated = $modInventory.Where{$_.Version -lt $modLatestVersion.Maximum}
    If ($modOutdated){
        ForEach ($modCurrent in $modOutdated){
            "Removing Module {0} at Version Level {1}" -f $modCurrent.Name, $modCurrent.Version
            Try {
                $modCurrent | Uninstall-Module -WhatIf
            }
            Catch {
                "Unable to remove Version {0}" -f $modCurrent
                $Error[0].Exception.Message
            }
        }
    }
    Else {
        "Nothing to see here"
    }
}
$modInventory = get-installedmodule -Name Pester -allVersions
If ($modInventory.Count){
    "Cleaning up {0} older versions of {1}" -f $modInventory.Count, ($modInventory | select-object -Property Name -Unique).Name
    Remove-ModuleVersions -moduleInformation $modInventory
}
Else {
    "There is only one version of {0} installed" -f ($modInventory | select-object -Property Name -Unique).Name
}