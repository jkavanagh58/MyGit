Function Remove-CodeConfig {
<#
    .NOTES
        08.12.2018 JJK: TODO: Add the Whatif component of ShouldSupportProcess
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
Param ()
    # Check for existing config and data
    If (Test-Path $env:APPDATA\Code -ErrorAction SilentlyContinue){
        # Remove from AppData
        Try {
            Write-Information -MessageData "Removing from APPData" -InformationAction Continue
            Remove-Item $env:APPDATA\Code -Recurse -Force -Confirm:$False
        }
        Catch {
            Write-Error "Unable to remove from APPData" -ErrorAction Continue
            $error[0].Exception.Message
        }
    }
    Else {
        Write-Information -MessageData "No Data to Purge" -InformationAction Continue
    }
    If (Test-Path $env:USERPROFILE\.vscode -ErrorAction SilentlyContinue) {
        # Check for Extensions Cache
        Try {
            Write-Information -MessageData "Removing Extensions Cached Information" -InformationAction Continue
            Remove-Item $env:USERPROFILE\.vscode -Recurse -Force -Confirm:$false
        }
        Catch {
            Write-Error "Unable to remove Extension Cache" -ErrorAction Continue
            $error[0].Exception.Message
        }
    }
}