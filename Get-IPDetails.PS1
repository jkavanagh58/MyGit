Function Get-IPDetails {

[cmdletbinding()]            
param (            
 [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]            
    [string[]]$ComputerName = $env:computername            
)                        
            
begin {
 $Report = @()  # Array to collect data and produce cumulative report
}            
process {            
 $Report = @()
 foreach ($Computer in $ComputerName) {            
  if(Test-Connection -ComputerName $Computer -Count 1 -ea 0) {            
   try {            
    $Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer -EA Stop | ? {$_.IPEnabled}            
   } catch {            
        Write-Warning "Error occurred while querying $computer."            
        Continue            
   }            
   foreach ($Network in $Networks) {            
        # Added this to not run on nics with not Gateway.  Several servers do this on backup network
        # need to figure out how to find the major production nic
        If ($Network.DefaultIPGateway -ne $null) {
            $IPAddress  = $Network.IpAddress[0]            
            $SubnetMask  = $Network.IPSubnet[0]            
            $DefaultGateway = $Network.DefaultIPGateway
            $DNSServer1 = $Network.DNSServerSearchOrder[0] 
            $DNSServer2 = $Network.DNSServerSearchOrder[1]
            $DNSServer3 = $Network.DNSServerSearchOrder[2]
            $IsDHCPEnabled = $false            
                If($network.DHCPEnabled) {            
                $IsDHCPEnabled = $true            
                }            
            $MACAddress  = $Network.MACAddress
        }           
    $OutputObj  = New-Object -Type PSObject            
    $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.ToUpper()            
    $OutputObj | Add-Member -MemberType NoteProperty -Name IPAddress -Value $IPAddress            
    #$OutputObj | Add-Member -MemberType NoteProperty -Name SubnetMask -Value $SubnetMask            
    #$OutputObj | Add-Member -MemberType NoteProperty -Name Gateway -Value $DefaultGateway            
    #$OutputObj | Add-Member -MemberType NoteProperty -Name IsDHCPEnabled -Value $IsDHCPEnabled            
    $OutputObj | Add-Member -MemberType NoteProperty -Name DNSServer1 -Value $DNSServer1      
    $OutputObj | Add-Member -MemberType NoteProperty -Name DNSServer2 -Value $DNSServer2            
    $OutputObj | Add-Member -MemberType NoteProperty -Name DNSServer3 -Value $DNSServer3            
    #$OutputObj | Add-Member -MemberType NoteProperty -Name MACAddress -Value $MACAddress            
    #$OutputObj 
   } 
   $OutputObj | export-csv C:\etc\srv03s.csv -NoTypeInformation -Append
   $Report += $OutputObj        
  }            
 }
 $Report            
}  
      
            
end {}
}

(Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*' -and Name -Like 'SSDSRV*'}).name  | sort -Property $_.name | Get-IPDetails | ft -AutoSize

#PS C:\etc\Scripts\Server> (Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*' } -Properties OperatingSystem).name 
#Get-IPDetails ssdsrv04
