# Working with setting some defaults for the install-module cmdlet
$PSDefaultParameterValues=@{
    "install-module:Confirm"=$False
    "install-module:Verbose"=$True
    "install-module:Scope"="AllUsers"
}