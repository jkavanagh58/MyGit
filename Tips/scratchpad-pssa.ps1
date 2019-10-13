# Working with PSSA Indentation rule
<#
[CmdletBinding()]
Param(
    [parameter(Mandatory = $False, ValueFromPipeline = $False,
        HelpMessage = "Testing")]
    [System.String]$somevar = "Testing"
)
BEGIN {

}
PROCESS {
    ForEach ($proc in Get-Process) {
        $proc.name
    }
    #What happens here
    ForEach ($proc in Get-Process) {
    $proc.name
    }
}
END {
    "All done here"
}
#>
ForEach ($proc in get-process) {
    "Test"
}