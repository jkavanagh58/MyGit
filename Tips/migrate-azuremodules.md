<h1> Migrate to AZ Module
	
<h2> Purpose
	AZ is the Azure module for cross-platform compatability. In short this version will work with PowerShell 5.x as well as PowerShell Core

<h2> Plan
Uninstall AzureRM module(s). Install module AZ. Uninstalling a module requires certain parameters which might not be clear at first.
    
```powershell
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
```
This is the code being used to ensure all remnants of AzureRM is removed from a computer.
<!-- toc -->



<!-- tocstop -->
	
	