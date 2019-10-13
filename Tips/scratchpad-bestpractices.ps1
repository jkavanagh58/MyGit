# Posting an ah-ha from the PowerShell DevOps Summit...
# @kmruddy - the newest PowerCLI Man put out a quick post on
# twitter and yeah head down in shame...
[CmdletBinding()]
Param (
    [System.IO.DirectoryInfo]$path = "c:\etc",
    [System.IO.FileInfo]$file = "c:\etc\scripts\system-functions.ps1",
    [String]$input
)
# Just looks more official?
# Not really ... notice without needing to do a get-childitem
# the FileInfo instance already has the filesystem type
# properties and methods we want
#$path | get-member -MemberType Methods
#$file | get-member -MemberType Methods
# Let's check the performance
"Cmdlet Method"
Measure-Command -Expression { get-childitem -Path $path -Recurse | Select-Object -Property Name, Directory } | Select-Object -Property TotalSeconds
"-----"
".Net Method"
Measure-Command -Expression { $path.GetFiles('*.*', 'AllDirectories') | Select-Object -Property Name, Directory } | Select-Object -Property TotalSeconds
# Lets check performance for array creation
Remove-Variable testdata, procArray -ErrorAction SilentlyContinue
"Collecting test data"
$testData = $path.GetFiles('*.*', 'AllDirectories')
Measure-Command -Expression { $procArray = @()
    ForEach ($item in $testData) { $procArray += $item }
} | Select-Object -Property TotalSeconds
"Record Count: {0}" -f $procArray.Count
Remove-Variable procArray
# Proper array

Measure-Command -Expression { $procArray = [System.Collections.ArrayList]@();
    ForEach ($item in $testData) { [Void]$procArray.Add($item) };
    "Record Count: {0}" -f $($procArray.Count)
} | Select-Object -Property TotalSeconds
"Record Count: {0}" -f $procArray.Count
