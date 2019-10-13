# Function-enableMMTask


| Title   | Information |
| ------- | ------------------------- |
| Name    | function-enableMMTask.ps1 |
| Type    | PowerShell Script         |
| Author  | Kavanagh, John            |
| Contact | john.kavanagh@wegmans.com |


## Purpose

This is the proposed replacement for the scheduled task interaction of the SCOM Patching Windows. Current process is a stand-alone script and is triggered based on the Day of the Week. This script includes the functions to be used for trigger scheduled task action per **TaskName**.

Benefits:
1. More granular.
2. calling functions will provide performance benefits.
3. Script loaded with start-blackoutsync will place function in memory, again performance benefit.
4. Task actions will be performed against a specific task versus all tasks for the day.

## Implementation

- [ ] Copy script to WFM-Wintel-02
- [ ] Use . c:\etc\scripts\function-enableMMTask.ps1 in Begin statement of start-BlackOutsync.ps1
- [ ] Add function call passing the SCOM GroupName as GroupName pipeline parameter
