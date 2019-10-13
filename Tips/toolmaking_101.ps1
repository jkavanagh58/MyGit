Function get-adservers {
<#
    Standard function for using AD as an input for scripts needing a list of active server objects
#>
    $servers =  get-adcomputer -Filter {OperatingSystem -like "*Windows Server*"} -Properties PasswordLastSet |
                Where-Object {((get-date)-$_.PasswordLastSet).TotalDays -le 31} |
                Select-Object -Property Name, PasswordLastSet, @{N="DaysElapsed";e={((get-date)-$_.PasswordLastSet).TotalDays}} |
                sort-object -Property Name
    RETURN $servers
}

# Example of script element turned to a tool.
$compList = get-adservers
$compList | Select-Object -First 5 -Property Name

# It is a tool, let's make it more flexible by offering an option to run against an alternate domain
Function get-adservers {
#Requires -Module ActiveDirectory
    <#
        Standard function for using AD as an input for scripts needing a list of active server objects
    #>
    Param (
        [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage = "Domain name or Domain Controller name")]
        [System.String]$qryDomain = $env:USERDNSDOMAIN
)
    $servers =  get-adcomputer -Filter {OperatingSystem -like "*Windows Server*"} -Properties PasswordLastSet -Server $qryDomain |
                Where-Object {((get-date)-$_.PasswordLastSet).TotalDays -le 31} |
                Select-Object -Property Name, PasswordLastSet, @{N="DaysElapsed";e={((get-date)-$_.PasswordLastSet).TotalDays}} |
                sort-object -Property Name
    RETURN $servers
}


# ========================================================================================
# Next step would be to collection functions like that and create a module for easy access