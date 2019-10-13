﻿# Add logged on user to local Adminsitrators group 
$curuser = ((gwmi win32_computersystem).username).Replace("\","/")
([ADSI]"WinNT://$env:computername/Administrators,group").Add("WinNT://$curuser") 

# SIG # Begin signature block
# MIIEJQYJKoZIhvcNAQcCoIIEFjCCBBICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoeMVumqpbe3LptqJSVTZOpsb
# EEKgggI5MIICNTCCAZ6gAwIBAgIQGq1CBDjqRrBNCLQW3sYq4jANBgkqhkiG9w0B
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
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRxpRrUNapD1NzZ3xst
# Gr/aUaIsTjANBgkqhkiG9w0BAQEFAASBgMyUI4vYVPJ6BwRNp8E6ZgV1BzolBgaR
# Uo8/mUS32IijIQs1U831nH7H/Euu5RAg8JT4k6oIRolZ6ZdOnBwF0J3i+rpQSVgE
# eXwgKjOFkNbQuPYzFAu7+MFIwAzbNQq5m+Pcv+rSgTNZt8Nj2BJm1fQb4PuaSMiE
# YANnnxWi2bPM
# SIG # End signature block