# Use the ForEach-Object Method
# could be seen as more elegant
get-aduser -Filter * | ForEach-Object -Process {if ($_.SamAccountName -like "techadmin*"){$_.Name}}

# Use ForEach to find based on naming pattern - for demo only
get-aduser -Filter * | Where {$_.SamAccountName -like "techadmin*"} | ForEach {$_ | select -Property Name}

# Use the inline methods to chain a Where and ForEach
(get-aduser -Filter *).Where({$_.SamAccountName -like "techadmin*"}).ForEach({ $_.Name })