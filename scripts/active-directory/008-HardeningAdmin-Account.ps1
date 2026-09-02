# Harden all admin accounts
$adminOUs = @(
    "OU=Tier0-DomainAdmins,OU=Admin,OU=BIIRA,DC=ad,DC=biira,DC=online",
    "OU=Tier1-ServerAdmins,OU=Admin,OU=BIIRA,DC=ad,DC=biira,DC=online",
    "OU=Tier2-WorkstationAdmins,OU=Admin,OU=BIIRA,DC=ad,DC=biira,DC=online"
)

Write-Host "`n=== Hardening Admin Accounts ===" -ForegroundColor Cyan

foreach ($ou in $adminOUs) {
    $accounts = Get-ADUser -Filter * -SearchBase $ou
    
    foreach ($account in $accounts) {
        # Set account as sensitive (prevents delegation)
        Set-ADUser -Identity $account -AccountNotDelegated $true
        
        # Require Kerberos preauthentication (security)
        Set-ADAccountControl -Identity $account -DoesNotRequirePreAuth $false
        
        # Require smart card for interactive logon (optional - disable for lab)
        # Set-ADUser -Identity $account -SmartcardLogonRequired $true
        
        Write-Host "Hardened: $($account.SamAccountName)" -ForegroundColor Green
    }
}

Write-Host "`nSecurity flags applied to all admin accounts" -ForegroundColor Green