<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>
# Establish Gateway Connections
$dmz1=Get-ManagementServer | ? {$_.Name -eq 'dmz25.dmz.swagelok.com'}
$dmz2=Get-ManagementServer | ? {$_.Name -eq 'dmz27.dmz.swagelok.com'}
$sap1=Get-ManagementServer | ? {$_.Name -eq 'IS1OPS06.sap.swagelok.lan'}
$sap2=Get-ManagementServer | ? {$_.Name -eq 'IS1OPS07.sap.swagelok.lan'}
$sc1=Get-ManagementServer | ? {$_.Name -eq 'SC1OPS01.scs.swagelok.com'}
$sc2=Get-ManagementServer | ? {$_.Name -eq 'SC1OPS02.scs.swagelok.com'}
$inf1=Get-ManagementServer | ? {$_.Name -eq 'IS1OPS04.swagelok.com'}
$inf2=Get-ManagementServer | ? {$_.Name -eq 'IS1OPS05.swagelok.com'}
$mn1=Get-ManagementServer | ? {$_.Name -eq 'MN1OPS01.corp.swagelok.lan'}
$mn2=Get-ManagementServer | ? {$_.Name -eq 'MN1OPS02.corp.swagelok.lan'}
# Gather all agent machines
$agents=Get-Agent | sort Name
# Process all agents returned
foreach ($ag in $agents){
	$secondary=$ag.getFailOverManagementServers()
	$curmaster=$ag.PrimaryManagementServerName
	if($secondary.count -ne 1){
		# Process agents that have no failover server defined
		switch ($ag.PrimaryManagementServerName)
		{
			'mn1ops01.corp.swagelok.lan' 	{"`tSet failover to ops02 for $($ag.name) "
											Set-ManagementServer -AgentManagedComputer $ag `
											-PrimaryManagementServer $mn1 `
											-FailoverServer $mn2
											}
			'mn1ops02.corp.swagelok.lan' 	{"`tSet failover to ops01 for $($ag.name) "
											Set-ManagementServer -AgentManagedComputer $ag `
											-PrimaryManagementServer $mn2 `
											-FailoverServer $mn1
											}
			'sc1ops01.scs.swagelok.com'		{"`tSet failover to ops02 for $($ag.name) "
											Set-ManagementServer -AgentManagedComputer $ag `
											-PrimaryManagementServer $sc1 `
											-FailoverServer $sc2
											}
			'sc1ops02.scs.swagelok.com'		{"`tSet failover to ops01 for $($ag.name) "
											Set-ManagementServer -AgentManagedComputer $ag `
											-PrimaryManagementServer $sc2 `
											-FailoverServer $sc1
											}
			'is1ops04.swagelok.com'			{"`tSet failover to ops05 for $($ag.name) "
											Set-ManagementServer -AgentManagedComputer $ag `
											-PrimaryManagementServer $inf1 `
											-FailoverServer $inf2
											}
			'is1ops05.swagelok.com'			{"`tSet failover to ops04 for $($ag.name) "
											Set-ManagementServer -AgentManagedComputer $ag `
											-PrimaryManagementServer $inf2 `
											-FailoverServer $inf1
											}
			'is1ops06.sap.swagelok.lan' 	{"`tSet failover to ops07 for $($ag.name) "
											Set-ManagementServer -AgentManagedComputer $ag `
											-PrimaryManagementServer $sap1 `
											-FailoverServer $sap2
											}
			'is1ops07.sap.swagelok.lan'		{"`tSet failover to ops06 for $($ag.name) "
											Set-ManagementServer -AgentManagedComputer $ag `
											-PrimaryManagementServer $sap2 `
											-FailoverServer $sap1
											}
			'dmz25.dmz.swagelok.com'		{"`tSet failover to dmz27 for $($ag.name) "
											Set-ManagementServer -AgentManagedComputer $ag `
											-PrimaryManagementServer $dmz1 `
											-FailoverServer $dmz2
											}
			'dmz27.dmz.swagelok.com'		{"`tSet failover to dmz25 for $($ag.name) "
											Set-ManagementServer -AgentManagedComputer $ag `
											-PrimaryManagementServer $dmz2 `
											-FailoverServer $dmz1
											}
			default 						{"`tMissing failover config for $($ag.name) "}
		}
	}
}
# SIG # Begin signature block
# MIIEFQYJKoZIhvcNAQcCoIIEBjCCBAICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUy7zVxn4pigUwcnBdfTwfXy0J
# mImgggItMIICKTCCAZKgAwIBAgIQrOfUqrQ+kKREeKyDkz+mwDANBgkqhkiG9w0B
# AQUFADAeMRwwGgYDVQQDExNzcnZqa2F2YSAtIFN3YWdlbG9rMB4XDTExMDEwMTA1
# MDAwMFoXDTE3MDEwMTA1MDAwMFowHjEcMBoGA1UEAxMTc3J2amthdmEgLSBTd2Fn
# ZWxvazCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAx46O2ULyLzX+7mnFZIsT
# 3NKk2WT8+arh4lm/DE3p1+j1jFD7t5F3Xq+5Wp3iOnjWxrfB5n5hkxol5jPp0jTV
# Gt+GCYd3B1K8K0ot3eq5t3EzZY25hJV5RP8nLux2PZ4Zv5XtwOxumdzgBcw4TNDK
# NmlVl4J1WBI2rQZdHpAju2sCAwEAAaNoMGYwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# TwYDVR0BBEgwRoAQ4S1RzNj3oK1AFF68rJJk7KEgMB4xHDAaBgNVBAMTE3Nydmpr
# YXZhIC0gU3dhZ2Vsb2uCEKzn1Kq0PpCkRHisg5M/psAwDQYJKoZIhvcNAQEFBQAD
# gYEAJ3RLTpu5MSHZ5v6S3ryk9/0tBtrr+8vyJvttZKONJ/0bavOiydSLFrXe6dIq
# 7rkZX0ync00P41J/HyCziQ/06RDCb3FAXj7wt62/FIoIGKB7vlHQZ2ZwcoRx309q
# sm8vYDRD7mfVmqB08OrTwihVnyy948OcYsJFgKrX4DLn8lUxggFSMIIBTgIBATAy
# MB4xHDAaBgNVBAMTE3NydmprYXZhIC0gU3dhZ2Vsb2sCEKzn1Kq0PpCkRHisg5M/
# psAwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZI
# hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
# ARUwIwYJKoZIhvcNAQkEMRYEFIM1FTsbMNSB7WZwO0txUGkcC2OxMA0GCSqGSIb3
# DQEBAQUABIGAAR7fu2pLp+DdottUs27ZmzPth3ax2E6N4qMsIzrG6Ubda0tITh/R
# +dX6pj0l75K3qmspD/AML2DHZw+J+77gtwWtHtTTeig3bxJM3DkYtiRuTNxAJ4N5
# iC8zq5leysBtOnYhVbDHcMndp2GVoEmlNQJ8wfTXsB5aWQ8lkNT7BuI=
# SIG # End signature block
