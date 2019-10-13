Function Out-BAOLog {
    <#
        .SYNOPSIS
            Simple logging for Maintenance Mode attempts
        .NOTES
            10.05.2018 JJK:	Log format
                timestamp:machinename:attemptedoperation:result
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory=$True, ValueFromPipeline=$True,
                HelpMessage = "Name of machine for logging")]
        [System.String]$computerName,
        [parameter(Mandatory=$False, ValueFromPipeline=$False,
                HelpMessage = "Timestamp for log entry")]
        [System.String]$logStamp = Get-Date -Format ddMMyyyyhhmm,
        [parameter(Mandatory=$False, ValueFromPipeline=$False,
                HelpMessage = "Log file")]
        [System.String]$logFile = "D:\Scripts\BAO\log\MMOps.log",
        [parameter(Mandatory=$True, ValueFromPipeline=$True,
                HelpMessage = "Stop or Start request")]
        [System.String]$actionType,
        [parameter(Mandatory=$True, ValueFromPipeline=$True,
                HelpMessage = "Result of action")]
        [System.String]$actionResult
    )
    BEGIN{
        $logEntry = "{0}:{1}:{2}:{3}" -f $logStamp, $computerName, $actionType, $actionResult
    }
    PROCESS {
        Out-File -FilePath $logFile -InputObject $logEntry -Encoding ASCII -Append
    }
}