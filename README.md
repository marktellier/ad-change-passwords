# Active Directory Password Change

Changing your AD password across multiple domains can be time consuming. This script was written to save time by changing my password across multiple domains. For the script to work, the following must be true across all domains:

- Same logon name
- Same password
- Network access to all DCs
- Name resolution to all DCs

---

This script does require the ActiveDirectory module, so you will need to have the RSAT tools installed on your workstation.

```powershell
# --- LOAD MODULE
If ( ! (Get-module ActiveDirectory )) {
    Import-Module ActiveDirectory
}
```

This will prompt me for my username (NO DOMAIN NAME), current and new passwords.

```powershell
# Enter Credentials
$cLogin = Read-Host "Enter AD Username only (NO DOMAIN NAME)"
$coPassword = Read-Host -asSecureString "Enter your current password"
$cnPassword = Read-Host -asSecureString "Enter your new password"
```

The next section is only for your reference. We have a lot of domains and domain controllers, it's useful to have a reference as to what Domain and DC I'm referencing to change my password.

```powershell
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
```

If you've worked with hash tables, you know that items in the table are retrieved in random order. Now that's not a problem here, but I chose to store data in an ordered dictionary so that passwords are changed across domains in a predictable order. The Key is your NetBIOS domain name and will be added as a prefix to your username. The Value is the fqdn of a domain controller that will be contact for changing your password.  

Update this list to refence your infrastructure.

```powershell

# --- DEFINE DOMAIN KEY VALUE PAIRS
$domainList = [ordered]@{
    DOMAINA    = "dc04.domaina.com"
    DOMAINB    = "dc02.domainb.local"
    DOMAINC    = "dc01.domainc.com"
    DOMAIND    = "dc03.domaind.local"
    DOMAINE    = "dc05.domaine.com"
}
```

Now it's time to change your password across all domains, writting output to the screen. You will see what domain password has changed and what if any changes have failed. My suggestion would be to start by testing the script with one domain, then two, then go for it.

```powershell

# --- CHANGE DOMAIN PASSWORDS
$domainList.GetEnumerator() | ForEach-Object {
    $msDomain = '{0}' -f $_.key
    $msDC = '{0}' -f $_.value
    Write-Output "Changing Domain password for: $msDomain"
    Set-ADAccountPassword -Server $msDC -Identity $cLogin -OldPassword $coPassword -NewPassword $cnPassword
}
```

This is a reminder to myself, other places I may have to change my password.

```powershell
Write-Host "`n`nRemember to change passwords in following:"
Write-Host "IPA `nLaptop `nRoyalTS  `nOutlook `nMobile Phone `nAWS Workspaces `nScheduled Task"
```

Hope this helps to get a few minutes back to your day.
