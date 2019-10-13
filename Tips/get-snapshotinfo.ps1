$Report = @()
foreach ($snap in Get-VM | Get-Snapshot | Where-Object {((get-date) - $_.Created).TotalDays -gt 30}) {
    # Not Current 
    $snapInfo = [PSCustomObject]@{
        VM          = $snap.VM.Name
        Host        = $snap.VM.VMHost
        Description = $snap.Description
        Created     = $snap.Created
        "Size(GB)"  = [Math]::Round($snap.SizeGB, 4)
    }
    $Report += $snapinfo
    $snapevent = Get-VIEvent -Entity $snap.VM -Types Info -Finish $snap.Created -MaxSamples 1 | Where-Object {$_.FullFormattedMessage -imatch 'Task: Create virtual machine snapshot'}
    $snapevent
    #if ($snapevent -ne $null) {Write-Host ( "VM: " + $snap.VM + ". Snapshot '" + $snap + "' created on " + $snap.Created.DateTime + " by " + $snapevent.UserName + ".")}
    #else {Write-Host ("VM: " + $snap.VM + ". Snapshot '" + $snap + "' created on " + $snap.Created.DateTime + ". This event is not in vCenter events database")}
}
$Report
