# Create Tier 0 Domain Admin Account
# Run this on srv1 as Domain Admin

$domainDN = "DC=ad,DC=biira,DC=online"
$tier0OU = "OU=Tier0-DomainAdmins,OU=Admin,OU=BIIRA,$domainDN"

# Replace with your actual name
$firstName = "Noble"
$lastName = "Antwi"
$username = "$($firstName.ToLower()).$($lastName.ToLower())-da"

Write-Host "`n=== Creating Tier 0 Domain Admin Account ===" -ForegroundColor Cyan

# Create admin account
New-ADUser -Name "$firstName $lastName (Domain Admin)" `
           -GivenName $firstName `
           -Surname $lastName `
           -SamAccountName $username `
           -UserPrincipalName "$username@ad.biira.online" `
           -DisplayName "$firstName $lastName (Domain Admin)" `
           -Description "Tier 0: Domain Administrator account for $firstName $lastName" `
           -Path $tier0OU `
           -AccountPassword (ConvertTo-SecureString "Change_This_Complex_Password_123!" -AsPlainText -Force) `
           -Enabled $true `
           -ChangePasswordAtLogon $true `
           -PasswordNeverExpires $false

Write-Host "Created: $username" -ForegroundColor Green

# Add to Domain Admins (built-in group)
Add-ADGroupMember -Identity "Domain Admins" -Members $username
Write-Host "Added to: Domain Admins" -ForegroundColor Green

# Add to custom Tier 0 group
Add-ADGroupMember -Identity "SG-Tier0-DomainAdmins" -Members $username
Write-Host "Added to: SG-Tier0-DomainAdmins" -ForegroundColor Green

# Verify NOT in OKTA sync group (safety check)
$inOktaGroup = Get-ADGroupMember -Identity "SG-OKTA-AllUsers" | Where-Object {$_.SamAccountName -eq $username}
if ($inOktaGroup) {
    Write-Host " WARNING: Admin account in SG-OKTA-AllUsers! Remove immediately!" -ForegroundColor Red
} else {
    Write-Host "Verified: NOT in SG-OKTA-AllUsers (correct)" -ForegroundColor Green
}

# Display account details
Write-Host "`n=== Account Created ===" -ForegroundColor Cyan
Get-ADUser -Identity $username -Properties * | Select-Object `
    Name, 
    SamAccountName, 
    UserPrincipalName, 
    DistinguishedName, 
    Enabled,
    @{Name='MemberOf';Expression={$_.MemberOf -join '; '}} | 
    Format-List