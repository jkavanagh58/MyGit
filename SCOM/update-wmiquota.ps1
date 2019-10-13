$config = gwmi -class "__ProviderHostQuotaConfiguration" -namespace Root
$config.HandlesPerHost = 8*1024
$config.Put()