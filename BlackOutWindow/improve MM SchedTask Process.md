# Revise Scheduled Task Process

Use a script to create new scheduled tasks. Eliminates static list of scheduled tasks. Current scheduled tasks work so this is not an immediate need. Current ScheduledTasks are on WFM-OM12-MSM-03.

## Why

Cleaner than current static scheduled items. These scheduled items have to be enabled and disabled monthly.


## Concept

Run through SCOM groups, use Name element to extract window day and time. Use data to create new scheduled tasks.

cmdlet

[New-ScheduledTask](https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/New-ScheduledTask?view=win10-ps)

[Start-SCOMMaintenanceMode](https://docs.microsoft.com/en-us/powershell/systemcenter/systemcenter2016/OperationsManager/vlatest/Start-SCOMMaintenanceMode)


## Steps

1. Code to list SCOM Groups - filter by day
2. Iterate through group
3. Extract start and end into variables - converted to UTC?
4. Create new scheduled task that will run start-maintenancemode


