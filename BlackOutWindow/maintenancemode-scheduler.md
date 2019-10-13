# **Maintenance Mode Scheduler**

Script to start Maintenance Mode for Server OS Patching.

## Tasks

1. Read SCOM Groups related to patching
2. Based on name determine Maintenance Mode start time, use standard duration, enter SecuriyIssue as Reason
	- Extract start and stop time from SCOM Group Name ('[0-1][0-9]:[0-5][0-9](a|p)m')
4. When window is complete end maintenancemode

## Questions

- Need to understand window process to determine method to end maintenance mode. Purely SCCM or orchestrator?

## Issues

* SCOM 2012R2 does not provide means to future schedule MaintenanceMode. Alternate method to work on is using the existing Scheduled Tasks. For each patch group, find associated scheduled task and enable it.

## Notes
07.14.2017:	Test run with initial script

```
get-scomclassinstance -DisplayName $testgroup |get-scommaintenancemode | select *

 MonitoringObjectId : e6ceddfc-a538-73bd-f1bc-40d366e6e1d1
 StartTime          : 7/14/2017 7:43:07 PM
 ScheduledEndTime   : 7/14/2017 8:28:07 PM
 EndTime            :
 Reason             : SecurityIssue
 Comments           : Testing scripted process for starting Maintenance Mode for Security Patching
 User               : WEGMANS\TechAdminJXK
 LastModified       : 7/14/2017 7:43:07 PM
 ManagementGroup    : PRD_OM12R2
 ManagementGroupId  : 4aabdd25-45d3-6393-35be-73355cec2345
```
07.14.2017: Modify parameter definitions, need to add verify process

07.17.2017: Issue with Groups
- Check WFM - Windows-Svr-MW - Production - 2.Tuesday 08:00pm-**010**:00pm
- Check WFM - Windows-Svr-MW - Production - 2.Tuesday 08:00pm-**010**:00pm OMS Orchestrator
08.01.2017: Working on email notification

<code>
$taskCIM = new-cimsession -Computer "WFM-OM12-MSM-03.wfm.wegmans.com"
get-scheduledtask -CimSession $taskCIM -TaskName $groupObj.DisplayName |
	enable-scheduledtask -cimsession $taskCIM
</code>
