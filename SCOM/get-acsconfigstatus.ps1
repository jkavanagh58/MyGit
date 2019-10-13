connect-toscom
$srvs = get-agent | ? {$_.Domain -eq 'INFONET'} | sort Name
ForEach ($srv in $srvs){
$machine=$srv.name
if (test-connection -computername $machine -Count 1 -Quiet -Erroraction SilentlyContinue){
# Server online, let's check the service
    $svcdat = gwmi win32_service -Filter "Name = 'AdtAgent'" -ComputerName $machine -erroraction SilentlyContinue | select status
    if ($svcdat){
        "$machine shows AdtAgent is currently $($svcdat.status)"
    } 
    Else {
        "$machine does not appear to be configured for ACS"
    }
}
Else { #Server not online
    "$machine not responding"
} # Finish processing online status

} # End ForEach loop