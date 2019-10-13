# Documenting how to use ModifyGroupMembership script to work with SCOM Groups
# Link http://systemcentermvp.com/2017/03/28/bulk-modify-explicit-group-membership-powershell-scom/
# This code is tested on WFM-WINTEL-02
C:\etc\scripts\ModifyGroupMembership.ps1 -ManagementServer wfm-om12-msm-03 -ManagementPackID WFM.WindowsSvrMW.Production.Friday.amam -GroupID UINameSpacef5a736b118724e898c3aff7ef5259c76.Group -InstancesToRemove "442099c8-6b7b-6dcd-d3dc-584ce203999b"
C:\etc\scripts\ModifyGroupMembership.ps1 -ManagementServer wfm-om12-msm-03 -ManagementPackID WFM.WindowsSvrMW.Production.Friday.amam -GroupID UINameSpacef5a736b118724e898c3aff7ef5259c76.Group -InstancesToAdd "442099c8-6b7b-6dcd-d3dc-584ce203999b"

# You need the Management Pack ID:
GET-SCOMMANAGEMENTPACK | where {$_.displayname -like “WFM - Windows-Svr-MW - Production*"}

# You also need the Group ID which is really the Name based on the class
Get-SCOMGroup -DisplayName 'WFM - Windows-Svr-MW - Production - 2.Tuesday 02:00pm-04:00pm' | Get-SCOMClass | select-object -property name 
