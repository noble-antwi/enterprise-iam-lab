# Phase 2: User Account Creation

## Overview
Creating realistic test users for OKTA synchronization with proper naming, UPN configuration, and group membership.

## User Naming Standards

### Standard User Format
```
SamAccountName:      firstname.lastname
UserPrincipalName:   firstname.lastname@biira.online
Display Name:        FirstName LastName
Email Address:       firstname.lastname@biira.online
```

### Service Account Format
```
SamAccountName:      svc-application-purpose
UserPrincipalName:   svc-application-purpose@biira.online
Display Name:        [Application] Service Account
Email:               (none)
```

### Administrative Account Format
```
SamAccountName:      admin-username
UserPrincipalName:   admin-username@biira.online
Display Name:        Admin - FirstName LastName
Email:               admin-username@biira.online
```

## Critical: UPN Suffix Configuration

### Why @biira.online UPN?
- ✅ User-friendly login for OKTA
- ✅ Matches public domain (professional)
- ✅ Separates from internal AD domain
- ✅ Enables seamless cloud SSO

### Verify UPN Suffix Exists
```powershell
# Check available UPN suffixes
(Get-ADForest).UPNSuffixes

# Should include: biira.online
# If not, add it first (see Phase 1 docs)
```

## Creating Individual Users

### Manual Creation (GUI)

**Steps:**
1. Open Active Directory Users and Computers
2. Navigate to correct OU (e.g., BIIRA\Users\Corporate\IT)
3. Right-click → New → User
4. Fill in:
   - First name: John
   - Last name: Smith
   - User logon name: john.smith
   - **UPN suffix:** Select `@biira.online` from dropdown
5. Set password: Welcome2Biira!
6. Uncheck: User must change password at next logon (for lab)
7. Click Finish

### PowerShell Creation (Recommended)

**Single User:**
```powershell
# Variables
$firstName = "John"
$lastName = "Smith"
$department = "IT"
$title = "Systems Administrator"
$username = "$firstName.$lastName".ToLower()
$upn = "$username@biira.online"
$ou = "OU=IT,OU=Corporate,OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online"

# Create user
New-ADUser -Name "$firstName $lastName" `
           -GivenName $firstName `
           -Surname $lastName `
           -SamAccountName $username `
           -UserPrincipalName $upn `
           -EmailAddress $upn `
           -Title $title `
           -Department $department `
           -Path $ou `
           -AccountPassword (ConvertTo-SecureString "Welcome2Biira!" -AsPlainText -Force) `
           -Enabled $true `
           -ChangePasswordAtLogon $false

# Verify
Get-ADUser $username -Properties UserPrincipalName, EmailAddress
```

## Bulk User Creation

### Step 1: Create CSV Template

**File:** `configs/templates/user-template.csv`

```csv
FirstName,LastName,Department,Title,Email
John,Smith,IT,Systems Administrator,john.smith@biira.online
Jane,Doe,Finance,Financial Analyst,jane.doe@biira.online
Michael,Johnson,Sales,Sales Manager,michael.johnson@biira.online
Sarah,Williams,HR,HR Director,sarah.williams@biira.online
David,Brown,Executive,CTO,david.brown@biira.online
Emily,Davis,IT,Network Engineer,emily.davis@biira.online
Robert,Martinez,Finance,Senior Accountant,robert.martinez@biira.online
Lisa,Anderson,Marketing,Marketing Director,lisa.anderson@biira.online
James,Wilson,Sales,Account Executive,james.wilson@biira.online
Mary,Taylor,HR,Recruiter,mary.taylor@biira.online
```

### Step 2: Run Bulk Creation Script

```powershell
# Navigate to scripts folder
cd C:\enterprise-iam-lab\scripts\active-directory

# Run bulk user creation
.\New-BulkUsers.ps1

# With custom CSV
.\New-BulkUsers.ps1 -CsvPath "C:\custom-users.csv"

# With custom password
.\New-BulkUsers.ps1 -DefaultPassword "MySecurePass123!"
```

**Script will:**
- Read CSV file
- Create users in department-specific OUs
- Set UPN to @biira.online
- Add to SG-OKTA-AllUsers group
- Add to department groups

### Step 3: Verify Creation

```powershell
# List all users in BIIRA OUs
Get-ADUser -Filter * -SearchBase "OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online" -Properties Department, EmailAddress | 
    Select-Object Name, SamAccountName, UserPrincipalName, Department | 
    Format-Table -AutoSize

# Verify UPN suffixes
Get-ADUser -Filter * -SearchBase "OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online" -Properties UserPrincipalName | 
    Where-Object {$_.UserPrincipalName -notlike "*@biira.online"} | 
    Select-Object Name, UserPrincipalName

# Should return empty (all users should have @biira.online)
```

## Service Account Creation

### OKTA AD Agent Service Account

**Critical for OKTA integration:**

```powershell
# Create service account for OKTA AD Agent
$svcAccountName = "svc-okta-agent"
$svcUPN = "$svcAccountName@biira.online"
$svcOU = "OU=ServiceAccounts,OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online"
$svcPassword = ConvertTo-SecureString "ComplexP@ssw0rd123!" -AsPlainText -Force

New-ADUser -Name $svcAccountName `
           -SamAccountName $svcAccountName `
           -UserPrincipalName $svcUPN `
           -DisplayName "OKTA AD Agent Service Account" `
           -Description "Service account for OKTA Active Directory Agent synchronization" `
           -Path $svcOU `
           -AccountPassword $svcPassword `
           -Enabled $true `
           -PasswordNeverExpires $true `
           -CannotChangePassword $true

# Verify
Get-ADUser $svcAccountName -Properties PasswordNeverExpires, CannotChangePassword
```

**Service Account Permissions (for OKTA Agent):**
- Read access to Users OUs
- Read access to Groups OUs
- NO write permissions (read-only sync)

### Additional Service Accounts

```powershell
# Azure AD Connect (future)
New-ADUser -Name "svc-azure-sync" -SamAccountName "svc-azure-sync" ...

# Backup service
New-ADUser -Name "svc-backup" -SamAccountName "svc-backup" ...
```

## Group Membership Assignment

### Add Users to OKTA Sync Group

```powershell
# Add all corporate users to SG-OKTA-AllUsers
$users = Get-ADUser -Filter * -SearchBase "OU=Corporate,OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online"

foreach ($user in $users) {
    Add-ADGroupMember -Identity "SG-OKTA-AllUsers" -Members $user
    Write-Host "Added $($user.SamAccountName) to SG-OKTA-AllUsers"
}

# Verify membership
(Get-ADGroupMember -Identity "SG-OKTA-AllUsers").Count
```

### Add Users to Department Groups

```powershell
# Auto-assign based on Department attribute
$departments = @("IT", "Finance", "Sales", "HR", "Marketing", "Executive")

foreach ($dept in $departments) {
    $deptUsers = Get-ADUser -Filter "Department -eq '$dept'" -SearchBase "OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online"
    $deptGroup = "SG-Dept-$dept"
    
    foreach ($user in $deptUsers) {
        Add-ADGroupMember -Identity $deptGroup -Members $user -ErrorAction SilentlyContinue
    }
    
    Write-Host "Added $($deptUsers.Count) users to $deptGroup"
}
```

## User Attributes for OKTA Sync

### Essential Attributes

| AD Attribute | OKTA Field | Purpose |
|--------------|------------|---------|
| UserPrincipalName | Login | Primary identifier |
| EmailAddress | Email | Email address |
| GivenName | firstName | First name |
| Surname | lastName | Last name |
| DisplayName | displayName | Full name |
| Department | department | Org structure |
| Title | title | Job title |
| Manager | manager | Reporting structure |

### Set Additional Attributes

```powershell
# Set manager relationship
Set-ADUser -Identity "john.smith" -Manager "david.brown"

# Set employee ID (for future use)
Set-ADUser -Identity "john.smith" -EmployeeID "EMP001"

# Set office location
Set-ADUser -Identity "john.smith" -Office "Chicago HQ"

# Set phone number
Set-ADUser -Identity "john.smith" -OfficePhone "+1-555-0123"
```

## Realistic User Scenarios

### Scenario 1: New Employee Onboarding

**User:** Sarah Wilson, Marketing Coordinator

```powershell
# Create user
New-ADUser -Name "Sarah Wilson" `
           -GivenName "Sarah" `
           -Surname "Wilson" `
           -SamAccountName "sarah.wilson" `
           -UserPrincipalName "sarah.wilson@biira.online" `
           -EmailAddress "sarah.wilson@biira.online" `
           -Title "Marketing Coordinator" `
           -Department "Marketing" `
           -Manager "lisa.anderson" `
           -Office "Chicago HQ" `
           -Path "OU=Marketing,OU=Corporate,OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online" `
           -AccountPassword (ConvertTo-SecureString "Welcome2Biira!" -AsPlainText -Force) `
           -Enabled $true

# Add to groups
Add-ADGroupMember -Identity "SG-OKTA-AllUsers" -Members "sarah.wilson"
Add-ADGroupMember -Identity "SG-Dept-Marketing" -Members "sarah.wilson"
Add-ADGroupMember -Identity "SG-App-Office365" -Members "sarah.wilson"
```

### Scenario 2: Contractor Account

**User:** Alex Johnson, IT Contractor

```powershell
# Create contractor
New-ADUser -Name "Alex Johnson" `
           -GivenName "Alex" `
           -Surname "Johnson" `
           -SamAccountName "alex.johnson" `
           -UserPrincipalName "alex.johnson@biira.online" `
           -Title "IT Contractor" `
           -Department "IT" `
           -Path "OU=Contractors,OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online" `
           -AccountPassword (ConvertTo-SecureString "TempPass123!" -AsPlainText -Force) `
           -Enabled $true `
           -AccountExpirationDate (Get-Date).AddDays(90)

# Note: Account expires in 90 days
```

## Validation

### User Count by Department

```powershell
# Count users per department
Get-ADUser -Filter * -SearchBase "OU=Corporate,OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online" -Properties Department | 
    Group-Object Department | 
    Select-Object Name, Count | 
    Sort-Object Name

# Expected output:
# Name       Count
# ----       -----
# Executive      1
# Finance        2
# HR             2
# IT             2
# Marketing      1
# Sales          2
```

### UPN Verification

```powershell
# Critical: Verify ALL users have @biira.online UPN
$allUsers = Get-ADUser -Filter * -SearchBase "OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online" -Properties UserPrincipalName

# Check for incorrect UPNs
$incorrectUPN = $allUsers | Where-Object {$_.UserPrincipalName -notlike "*@biira.online"}

if ($incorrectUPN) {
    Write-Host "WARNING: Users with incorrect UPN:" -ForegroundColor Red
    $incorrectUPN | Select-Object Name, UserPrincipalName
} else {
    Write-Host "✅ All users have correct @biira.online UPN" -ForegroundColor Green
}
```

### Group Membership Verification

```powershell
# Verify OKTA sync group membership
$oktaGroupMembers = Get-ADGroupMember -Identity "SG-OKTA-AllUsers"

Write-Host "SG-OKTA-AllUsers has $($oktaGroupMembers.Count) members" -ForegroundColor Cyan

# List members
$oktaGroupMembers | 
    Get-ADUser -Properties EmailAddress | 
    Select-Object Name, SamAccountName, EmailAddress | 
    Format-Table -AutoSize
```

## Troubleshooting

### Issue: User created with wrong UPN

```powershell
# Fix UPN
Set-ADUser -Identity "username" -UserPrincipalName "username@biira.online"

# Verify
Get-ADUser "username" -Properties UserPrincipalName
```

### Issue: User not in OKTA sync group

```powershell
# Add to group
Add-ADGroupMember -Identity "SG-OKTA-AllUsers" -Members "username"

# Verify
Get-ADGroupMember -Identity "SG-OKTA-AllUsers" | Where-Object {$_.SamAccountName -eq "username"}
```

### Issue: Duplicate SamAccountName

```powershell
# Check if exists
Get-ADUser -Filter "SamAccountName -eq 'john.smith'"

# Use alternative naming
# john.m.smith (with middle initial)
# john.smith2 (with number)
```

## Checklist

- [ ] Test users created in appropriate OUs
- [ ] All users have @biira.online UPN
- [ ] Service account created (svc-okta-agent)
- [ ] All users added to SG-OKTA-AllUsers
- [ ] Users added to department groups
- [ ] Attributes populated (Department, Title, Email)
- [ ] PowerShell validation scripts run successfully

## Screenshots
_[Add screenshot: ADUC showing users in IT OU with @biira.online UPN]_
_[Add screenshot: User properties showing UPN configuration]_
_[Add screenshot: SG-OKTA-AllUsers members tab]_
_[Add screenshot: PowerShell output showing user verification]_

## Next Steps
- ✅ Users created and configured
- ✅ Service account ready
- ⏭️ **Next:** Install OKTA AD Agent (Phase 3)
- ⏭️ **Next:** Configure directory synchronization

---
**Status:** ✅ Complete  
**Date Completed:** October 2025  
**Documented by:** Noble W. Antwi