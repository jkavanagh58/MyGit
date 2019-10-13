connect-toscom
$Report = @()
$groups = get-MonitoringObjectGroup
$groups.count
$sqlgrps = "SW - SIS INT Dev", "SW - SIS INT Prod", "SW - SIS INT QA"
ForEach ($sql in $sqlgrps){
    "Looking at $sql"
    $Group = $Groups | where {$_.DisplayName -eq $sql} 
    $Members = $Group.GetRelatedMonitoringObjects()
    # $Members  | select DisplayName, HealthState
    ForEach ($mbr in $Members){   
       $mbrdat = New-Object PSObject # Object to store data for collation
       Add-Member -InputObject $mbrdat -MemberType NoteProperty -Name "Group" -Value $sql
       Add-Member -InputObject $mbrdat -MemberType NoteProperty -Name "Server" -Value $mbr.DisplayName
       Add-Member -InputObject $mbrdat -MemberType NoteProperty -Name "Description" -Value $mbr.FullName
       Add-Member -InputObject $mbrdat -MemberType NoteProperty -Name "HealthState" -Value $mbr.HealthState
       $Report += $mbrdat
    }
}
"Done"