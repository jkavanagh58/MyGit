 Function ___-_________ {
<#
.SYNOPSIS
    This advanced function ...

.DESCRIPTION
    ...

.PARAMETER <ParameterName>
    The <ParameterName> parameter ...

.PARAMETER Environment
    The Environment parameter is used to separate log files into their own directories. Additionally, the Environment parameter can be used to assist in making logical decisions where varying events occur inside the code based on the current environment.

.PARAMETER Log
    The Log parameter is used to indicate that the function should produce logging output. The valid parameter values for the Log parameter are ToScreen, ToScreenAndFile, and ToFile. This will display logging on the screen only, on the screen and in a locally stored file, or in a locally stored file only, respectively.

.EXAMPLE
    This example ...
    PS > <Example>
    
.NOTES
    Name: ___-_________
    Author: <Name>
    Comments: --
    Last Edit: xx/xx/xxxx [1.0]
    Template Version: 2.1 (Template Author: Tommy Maynard)
        - Doesn't log parameter value(s), if a parameter name includes the word "password."
    Version 1.0
        - <VersionNotes> (or delete if no version notes)
    Version 1.1
        -
    Version 1.2
  
              --
    Version 2.0
#>
    [CmdletBinding()]
    Param (
        # Add additional parameters here.
        
        #region Template code for Param block.
        [Parameter()]
        [ValidateSet('ACC','DEV','NON-PRD','PRD','QA','STG','TST')]
        [string]$Environment,

        [Parameter()]
        [ValidateSet('ToFile','ToScreen','ToScreenAndFile')]
        [string]$Log
        #endregion
    )

    Begin {
        #region Template code for Begin block.
            #region Catch Verbose being used.
            If ($PSBoundParameters['Verbose']) {
                $Log = 'ToScreen'
            }
            #endregion

            #region Create Write-Verbose function, log directory, and log file.
            Switch ($Log) {
                {$Log -eq 'ToScreen'} {
                    #region Modify the VerbosePreference variable.
                    $VerbosePreference = 'Continue'
                    break
                    #endregion
                }
                {$Log -eq 'ToFile' -or $Log -eq 'ToScreenAndFile'} {
                    #region Determine the file log directory (according to $Environment).
                    $LogDirectory = "$($MyInvocation.MyCommand.Name)"
                    If ($Environment) {
                        $LogPath = "$env:SystemDrive\support\Logs\$LogDirectory\$($Environment.ToUpper())"
                    } Else {
                        $LogPath = "$env:SystemDrive\support\Logs\$LogDirectory"
                    } # End If-Else.
                    #endregion

                    #region Create the file log directory (if needed).
                    If (-Not(Test-Path -Path $LogPath)) {
                        [System.Void](New-Item -Path $LogPath -ItemType Directory)
                    } # End If.
                    #endregion

                    #region Create the log file path variable.
                    $FileName = "$(Get-Date -Format 'DyyyyMMddThhmmsstt.fffffff').txt"
                    $LogFilePath = "$LogPath\$FileName"
                    #endregion

                    #region Create Write-Verbose function.
                    If ($Log -eq 'ToFile') {
                        Function Write-Verbose {
                            Param ($Message)
                            "[$(Get-Date -Format G)]: $Message" | Out-File -FilePath $LogFilePath -Append
                        }

                    } ElseIf ($Log -eq 'ToScreenAndFile') {
                        $VerbosePreference = 'Continue'
                        Function Write-Verbose {
                            Param ($Message)
                            Microsoft.PowerShell.Utility\Write-Verbose -Message $Message
                            "[$(Get-Date -Format G)]: $Message" | Out-File -FilePath $LogFilePath -Append
                        }
                    } # End If-ElseIf.
                #endregion
                }
                'default' {}
            } # End Switch.
            #endregion

            #region Write informational details.
            $BlockLocation = '[INFO   ]'
            Write-Verbose -Message "$BlockLocation Invoking the $($MyInvocation.MyCommand.Name) $($MyInvocation.MyCommand.CommandType) on $(Get-Date -Format F)."
            Write-Verbose -Message "$BlockLocation Invoking user is ""$env:USERDOMAIN\$env:USERNAME"" on the ""$env:COMPUTERNAME"" computer."
            If ($Log -eq 'ToFile' -or $Log -eq 'ToScreenAndFile') {
                Write-Verbose -Message "$BlockLocation Storing log file as ""$LogFilePath."""
            }
            Foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
                If ($Parameter.Key -like '*password*') {
                    Write-Verbose -Message "$BlockLocation Including the ""$($Parameter.Key)"" parameter without the parameter $(If ($Parameter.Value.Count -gt 1) {'values'} Else {'value'})."
                } Else {
                    Write-Verbose -Message "$BlockLocation Including the ""$($Parameter.Key)"" parameter with the ""$($Parameter.Value -join '","')"" $(If ($Parameter.Value.Count -gt 1) {'values'} Else {'value'})."
                }
            }
            #endregion

            #region Write block location. 
            $BlockLocation = '[BEGIN  ]'
            Write-Verbose -Message "$BlockLocation Entering the Begin block [$($MyInvocation.MyCommand.CommandType): $($MyInvocation.MyCommand.Name)]."
            #endregion
        #endregion

        # Add additional code here.
    } # End Begin.

    Process {
        #region Template code for Process block.
            #region Write block location.
            $BlockLocation = '[PROCESS]'
            Write-Verbose -Message "$BlockLocation Entering the Process block [$($MyInvocation.MyCommand.CommandType): $($MyInvocation.MyCommand.Name)]."
            #endregion
        #endregion

        # Add additional code here.
    } # End Process.

    End {
        #region Template code for End block.
            #region Write block location.
            $BlockLocation = '[END    ]'
            Write-Verbose -Message "$BlockLocation Entering the End block [$($MyInvocation.MyCommand.CommandType): $($MyInvocation.MyCommand.Name)]."
            #endregion
        #endregion

        # Add additional code here.
    } # End End.
} # End Function: ___-_________.