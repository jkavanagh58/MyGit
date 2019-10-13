<#
    Simple example of how Try/Catch can be error specific and provide issue workarounds
    not just error notification
    .LINK http://tinyurl.com/ya3wcmqz
        HowTo: For finding the Exception type used to filter the catch statements
#>

# Download the 1.0 release of the VMware.vSphereDSC module from GitHub
Try {
    Invoke-WebRequest -Uri 'https://github.com/vmware/dscr-for-vmware/releases/download/v1.0/VMware.vSphereDSC.zip' -OutFile $env:userprofile\Downloads\VMware.vSphereDSC.zip
}
Catch [System.Net.WebException] {
    Write-Error -Message "WebException error; attempting Protocol TLS1.2" -ErrorAction Continue
    # On error, the SecurityProtocol for the local PowerShell session will be updated to access TLS 1.2 and the download will be attempted again.
    $secProtocol = [Net.ServicePointManager]::SecurityProtocol
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri 'https://github.com/vmware/dscr-for-vmware/releases/download/v1.0/VMware.vSphereDSC.zip' -OutFile $env:userprofile\Downloads\VMware.vSphereDSC.zip
    # The SecurityProtocol will be then reverted back to the state it was at prior
    [Net.ServicePointManager]::SecurityProtocol = $secProtocol
}
Catch {
    Write-Error -Message "You can not download this file" -ErrorAction Continue
    $error[0].Exception.Message
}
