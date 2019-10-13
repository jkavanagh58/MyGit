connect-toscom
$subs = get-notificationsubscription | ? {$_.DisplayName -like "INT*" -or $_.DisplayName -like "SQL*"} | sort DisplayName
ForEach ($s in $subs){
   "Notification Group: " + $s.DisplayName 
   $s.ToRecipients | sort Name | %{$_. Name}
}
