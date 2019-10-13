$admcreds = get-credential -UserName "wegmans\techadminjxk" -Message "Create the credential object"
get-adcomputer -Filter {Name -like "wks*"} | 
    Sort-Object -Property Name |
    ForEach { $machine = $_.Name ;
                Try {get-hotfix -ID KB4103721 -ComputerName $_.Name -Credential $admcreds -ErrorAction SilentlyContinue} 
                Catch {"{0}: {1}"-f $machine, $error[0].Exception.Message }
    }