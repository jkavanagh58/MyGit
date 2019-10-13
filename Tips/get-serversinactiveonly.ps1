get-adcomputer -Filter {OperatingSystem -like "*Windows Server*"} -Properties PasswordLastSet |
    Where-Object {((get-date)-$_.PasswordLastSet).TotalDays -ge 31} |
    Select-Object -Property Name, PasswordLastSet, @{N="DaysElapsed";e={((get-date)-$_.PasswordLastSet).TotalDays}} |
    sort-object -Property Name
