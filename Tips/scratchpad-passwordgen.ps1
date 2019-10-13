# GeneratePassword can be called as a static method
# You don't need to instantiate the class first. It works just fine like this:
 
[System.Web.Security.Membership]::GeneratePassword(24,5)
# It just takes two arguments: "How long is the password" and "How many special characters"?
# The generated password is a string, and that's find for reading but not useful for creating a 
# credential object. So you'll usually need to convert the password into a SecureString.
 
# Same as above, just a different password length and complexity
$PW = [System.Web.Security.Membership]::GeneratePassword(30,10)
 
# The password as it is now:
$PW
 
# Converted to SecureString
$SecurePass = $PW | ConvertTo-SecureString -AsPlainText -Force
 
# The SecureString object
$SecurePass

<# 
	Saving for other use
	PowerShell Cheat Sheet
	https://binged.it/2mEVVDn
#>