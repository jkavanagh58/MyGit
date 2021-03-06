#=============================================================================#
#                                                                             #
# Install-SCOMSnapIn.ps1                                                      #
# Powershell Script to install Operations Management Server SnapIn            #
# Author: Jeremy Engel                                                        #
# Date: 04.13.2011                                                            #
# Version: 1.1.0                                                              #
#                                                                             #
#=============================================================================#

Param([Parameter(Mandatory = $true)]$Computer,
      [Parameter(Mandatory = $true)]$ManagementServer
      )

$fileRepository = "\\$ManagementServer\c$\Program Files\System Center Operations Manager 2007"
$rootPath = "C:\Program Files\System Center Operations Manager 2007\SnapIn"

$files = @("Microsoft.EnterpriseManagement.OperationsManager.ClientShell.dll",
           "Microsoft.EnterpriseManagement.OperationsManager.ClientShell.dll-help.xml",
           "Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Format.ps1xml",
           "Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Types.ps1xml"
           )
$sdkfiles = @("Microsoft.EnterpriseManagement.OperationsManager.Common.dll",
              "Microsoft.EnterpriseManagement.OperationsManager.dll"
              )

function Main {
  $remotePath = $rootPath.Replace("C:","\\$Computer\c$")
  if(!(Test-Path $remotePath)) { $null = New-Item $remotePath -Type Directory }
  foreach($file in $files) { 
    if(!(Test-Path "$remotePath\$file")) { 
      Copy-Item -Path "$fileRepository\$file" -Destination $remotePath
      }
    }
  foreach($file in $sdkfiles) {
    if(!(Test-Path "$remotePath\$file")) {
      Copy-Item -Path "$fileRepository\SDK Binaries\$file" -Destination $remotePath
      }
    }
  $hklm = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Computer)
  $scom = $hklm.CreateSubKey("SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\Microsoft.EnterpriseManagement.OperationsManager.Client")
  $scom.SetValue("ApplicationBase",$rootPath,"String")
  $scom.SetValue("AssemblyName","Microsoft.EnterpriseManagement.OperationsManager.ClientShell, Version=6.0.4900.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35","String")
  $scom.SetValue("ModuleName","$rootPath\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.dll","String")
  $scom.SetValue("PowerShellVersion","1.0","String")
  $scom.SetValue("Vendor","Microsoft Corporation","String")
  $scom.SetValue("Version","6.0.4900.0","String")
  $scom.SetValue("Description","Microsoft Operations Manager Shell Snapin","String")
  $scom.SetValue("Types","$rootPath\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Types.ps1xml","String")
  $scom.SetValue("Formats","$rootPath\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Format.ps1xml","String")
  }

Main
