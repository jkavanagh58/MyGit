<link href="/md.css" rel="stylesheet"></link>

# Delta Process

![progress](http://progressed.io/bar/75?title=Research)

## Overview

Prior to patching synch the CCM collections with their corresponding SCOM Group. This would allow changes to computers included in CCM Maintenance windows.

## Progress

Script to query CCM and SCOM - at issue is how to match data object types. Since we have added all objects associated with the computer object there are objects that cannot be matched up to the CCM Member collection.

```
$SCGrpMembers = Invoke-Command -Session $OpsMgr -ScriptBlock{get-SCOMGroup -DisplayName $using:SCGrpName | Get-SCOMClassInstance}
$SCGrpMembers | select DisplayName, ID
```

`Example: RDC-VCOLLECT-03 (Replication...`

- Working on a method to normalize data for compare against CCM members
- Performance might be an issue
- 07.06.2017 JJK: Remove process not working despite changes being recorded in EventLog
- 07.06.2017 JJK: works if not splatted

## Alternate Concept

Perform a complete **Instances Remove** prior to previously developed script.

- Will make it a single process
- The ID value returned from previous posted code segment will be used to create an array of Instances to remove via modifygroupmembership.p1 in the same manner we create the array for InstancesToAdd
- Place the remove process in a seperate function for easy debugging.

### Flow

1. Collect members of CCM group
2. Collect all instances of corresponding SCOM Group
3. Call modifygroupmembership.ps1 with InstancesToRemove use data from previous step for Instances to remove
4. Call ModifygroupMembership.ps1 with InstancesToAdd with CCM member (computer object) and all related objects

### Notes

| Date     | Note |
| -- |:--|
|07.13.2017| new runs of comprehensive script
|07.14.2017| modified try/catch since logging was not occurring
|07.14.2017| Worked with issue updating Thursday EDW group... was able to run manually
