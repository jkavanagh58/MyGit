function GetDisplayName($object){
     $displayName = [System.String]::Empty
     if(($object.DisplayName -eq $null) -or ($object.DisplayName.Length -eq 0)){
           $displayName = $object.Name
     }
     else {
           $displayName = $object.DisplayName
     }
     $displayName
}
$mg = (Get-ManagementGroupConnection).ManagementGroup
$groups = $mg.GetRootPartialMonitoringObjectGroups() | sort DisplayName
foreach($group in $groups) {
     $group.DisplayName
     $groupMembers = $group.GetRelatedPartialMonitoringObjects([Microsoft.EnterpriseManagement.Common.TraversalDepth]::OneLevel);
     if($groupMembers.Count -eq 0) {
           "The group is empty"
     }
     else {
            $groupMembers | Select-Object DisplayName,Path,@{name="Type";expression={foreach-object {GetDisplayName $_.GetLeastDerivedNonAbstractMonitoringClass()}}} | sort DisplayName | ft
            $FileName = $group.DisplayName
            $FileName += ".csv"
            $OutPath = $FileName
            $groupMembers | Export-Csv -Path $OutPath -NoTypeInformation
     }
}
