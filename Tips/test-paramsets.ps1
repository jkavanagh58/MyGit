Function Test-moveuserorcomputer {
[cmdletbinding()]
Param(
    [parameter(Mandatory = $True, ValueFromPipeline = $True,
        HelpMessage = "Destination OU")]
    [System.String]$OU,
    [parameter(Mandatory=$True, ValueFromPipeline=$True,
        HelpMessage = "User First Name",
        ParameterSetName = 'User')]
    [Switch]$User,
    [parameter(Mandatory = $True, ValueFromPipeline = $True,
        HelpMessage = "User Logon Name",
        ParameterSetName = 'User')]
        [System.String]$logon,
    [parameter(Mandatory = $True, ValueFromPipeline = $True,
        HelpMessage = "Computer",
        ParameterSetName = 'Computer')]
    [Switch]$Computer,
    [parameter(Mandatory = $True, ValueFromPipeline = $True,
        HelpMessage = "Name of Computer",
        ParameterSetName = 'Computer')]
    [System.String]$MachineName
)
    $PSCmdlet.ParameterSetName
    Switch ($PSCmdlet.ParameterSetName){
        'Computer'  {"The process would move {0} to {1}" -f $MachineName, $OU}
        'User'      { "The process would move {0} to {1}" -f $logon, $OU}
    }
}