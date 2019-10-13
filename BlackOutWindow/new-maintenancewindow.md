# Project

Stand-alone tool (powershell script) to place a server and all related objects into SCOM MaintenanceMode

## Description:

There is always a need to provide a conenient way for operators to place a SCOM Monitored server into MaintenanceMode. Additionally there are automation projects that will need to do this. The goal of this project is provide a script that can be used manually or part of another process to perform this operation comprehensively as well as easily. No need to install the OpsMgr SDK locally as all operations will be performed via a remote session.

### Work to be done

- [ ] Add pipeline parameter for MaintenanceMode Reason
- [ ] Error Handling
- [ ] Remove inferred credentials being used for testing from desktop
- [ ] Test in PowerShell Core; based on no local modules could be cross-platform
- [X] Fix AgentObjects query to use server short name
- [ ] Accept multiple machines for input
- [ ] Need to discuss the request regarding varying MaintenanceMode times

### Contributors

Name | Contact
---------|--------
 John Schleich |
 Matt Bartholomew |
 Rod Potter | rod.potter@wegmans.com
 John Kavanagh | john.kavanagh@wegmans.com
