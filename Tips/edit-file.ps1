$original_file = 'c:\temp\add-VSCodeExtension.ps1'
$destination_file =  'C:\temp\add-VSCodeInsExtension.ps1'
(Get-Content $original_file) | Foreach-Object { $_ -replace 'code ', 'code-insiders' } |
    Set-Content $destination_file