$qrytxt = "Select Name FROM sms_collectionmember_a WHERE CollectionID = 'DZ1003BB'"
gwmi -Namespace "root\sms\site_dz1" -computername dmz1sms01 -query $qrytxt | 
select Name