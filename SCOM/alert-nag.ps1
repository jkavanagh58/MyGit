$oldAlerts = Get-Alert | Where-Object {($_.LastModified -ge [DateTime]::Now.AddHours(-4)) -and ($_.ResolutionState -eq 0)}
ForEach($alert in $oldAlerts) {
    $alert.Update("")
}