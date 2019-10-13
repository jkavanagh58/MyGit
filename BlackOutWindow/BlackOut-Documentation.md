# Documentation

06.19.2017 Meeting - Discussing Delta and trigger process steps (John Schleich and Rod Potter)
07.11.2017 Feedback - Accounting for static entries

## Purpose

Document information assembled to build the SCOM tasks

## Tasks

### Populate SCOM Groups

* [x] ~~_1. Review current Steps_~~
* [x] ~~_2. Determine best use of modifygroupmembership.ps1_~~
* [x] ~~_3. Develop Single stand-alone script that calls modifygroupmembership.ps1_~~

### Update SCOM Groups (Delta Process)

* [] Review Change CSV mentioned in **Items** list
* [x] Query CCM collection and adjust SCOM group as needed
* [  ] What objects do we adjust?

### Manage Maintenance Windows

= SCOM SDK provides access to IsInMaintenanceMode

- Adjust or stop Maintenance Window

### Data Gathering

Generate list of alerts post patching

- Group alerts to determine what additional objects need to be included in Maintenance Window related group

## Items

[Change CSV](file://rdc-orc12-db-01\scorch$\MaintenanceWindowChanges.csv)

* [X] Issue with unsealed management packs?

## Ideas

SCOM Class Query matching "DNS", "DFS"; PrincipalName

### Use CCM Cmdlets versus WMI query

Just a thought, will have to test performance and ease.

## Scheduled Task Information

Script Name: start-Sync.ps1
Server Name: WFM-WINTEL-02


|Configuration  |Value  |
|---------|---------|
| Action    | powershell.exe        |
| Parameters     | -NoProfile -NonInteractive -Command "C:\Jobs\SCOM\MaintenanceMode\start-sync.ps1 -PatchWindow *DayOfWeek*"         |
| Working Directory     | C:\Jobs\SCOM\MaintenanceMode        |
Note: DayOfWeek changes for each task instance

Five tasks, one for each day of the week. Reduces amount of time to complete full synch and can be called individually in case there is a late change to a maintenance window.
Each sync process will create a Worksheet in the reporting file [Reporting File](file://wfm.wegmans.com/Departments/InformationTechnology/TechWintel/.Scripts/SCOM/MaintenanceMode/BlackOutWindowReport.xlsx) for verification

## Remaining Tasks

* [] Scheduling script needs to be reversed (was written using SCOM 2016 SDK) and use the existing **MaintenanceMode** scheduled tasks
* [] Scheduling process will need to include process to disable the **MainetnanceMode** scheduled tasks
* [] V2 Upgrades


### Updates

06.25.2018:  Scripts moved to C:\Jobs\SCOM\MaintenanceMode on WFM-WINTEL-02

## Version 2

* [] Convert processes to functions
* [] Create module for functions. Some functions might be helpful outside of the automated task. Will help make scripts easier to read.
