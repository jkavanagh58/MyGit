$servers = get-adcomputer -Filter {Enabled -eq $True -And OperatingSystem -like "Windows*Server*" -Or OperatingSystem -Like "Hyper-V Server" } -Properties OperatingSystem |
	Sort-Object -Property Name
ForEach ($server in $servers | where Name -like "WFM-*"){
	Try {
		$cimsession = New-CIMSession -Computername $server.name -Credential $admcreds -ErrorAction Stop
		$lastBoot = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $cimsession -Property LastBootUpTime
		"CIM: {0} Last Boot Time: {1}" -f $server.name, $lastBoot.LastBootUpTime
	}
	Catch [Microsoft.Management.Infrastructure.CimException]{
		Try {
			$lastBoot = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $server.name -Credential $admcreds -ErrorAction Stop |
				Select-Object @{N="LastBootupTime"; E={$_.ConvertToDateTime($_.LastBootUpTime)}}
			# Yes I could have used the CIM value for OperatingSystem but this is a quick example
			"WMI: {0} Last Boot Time: {1} - OperatingSystem {2}" -f $server.name, $lastBoot.LastBootUpTime, $server.OperatingSystem
		}
		Catch [System.Runtime.InteropServices.COMException]{
			"WMI: {0} Unable to access WMI - OperatingSystem {1}" -f $server.Name, $server.OperatingSystem
		}
		Catch [System.Management.Automation.ItemNotFoundException]{
			"`tWMI: {0} Host unreachable - OperatingSystem {1}" -f $server.Name, $server.OperatingSystem
			# Include test to resolve Hostname to IP address
		}
		Catch {
			# The catch all, outputting the Error Exception type so that I can add catch statements for them.
			$error[0].Exception.GetType().FullName
		}
	}
	Catch [System.Management.Automation.ItemNotFoundException]{
		"CIM: {0} Host unreachable - OperatingSystem {1}" -f $server.Name, $server.OperatingSystem
		# Include test to resolve Hostname to IP address
	}
	Catch {
		# The catch all, outputting the Error Exception type so that I can add catch statements for them.
		$error[0].Exception.GetType().FullName
	}
	Finally {
		if (get-variable -Name lastboot -ErrorAction SilentlyContinue){
			remove-variable lastboot -erroraction SilentlyContinue
		}
	}
}