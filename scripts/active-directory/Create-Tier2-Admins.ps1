# Create Tier 2 Workstation Admin Accounts
# Run this on srv1 as Domain Admin

$domainDN = "DC=ad,DC=biira,DC=online"
$tier2OU = "OU=Tier2-WorkstationAdmins,OU=Admin,OU=BIIRA,$domainDN"

# Define Tier 2 administrators (help desk / desktop support)
$tier2Admins = @(
    @{FirstName="Christopher"; LastName="Garcia"; Title="Security Analyst"},
    @{FirstName="Justin"; LastName="Hill"; Title="Cloud Architect"}
)

Write-Host "`n=== Creating Tier 2 Workstation Admin Accounts ===" -ForegroundColor Cyan

foreach ($admin in $tier2Admins) {
    $username = "$($admin.FirstName.ToLower()).$($admin.LastName.ToLower())-ws"
    
    # Check if account already exists
    $exists = Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue
    
    if ($exists) {
        Write-Host "Already exists: $username" -ForegroundColor Yellow
        continue
    }
    
    try {
        # Create admin account
        New-ADUser -Name "$($admin.FirstName) $($admin.LastName) (Workstation Admin)" `
                   -GivenName $admin.FirstName `
                   -Surname $admin.LastName `
                   -SamAccountName $username `
                   -UserPrincipalName "$username@ad.biira.online" `
                   -DisplayName "$($admin.FirstName) $($admin.LastName) (Workstation Admin)" `
                   -Description "Tier 2: Workstation Support - $($admin.Title)" `
                   -Title "$($admin.Title) - Desktop Support" `
                   -Path $tier2OU `
                   -AccountPassword (ConvertTo-SecureString "Change_This_Complex_Password_123!" -AsPlainText -Force) `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true `
                   -PasswordNeverExpires $false
        
        # Add to Tier 2 group
        Add-ADGroupMember -Identity "SG-Tier2-WorkstationAdmins" -Members $username
        
        Write-Host "Created: $username" -ForegroundColor Green
        
    } catch {
        Write-Host "Failed: $username - $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Milliseconds 200
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$tier2Count = (Get-ADUser -Filter * -SearchBase $tier2OU).Count
Write-Host "Tier 2 Admin Accounts Created: $tier2Count" -ForegroundColor Green

Write-Host "`nTier 2 Group Membership:" -ForegroundColor Cyan
Get-ADGroupMember -Identity "SG-Tier2-WorkstationAdmins" | Select-Object Name | Format-Table -AutoSize

# Verify none in OKTA sync group
Write-Host "`nOKTA Sync Safety Check:" -ForegroundColor Cyan
$oktaMembers = Get-ADGroupMember -Identity "SG-OKTA-AllUsers" | Select-Object -ExpandProperty SamAccountName
$adminInOkta = Get-ADUser -Filter * -SearchBase $tier2OU | Where-Object {$oktaMembers -contains $_.SamAccountName}
if ($adminInOkta) {
    Write-Host "WARNING: Admin accounts found in SG-OKTA-AllUsers!" -ForegroundColor Red
    $adminInOkta | Select-Object Name | Format-Table
} else {
    Write-Host "No Tier 2 admin accounts in SG-OKTA-AllUsers (correct)" -ForegroundColor Green
}