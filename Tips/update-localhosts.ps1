$hostSource = "$env:SystemRoot\System32\drivers\etc\hosts"
$localHosts = @("machine1", "machine2", "machine3")
ForEach ($node in $localHosts) {
    If (Test-Connection -ComputerName $node -Count 3 -Quiet){
        Try {
            $copyItemSplat = @{
                Destination = "\\$node\c$\windows\system32\drivers\etc"
                Path        = $hostSource
                Force       = $true
                ErrorAction = 'Stop'
            }
            Copy-Item @copyItemSplat
            "$node hosts file updated"
        }
        Catch {
            Write-Error -Message "Unable to copy updated hosts file to $node"

        }
    }
    Else {
        "$node could not be reached"
    }
}