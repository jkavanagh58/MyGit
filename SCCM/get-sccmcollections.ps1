
gwmi -Namespace "root\sms\site_dz1" -class sms_collection -computername dmz1sms01  | select Name,CollectionID | sort Name