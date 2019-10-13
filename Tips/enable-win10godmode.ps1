#Requires -RunAsAdministrator
$godmodeSplat = @{
    Path     = "$env:USERPROFILE\Desktop"
    Name     = "GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
    ItemType = 'Directory'
}
New-Item @godmodeSplat