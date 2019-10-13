#Requires -Modules PSStringScanner
#$newPretty = "%ai$gitSep%f$gitSep%cr$gitSep%an$gitSep%s"
$newPretty = "%ai$gitSep%f$gitSep%cr$gitSep%an$gitSep%s$gitSep"
$SinceDaysAgo = 8
[String]$gitSep = "|"
$log = (git log --pretty=format:$newPretty --since=$SinceDaysAgo --abbrev-commit) -split "\r?\n"

function Get-NextField {
    param($scanner)
    $scanner.ScanUntil("(?=\$gitSep)")
    $null = $scanner.ScanUntil("\$gitSep")
}

$(foreach ($record in $log) {
        $scanner = New-PSStringScanner $record

        [PSCustomObject][Ordered]@{
            TimeStamp = Get-NextField $scanner
            Subject   = Get-NextField $scanner
            When      = Get-NextField $scanner
            User      = Get-NextField $scanner
            Message   = Get-NextField $scanner
        }
    }) | Export-Excel -Path $env:TEMP\newmodule.xlsx -TableStyle Medium12 -TableName "git05052019" -ClearSheet -AutoSize