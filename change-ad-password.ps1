<#
.SYNOPSIS
    Change Active Directory Passwords
.DESCRIPTION
    Changes passwords for multiple domains, with the following assumptions:
     - Requires name resolution for all DC's, use local host entry if needed
     - Logon name is the same for all domains
     - Passwords are currently syncronized
     - Delete domain names from $domainList for which you don't want to change your password
     - RSAT tools must be installed on your workstation for the ActiveDirectory module
       https://www.microsoft.com/en-us/download/details.aspx?id=45520
.EXAMPLE
    PS C:\> change-ad-password.ps1
    Prompts you for current and new passwords
    Output will display the domain name as it changes each password
.NOTES
    AUTHOR: Mark Tellier 
    LASTEDIT: 10/16/2018 
    VERSION HISTORY: 
    1.0 - Initial release
#>


# --- LOAD MODULE
If ( ! (Get-module ActiveDirectory )) {
    Import-Module ActiveDirectory
}

# --- ENTER CREDENTIALS
$cLogin = Read-Host "Enter AD Username only (NO DOMAIN NAME)"
$coPassword = Read-Host -asSecureString "Enter your current password"
$cnPassword = Read-Host -asSecureString "Enter your new password"

<# 

ACTIVE DREICTORY DOMAIN REFERENCES

NETBIOS        IP ADDRESS      DOMAIN CONTROLLER
-------        ----------      -----------------     
DOMAINA        10.10.10.2      dc04.domaina.com
DOMAINB        10.10.20.2      dc02.domainb.local
DOMAINC        10.10.30.2      dc01.domainc.com
DOMAIND        10.10.40.2      dc03.domaind.local
DOMAINE        10.10.50.2      dc05.domaine.com

#>

# --- DEFINE DOMAIN KEY VALUE PAIRS
$domainList = [ordered]@{
    DOMAINA    = "dc04.domaina.com"
    DOMAINB    = "dc02.domainb.local"
    DOMAINC    = "dc01.domainc.com"
    DOMAIND    = "dc03.domaind.local"
    DOMAINE    = "dc05.domaine.com"
}

# --- CHANGE DOMAIN PASSWORDS
$domainList.GetEnumerator() | ForEach-Object {
    $msDomain = '{0}' -f $_.key
    $msDC = '{0}' -f $_.value
    Write-Output "Changing Domain password for: $msDomain"
    Set-ADAccountPassword -Server $msDC -Identity $cLogin -OldPassword $coPassword -NewPassword $cnPassword
}

Write-Host "`n`nRemember to change passwords in following:"
Write-Host "IPA `nLaptop `nRoyalTS  `nOutlook `nMobile Phone `nAWS Workspaces `nScheduled Task"
