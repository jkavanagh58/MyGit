<#
.SYNOPSIS
    SUPERFIX...DISCO VERSION 4.a!!!
.DESCRIPTION
    SCCM Client is interrogated and based on results a set of instructions are
    performed.
.LINK
    SMS_CLIENT WMI Reference
    http://msdn.microsoft.com/en-us/library/cc145840.aspx
.NOTES
    Created :	06/01/2010	Thomas M. Cichon - Property of Swagelok Company.
    Modified:	06/01/2010	Thomas M. Cichon - Combined WMI & WSUS Fixes into 1-script.
    Modified:	08/10/2010	Thomas M. Cichon - Updated McAfee service list.
    Modified:	10/11/2010	Thomas M. Cichon - Updated McAfee service list.
    Modified:	11/25/2010	Thomas M. Cichon - Added RSOP repair & enhanced WSUS repair.
    Modified:	05/10/2011	Thomas M. Cichon - Updated with SCCM R3 Client instal syntax.
    Modified:	05/24/2011	Thomas M. Cichon - Fixed client install string to point at %LOGONSERVER%
    Modified:	11/08/2011	Thomas M. Cichon - Updated to compile .Net 4.0 MOF folder.
    Modified:	03/02/2012	Thomas M. Cichon - Updated to reject Windows 7 systems.
    Modified:	04/22/2012	Thomas M. Cichon - Updated Remove SMS registry keys not removed by ccmsetup.
    Modified:	02/22/2012	Thomas M. Cichon - Updated to remove App-V Client.
    Modified:	05/08/2012	Thomas M. Cichon - Changed location of GPUpdate and added /boot command.
    Modified:	10/11/2012	Thomas M. Cichon - Changed Cache size to 16384.  Added AppV reinstall.
    11.02.2012 JJK TODO: Determine method of use, if local maintain $strcomputer
#>
Function repair-sccmclient {
Param($machinename)
<#
    If execution of this script will continue to be run locally on suspect client machine
    the Param statement can be removed and the wmiclass changed to root\ccm:sms_client.
#>
    ([wmiclass] "\\$machinename\root\ccm:sms_client").repairclient()
}
# Following functions fail naming convention but were maintained for reference
Function WinXP {
# Code goes in Here
"Running XP Specific Process"
}
Function Win7 {
# Code goes in Here
"Running Win7 Specific Process"
}
Function shutdown {
    restart-computer
}
Function Prompt {
    # Just window dressing
    "SUPERFIX# "
}
## If running local
## Store computer name to variable
$strComputer = $env:COMPUTERNAME
## Set working location to windir
set-location $env:windir
 
# Run specific operations based on client OS
if (test-path c:\users){Win7}Else{WinXP}