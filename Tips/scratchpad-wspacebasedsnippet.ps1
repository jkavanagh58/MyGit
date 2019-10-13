# these are snippets in the workspace snippets file
$mailparams = @{
    To          = "toaddress"
    From        = "fromaddress"
    Subject     = "mailsubject"
    Body        = "mailmessage"
    bodyAsHTML  = $True
    SMTPServer  = "smtp.wegmans.com"
    ErrorAction = "Stop"
}
Try {
    send-mailmessage @mailparams
}
Catch {
    "Unable to send message"
    "Reason: {0}:" -f $error[0].exception.message
}
# Using Snippet from workspace snippets file
If (!($defaultViServer)){
    Connect-VIserver $viServer -AllLinked | Out-Null
    'You are now connected to {0} vSphere servers' -f $defaultviservers.count
}
