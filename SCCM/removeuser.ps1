﻿# Remove logged on user to local Adminsitrators group 
$curuser = ((gwmi win32_computersystem).username).Replace("\","/")
([ADSI]"WinNT://$env:computername/Administrators,group").Remove("WinNT://INFONET/$curuser")
# SIG # Begin signature block
# MIIEJQYJKoZIhvcNAQcCoIIEFjCCBBICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHgcrVY+EucLHKjGsqkNVI6x8
# LMKgggI5MIICNTCCAZ6gAwIBAgIQGq1CBDjqRrBNCLQW3sYq4jANBgkqhkiG9w0B
# AQUFADAiMSAwHgYDVQQDExdLYXZhbmFnaCAtIENvZGUgU2lnbmluZzAeFw0xMjAx
# MDEwNDAwMDBaFw0xODAxMDEwNDAwMDBaMCIxIDAeBgNVBAMTF0thdmFuYWdoIC0g
# Q29kZSBTaWduaW5nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDdu7E99Cy9
# dlw4zluinlt2/r0ykhDj/ESaCxvKVgQED5tWut7C93BP0lKyW+2ViiRhhakqEVhL
# 0IhMhoeiAo7rQF0gk6vcxmaoVGOUWl9E1u0PzmBaAXrklDqeGuStm58mGm4B9E/O
# TLvVsd7eo/oCpvQsfk99ob1doMfDh+0ZdQIDAQABo2wwajATBgNVHSUEDDAKBggr
# BgEFBQcDAzBTBgNVHQEETDBKgBClD17LyCFrvK2jan5T6A2OoSQwIjEgMB4GA1UE
# AxMXS2F2YW5hZ2ggLSBDb2RlIFNpZ25pbmeCEBqtQgQ46kawTQi0Ft7GKuIwDQYJ
# KoZIhvcNAQEFBQADgYEAsVWgTlRIgfu7uYMhujAE7pWI7uMhjmtk5l4jdxQN168O
# Er0DIg/7RFnIU+XXixENL4JPpHBahheLe0RsVTnW2OrZOZUTKLHLsjo/bKjSjbtQ
# SJKq+jrYcTY5hTl1CQEeim39k2hpxqSl+GQdWOwtynEKLIAHWIW+uYDFfH/FKokx
# ggFWMIIBUgIBATA2MCIxIDAeBgNVBAMTF0thdmFuYWdoIC0gQ29kZSBTaWduaW5n
# AhAarUIEOOpGsE0ItBbexiriMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQow
# CKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcC
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTFJ0VuJOCvGyl6LbKK
# oJEyI/5R1DANBgkqhkiG9w0BAQEFAASBgIKXB9EkKv/UEKeyYiWuRWeIXDGzoSrp
# jl9d4U2KEfMGtXbIyZkrpUTkoUuE3uSDHwXge9kwhJFY953VeDuxI2WRKfBgIK+N
# hmiE4xnFiRBNox9WEDR/QpTtZD9fYt/LuZMhDFSiybxpYTkHNFJidxVrHD4SwRFv
# JBF3PAXgbbx7
# SIG # End signature block