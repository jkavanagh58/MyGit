<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
.NOTES
    01.20.2012:  Fixed issue with dmz server names. JJK
#>
Function Set-agentServerConfig {
param(
    $agent,
    $priServer,
    $failServer
)
    "Setting Primary server for $($agent.name)"
    Set-SCOMParentManagementServer -Agent $agent -PrimaryServer $priServer
    "Setting Failover server for $($agent.name)"
    Set-SCOMParentManagementServer -Agent $agent -FailoverServer $failServer
}
# Establish Gateway Connections
$dmz1 = Get-SCOMGatewayManagementServer | ? {$_.Name -eq 'dmz025.dmz.swagelok.com'}
$dmz2 = Get-SCOMGatewayManagementServer | ? {$_.Name -eq 'dmz027.dmz.swagelok.com'}
$sap1 = Get-SCOMGatewayManagementServer | ? {$_.Name -eq 'IS1OPS06.sap.swagelok.lan'}
$sap2 = Get-SCOMGatewayManagementServer | ? {$_.Name -eq 'IS1OPS07.sap.swagelok.lan'}
$sc1  = Get-SCOMGatewayManagementServer | ? {$_.Name -eq 'SC1OPS01.scs.swagelok.com'}
$sc2  = Get-SCOMGatewayManagementServer | ? {$_.Name -eq 'SC1OPS02.scs.swagelok.com'}
$inf1 = Get-SCOMGatewayManagementServer | ? {$_.Name -eq 'IS1OPS04.swagelok.com'}
$inf2 = Get-SCOMGatewayManagementServer | ? {$_.Name -eq 'IS1OPS05.swagelok.com'}
$mn1  = Get-SCOMGatewayManagementServer | ? {$_.Name -eq 'mn1ops08.swagelok.com'}
$mn2  = Get-SCOMGatewayManagementServer | ? {$_.Name -eq 'mn1ops09.swagelok.com'}
# Gather all agent machines
$agents=Get-SCOMAgent | Sort-Object -Property  Name
# Process all agents returned
foreach ($ag in $agents){
	$secondary=$ag.getFailOverManagementServers()
	$curmaster=$ag.PrimaryManagementServerName
	if($secondary.count -ne 1 -and $ag.HealthState -eq 'Success'){
		# Process agents that have no failover server defined
		switch ($ag.PrimaryManagementServerName)
		{
			'sc1ops01.scs.swagelok.com'		{"`tSet failover to ops02 for $($ag.name) "
											    Set-agentServerConfig -agent $ag -priServer $sc1 -failServer $sc2 
											}
			'sc1ops02.scs.swagelok.com'		{"`tSet failover to ops01 for $($ag.name) "
                                                Set-agentServerConfig -agent $ag -priServer $sc2 -failServer $sc1 
											}
			'is1ops04.swagelok.com'			{"`tSet failover to ops05 for $($ag.name) "
											    Set-agentServerConfig -agent $ag -priServer $inf1 -failServer $inf2 
                                            }
			'is1ops05.swagelok.com'			{"`tSet failover to ops04 for $($ag.name) "
                                                Set-agentServerConfig -agent $ag -priServer $inf2 -failServer $inf1
											}
			'is1ops06.sap.swagelok.lan' 	{"`tSet failover to ops07 for $($ag.name) "
											    Set-agentServerConfig -agent $ag -priServer $sap1 -failServer $sap2
											}
			'is1ops07.sap.swagelok.lan'		{"`tSet failover to ops06 for $($ag.name) "
                                                Set-agentServerConfig -agent $ag -priServer $sap2 -failServer $sap1
											}
			'dmz025.dmz.swagelok.com'		{"`tSet failover to dmz27 for $($ag.name) "
											    Set-agentServerConfig -agent $ag -priServer $dmz1 -failServer $dmz2
											}
			'dmz027.dmz.swagelok.com'		{"`tSet failover to dmz25 for $($ag.name) "
											    Set-agentServerConfig -agent $ag -priServer $dmz2 -failServer $dmz1
                                            }
            'mn1ops08.swagelok.com' 		{"`tSet failover to ops08 for $($ag.name) "
											    Set-agentServerConfig -agent $ag -priServer $dmz1 -failServer $dmz2
											}
			'mn1ops09.swagelok.com' 		{"`tSet failover to ops09 for $($ag.name) "
											    Set-agentServerConfig -agent $ag -priServer $dmz2 -failServer $dmz1
                                            }
			default 						{"`tMissing failover config for $($ag.name) "}
		}
	}
}
