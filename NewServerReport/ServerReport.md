# New Server Report

Date: 08.12.2017
Name: Kavanagh, John J.

## Project Description

Create a report of new servers for the preceding month. Report is distributed via email to IT Security.

## Work Details

1.  Use ActiveDirectory "WhenCreated" field to generate list of new servers.
2.  Create fields based on ActiveDirectory information.
3.  Add HyperVisor platform - _Phil Cozzo suggested_.
4.  Add IP Address field - _Jennifer Foster requested_.
5.  Added logic to script to determine true month of servers. Instead of using Scheduled tasks and using 30 as the number of days as the calculation variable. The script will determine current month/Year (with additional process if Report is running in January) and use those values when filtering new servers.


    If ((get-date).Month -eq 1){
    		# Handle report run in January
    		$serverlist = get-adcomputer -Filter {OperatingSystem -like "*Server*"} -Properties OperatingSystem, WhenCreated |
    		where {(get-date($_.WhenCreated)).Month -eq 12 -And (get-date($_.WhenCreated)).Year -eq (get-date).AddYears(-1).Year} |
    		Sort-Object -Property WhenCreated
    	}
    	Else {
    		$serverlist = get-adcomputer -Filter {OperatingSystem -like "*Server*"} -Properties OperatingSystem, WhenCreated |
    		where {(get-date($_.WhenCreated)).Month -eq (get-date).AddMonths(-1).Month -And (get-date($_.WhenCreated)).Year -eq (get-date).Year} |
    		Sort-Object -Property WhenCreated
    	}

## Additional Information

Jennifer Foster requested fields to be added to report.

-   Owner
-   Application

Script Name on WFM-WINTEL-01 create-newserverreport.ps1
Scheduled to start September 1st at 03:00
