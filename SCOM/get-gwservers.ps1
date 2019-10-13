<#
.SYNOPSIS
   Report: Gateway Management Server
.DESCRIPTION
   Uses OpsMgr Shell to list gateway servers and their Primary Management
   Server and Fail Over server.
.EXAMPLE
   S:\SysMgmt\Scripts\Powershell\SCOM\get-gwservers.ps1
#>

$gws=Get-ManagementServer | ? {$_.IsGateway} | sort name
"There are $($gws.count) gateway servers"
foreach ($gw in $gws){
	$gw.Name
	$pri = Get-primaryManagementserver -gatewaymanagementserver $gw | select Name
	$sec = Get-FailoverManagementServer -GatewayManagementServer $gw | Select Name
	"`tPrimary: $($pri.name)"
	"`tFailOver: $($sec.name)"
	"`r"
}
# SIG # Begin signature block
# MIIEFQYJKoZIhvcNAQcCoIIEBjCCBAICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4T/mVJ22RqCphNBSCs5N11tz
# lRegggItMIICKTCCAZKgAwIBAgIQrOfUqrQ+kKREeKyDkz+mwDANBgkqhkiG9w0B
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
# ARUwIwYJKoZIhvcNAQkEMRYEFJKeXufadqRj29FP/1mD6WVMR1UoMA0GCSqGSIb3
# DQEBAQUABIGAeD4QtVzI6/5nuy8h7iOMumVyRPAwPmTZ19hfl9eU+n1ZxPpyOoEP
# wRl/hnS+A+BXKygHDvTAkXKyospJ6bHqKw+hZCsgor3Rsm0dmaIGn2UcftAW7hzh
# HzJDhZvP5iaNCvlKzT4Qjjh4Rl/Pqla4VmUbRb40G/ySPFDLT6FgaXQ=
# SIG # End signature block
