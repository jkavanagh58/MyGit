#Requires -RunAsAdministrator
[Int32]$procErrors
if (get-installedmodule -Name AzureRM -ErrorAction SilentlyContinue){
    # Uninstall AzureRM Modules
    $modList = Get-InstalledModule -Name AzureRM*
    ForEach ($mod in $modList){
        Try {
            Uninstall-Module -Name $mod.Name -AllVersions -Confirm:$false -Force
            "`t{0} Uninstalled" -f $mod.Name
        }
        Catch {
            $procErrors++
            "`tUnable to uninstall {0}" -f $mod.Name
        }
    }
    # These modules also get installed with AzureRM
    If (get-installedmodule -Name Azure.Storage -ErrorAction SilentlyContinue){
        Try {
            Uninstall-Module -Name Azure.Storage -AllVersions -Confirm:$false -Force
            "`tAzure.Storage Uninstalled"
        }
        Catch {
            "`tUnable to uninstall Azure.Storage"
            $procErrors++
        }
    }
    If (get-installedmodule -Name Azure.AnalysisServices -ErrorAction SilentlyContinue){
        Try {
            Uninstall-Module -Name Azure.AnalysisServices -AllVersions -Confirm:$false -Force
            "`tAzure.AnalysisServices Uninstalled"
        }
        Catch {
            "`tUnable to uninstall Azure.AnalysisServices"
            $procErrors++
        }
    }
}
If ($procErrors -ge 1){
    Write-Error "There were issues removing AzureRM, until this is resolved the process cannot continue"
}
Else {
    Install-Module -Name AZ -Scope AllUsers -Confirm:$false -Force
    # Needs testing - should be elevated
    pwsh -Command {Install-Module -Name AZ -Confirm:$false -Force}
}