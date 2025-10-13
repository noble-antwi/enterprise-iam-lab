# Create Tier 1 Server Admin Accounts
# Run this on srv1 as Domain Admin

$domainDN = "DC=ad,DC=biira,DC=online"
$tier1OU = "OU=Tier1-ServerAdmins,OU=Admin,OU=BIIRA,$domainDN"

# Define Tier 1 administrators
$tier1Admins = @(
    @{FirstName="John"; LastName="Smith"; Title="IT Manager"},
    @{FirstName="Emily"; LastName="Davis"; Title="Network Engineer"},
    @{FirstName="Matthew"; LastName="Harris"; Title="DevOps Engineer"},
    @{FirstName="Kevin"; LastName="Hall"; Title="Systems Engineer"}
)

Write-Host "`n=== Creating Tier 1 Server Admin Accounts ===" -ForegroundColor Cyan

foreach ($admin in $tier1Admins) {
    $username = "$($admin.FirstName.ToLower()).$($admin.LastName.ToLower())-admin"
    
    # Check if account already exists
    $exists = Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue
    
    if ($exists) {
        Write-Host "Already exists: $username" -ForegroundColor Yellow
        continue
    }
    
    try {
        # Create admin account
        New-ADUser -Name "$($admin.FirstName) $($admin.LastName) (Server Admin)" `
                   -GivenName $admin.FirstName `
                   -Surname $admin.LastName `
                   -SamAccountName $username `
                   -UserPrincipalName "$username@ad.biira.online" `
                   -DisplayName "$($admin.FirstName) $($admin.LastName) (Server Admin)" `
                   -Description "Tier 1: Server Administrator - $($admin.Title)" `
                   -Title "$($admin.Title) - Server Admin" `
                   -Path $tier1OU `
                   -AccountPassword (ConvertTo-SecureString "Change_This_Complex_Password_123!" -AsPlainText -Force) `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true `
                   -PasswordNeverExpires $false
        
        # Add to Tier 1 group
        Add-ADGroupMember -Identity "SG-Tier1-ServerAdmins" -Members $username
        
        Write-Host "Created: $username" -ForegroundColor Green
        
    } catch {
        Write-Host "Failed: $username - $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Milliseconds 200
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$tier1Count = (Get-ADUser -Filter * -SearchBase $tier1OU).Count
Write-Host "Tier 1 Admin Accounts Created: $tier1Count" -ForegroundColor Green

Write-Host "`nTier 1 Group Membership:" -ForegroundColor Cyan
Get-ADGroupMember -Identity "SG-Tier1-ServerAdmins" | Select-Object Name | Format-Table -AutoSize

# Verify none in OKTA sync group
Write-Host "`nOKTA Sync Safety Check:" -ForegroundColor Cyan
$oktaMembers = Get-ADGroupMember -Identity "SG-OKTA-AllUsers" | Select-Object -ExpandProperty SamAccountName
$adminInOkta = Get-ADUser -Filter * -SearchBase $tier1OU | Where-Object {$oktaMembers -contains $_.SamAccountName}
if ($adminInOkta) {
    Write-Host "WARNING: Admin accounts found in SG-OKTA-AllUsers!" -ForegroundColor Red
    $adminInOkta | Select-Object Name | Format-Table
} else {
    Write-Host "No Tier 1 admin accounts in SG-OKTA-AllUsers (correct)" -ForegroundColor Green
}