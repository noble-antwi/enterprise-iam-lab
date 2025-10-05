# Phase 2: Active Directory Organizational Structure Implementation

## Executive Summary

I designed and implemented an enterprise-grade Active Directory organizational structure following Microsoft's tiered administrative model and industry best practices. The implementation includes 20 organizational units (OUs), 9 security groups for OKTA integration, and 27 test user accounts representing a realistic corporate environment.

**Key Achievements:**
- Implemented tiered administrative model (Tier 0/1/2) for enhanced security
- Designed scalable OU structure supporting 500-1000 user growth
- Created OKTA integration framework with proper sync scoping
- Automated bulk user provisioning using PowerShell
- Established department-based access control foundation

---

## OU Architecture Design & Implementation

### Design Rationale

I structured the Active Directory environment with a custom root OU named "BIIRA" to isolate all enterprise objects from default AD containers. This design follows Microsoft's recommended practice of separating production objects for cleaner Group Policy inheritance and administrative delegation.

### Implemented Hierarchy

**Final Structure:**

```
BIIRA (Root OU)
├── Users
│   ├── Employees
│   │   ├── Executive (4 users)
│   │   ├── IT (6 users)
│   │   ├── Finance (5 users)
│   │   ├── HR (3 users)
│   │   ├── Sales (5 users)
│   │   └── Marketing (4 users)
│   └── ServiceAccounts (1 account: svc-okta-agent)
│
├── Groups
│   ├── SecurityGroups (9 groups)
│   └── DistributionLists
│
├── Computers
│   ├── Workstations
│   └── Servers
│
└── Admin (Tiered Model)
    ├── Tier0-DomainAdmins
    ├── Tier1-ServerAdmins
    └── Tier2-WorkstationAdmins
```

### Automation Script

I automated the OU creation using PowerShell to ensure consistency and repeatability:

```powershell
# Enterprise OU Structure Creation
$domainDN = "DC=ad,DC=biira,DC=online"

$OUs = @(
    @{Name="BIIRA"; Path=$domainDN; Description="Biira Enterprise Root OU"},
    @{Name="Users"; Path="OU=BIIRA,$domainDN"; Description="All user accounts"},
    @{Name="Employees"; Path="OU=Users,OU=BIIRA,$domainDN"; Description="Corporate employees"},
    # ... (20 OUs total)
)

foreach ($OU in $OUs) {
    New-ADOrganizationalUnit -Name $OU.Name `
                             -Path $OU.Path `
                             -Description $OU.Description `
                             -ProtectedFromAccidentalDeletion $true
}
```

**Implementation Details:**
- Parent OUs created before child OUs to maintain hierarchy
- All OUs protected from accidental deletion
- Descriptions added for administrative documentation
- Error handling for existing OUs

### Results

The script successfully created all 20 organizational units in the correct hierarchical structure.

![Active Directory OU Hierarchy](<../../../assets/images/screenshots/phase-2/2. OU Creation Confirmation.png>)
*Figure 1: Complete BIIRA organizational unit hierarchy in Active Directory Users and Computers*

---

## Security Group Strategy & Implementation

### OKTA Integration Groups

I implemented three critical security groups to control OKTA synchronization and access:

**Script: Create-OktaGroups.ps1**

```powershell
$oktaGroups = @(
    @{Name="SG-OKTA-AllUsers"; Desc="All users synchronized to OKTA (primary sync scope)"},
    @{Name="SG-OKTA-Admins"; Desc="OKTA administrator console access"},
    @{Name="SG-OKTA-MFA-Exempt"; Desc="Users exempt from MFA requirements"}
)

foreach ($group in $oktaGroups) {
    New-ADGroup -Name $group.Name `
                -GroupScope Global `
                -GroupCategory Security `
                -Path "OU=SecurityGroups,OU=Groups,OU=BIIRA,$domainDN" `
                -Description $group.Desc
}
```

**Group Functions:**

**SG-OKTA-AllUsers:** Acts as the master filter for OKTA AD Agent synchronization. Only members of this group sync to OKTA cloud, preventing service accounts and admin accounts from unnecessary cloud provisioning. This approach reduces OKTA licensing costs and maintains a clean cloud directory.

**SG-OKTA-Admins:** Controls OKTA administrative console access. Members are mapped to the OKTA "Super Administrator" role during agent configuration, enabling least-privilege access management.

**SG-OKTA-MFA-Exempt:** Exempts specific accounts from Multi-Factor Authentication requirements. Critical for service accounts that cannot use MFA (automated processes) and emergency break-glass accounts.

### Department Access Groups

I created department-specific security groups for role-based access control:

**Script: Department_Group_Creation.ps1**

```powershell
$departments = @("IT", "Finance", "HR", "Sales", "Marketing", "Executive")

foreach ($dept in $departments) {
    New-ADGroup -Name "SG-Dept-$dept" `
                -GroupScope Global `
                -GroupCategory Security `
                -Description "$dept department access group"
}
```

These groups provide the foundation for RBAC, resource permissions, and application access management.

### Implementation Results

All security groups were successfully created and organized within the SecurityGroups OU.

![Security Groups in Active Directory](<../../../assets/images/screenshots/phase-2/6. Groups Created.png>)
*Figure 2: SecurityGroups OU displaying all 9 security groups - 3 OKTA integration groups (SG-OKTA-AllUsers, SG-OKTA-Admins, SG-OKTA-MFA-Exempt) and 6 department access groups (SG-Dept-Executive, Finance, HR, IT, Marketing, Sales). Each group includes descriptive metadata for administrative clarity.*

---

## User Provisioning & Automation

### Bulk User Creation Strategy

I implemented a CSV-based bulk user provisioning process to efficiently create 25 test users representing a realistic enterprise environment.

**CSV Source File: biira_employees.csv**

Location: `assets/csv/biira_employees.csv` "[csv](../../../assets/csv/biira_employees.csv)"

```csv
FirstName,LastName,Department,Title,Email
Michael,Johnson,Sales,Sales Manager,michael.johnson@biira.online
David,Brown,Executive,Chief Technology Officer,david.brown@biira.online
Emily,Davis,IT,Network Engineer,emily.davis@biira.online
...
```

### Automation Script

**Script: Bulk-CreateUsers.ps1**

```powershell
$users = Import-Csv "C:\Users\scripts\biira_employees.csv"
$domainDN = "DC=ad,DC=biira,DC=online"

foreach ($user in $users) {
    $username = "$($user.FirstName).$($user.LastName)".ToLower()
    $ou = "OU=$($user.Department),OU=Employees,OU=Users,OU=BIIRA,$domainDN"
    
    # Create user with proper UPN
    New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
               -SamAccountName $username `
               -UserPrincipalName $user.Email `
               -EmailAddress $user.Email `
               -Title $user.Title `
               -Department $user.Department `
               -Path $ou `
               -AccountPassword (ConvertTo-SecureString "Removed it" -AsPlainText -Force) `
               -Enabled $true
    
    # Automatic group membership
    Add-ADGroupMember -Identity "SG-OKTA-AllUsers" -Members $username
    Add-ADGroupMember -Identity "SG-Dept-$($user.Department)" -Members $username
}
```

**Script Logic:**

1. **Username Generation:** Creates standardized usernames in `firstname.lastname` format (lowercase) from CSV data
2. **Dynamic OU Placement:** Reads department from CSV and constructs the correct OU path automatically
3. **UPN Configuration:** Sets UserPrincipalName to `@biira.online` (not `@ad.biira.online`) to match public domain for clean OKTA login experience
4. **Automatic Group Assignment:** Adds each user to both `SG-OKTA-AllUsers` (OKTA sync scope) and their department group

### Provisioning Results

The script successfully created 25 users from the CSV file, automatically placing them in the correct departmental OUs and assigning appropriate group memberships.

![PowerShell Bulk User Creation](<../../../assets/images/screenshots/phase-2/1. Bulk User Creation.png>)
*Figure 3: PowerShell script execution output showing successful creation of 25 users from CSV file. Each user was automatically placed in their department OU and added to both SG-OKTA-AllUsers and their department security group. Summary displays 27 total users in SG-OKTA-AllUsers (25 from bulk import + 2 manually created) distributed across 6 departments: Executive (4), Finance (5), HR (3), IT (6), Marketing (4), Sales (5).*

---

## Service Account Configuration

### OKTA AD Agent Service Account

I created a dedicated service account for OKTA AD Agent authentication with appropriate security settings:

**Account: svc-okta-agent**

```powershell
New-ADUser -Name "svc-okta-agent" `
           -SamAccountName "svc-okta-agent" `
           -UserPrincipalName "svc-okta-agent@biira.online" `
           -DisplayName "OKTA AD Agent Service Account" `
           -Description "Service account for OKTA AD synchronization" `
           -Path "OU=ServiceAccounts,OU=Users,OU=BIIRA,$domainDN" `
           -AccountPassword (ConvertTo-SecureString "I removed it" -AsPlainText -Force) `
           -Enabled $true `
           -PasswordNeverExpires $true `
           -CannotChangePassword $true
```

**Configuration Rationale:**
- **PasswordNeverExpires:** Service accounts require stable credentials; password rotation would break OKTA sync
- **CannotChangePassword:** Prevents accidental password changes that would disrupt synchronization
- **Isolated OU:** Separated from regular users for distinct GPO application
- **Excluded from OKTA sync:** Not a member of `SG-OKTA-AllUsers` - stays local to AD

![Service Account Properties](<../../../assets/images/screenshots/phase-2/7. OKTA Service Account.png>)

*Figure 4: OKTA AD Agent service account (svc-okta-agent) properties showing critical security settings. Account tab displays "Password never expires" and "User cannot change password" options enabled, ensuring stable authentication for OKTA AD Agent. The account is located in the ServiceAccounts OU, isolated from regular user accounts for distinct policy application.*

---

## OKTA Synchronization Scope

### Group Membership Verification

With all users provisioned, I verified that the OKTA sync scope is properly configured. The SG-OKTA-AllUsers group now contains all 27 employee accounts, ready for OKTA AD Agent synchronization.

![SG-OKTA-AllUsers Group Membershipt](<../../../assets/images/screenshots/phase-2/11. SG-OkTA-AllUsers.png>)
*Figure 5: SG-OKTA-AllUsers security group Members tab showing all 27 user accounts ready for OKTA synchronization. The member list includes users from all departments (Executive, Finance, HR, IT, Marketing, Sales), each with their @biira.online email address configured. The service account (svc-okta-agent) is correctly excluded from this group, preventing unnecessary cloud provisioning.*

### User Attribute Configuration

All users were provisioned with complete attributes required for OKTA synchronization:

![User Account Configuration](<../../../assets/images/screenshots/phase-2/9. John Smith in the IT Departmtnet.png>)
*Figure 6: Sample user account (John Smith) properties displaying the Account tab. The critical configuration shows UserPrincipalName set to john.smith@biira.online and Email address matching the UPN. This @biira.online suffix (not @ad.biira.online) is essential for OKTA integration - it serves as the login identifier in OKTA and matches the organization's public domain for a professional SSO experience.*

**Key Attributes Configured:**

| Attribute | Purpose | Example Value |
|-----------|---------|---------------|
| UserPrincipalName | OKTA login identifier | john.smith@biira.online |
| EmailAddress | Email field in OKTA profile | john.smith@biira.online |
| Department | Organizational mapping | IT, Finance, Sales, etc. |
| Title | Job title in OKTA | Systems Administrator |
| MemberOf | Group-based provisioning | SG-OKTA-AllUsers, SG-Dept-IT |

---

## UPN Suffix Strategy (Split-Brain DNS)

### Architecture Design

I implemented a split-brain DNS design separating internal AD infrastructure from user-facing cloud services:

**Internal Domain:** `ad.biira.online`
- AD forest root domain
- Used for computer authentication and Kerberos
- Internal DNS resolution only
- Not exposed to users

**Public UPN Suffix:** `biira.online`
- Alternative UPN suffix added to AD forest
- Used for all user account logins
- Matches public domain for professional appearance
- Enables seamless OKTA/cloud SSO

**Business Value:**
- Users experience clean login: `john.smith@biira.online`
- Internal domain structure hidden from end users
- Professional external-facing identity
- Simplified cloud service integration

---

## Implementation Summary

### Final Environment Statistics

**Organizational Units:** 20
- Users (with 6 departmental sub-OUs + Employees + ServiceAccounts)
- Groups (SecurityGroups + DistributionLists)
- Computers (Workstations + Servers)
- Admin (Tier0/1/2)

**Security Groups:** 9
- 3 OKTA integration groups
- 6 department access groups

**User Accounts:** 27 total
- 26 employee accounts across 6 departments
- 1 service account (svc-okta-agent)

### User Distribution by Department

| Department | User Count | Example Users |
|-----------|-----------|---------------|
| Executive | 4 | David Brown (CTO), Jessica Clark (CFO), Laura King (COO), Stephanie Adams (CMO) |
| IT | 6 | John Smith, Emily Davis, Christopher Garcia, Matthew Harris, Kevin Hall, Justin Hill |
| Finance | 5 | Sarah Williams, Robert Martinez, Jennifer Rodriguez, Nicole Allen, Rachel Scott |
| HR | 3 | Mary Taylor, Amanda Walker, Tyler Green |
| Sales | 5 | Michael Johnson, James Wilson, Daniel Lee, Andrew Lewis, Brandon Wright |
| Marketing | 4 | Lisa Anderson, Patricia White, Ryan Young, Michelle Lopez |

---

## Technical Validation

### PowerShell Verification

**OU Count Verification:**
```powershell
(Get-ADOrganizationalUnit -Filter * -SearchBase "OU=BIIRA,DC=ad,DC=biira,DC=online").Count
# Result: 20 OUs
```

**User Count Verification:**
```powershell
(Get-ADUser -Filter * -SearchBase "OU=Employees,OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online").Count
# Result: 27 users
```

**OKTA Sync Group Verification:**
```powershell
(Get-ADGroupMember -Identity "SG-OKTA-AllUsers").Count
# Result: 27 members
```

**UPN Suffix Verification:**
```powershell
Get-ADUser -Filter * -SearchBase "OU=Employees,OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online" -Properties UserPrincipalName | 
    Where-Object {$_.UserPrincipalName -notlike "*@biira.online"}
# Result: Empty (all users have correct UPN)
```

All validation checks passed successfully, confirming proper implementation.

---

## Security & Best Practices

### Implemented Security Controls

**1. Tiered Administrative Model**
- Tier 0: Domain controllers, forest admins (highest privilege)
- Tier 1: Server infrastructure administrators
- Tier 2: Workstation support staff (lowest privilege)
- Prevents privilege escalation and lateral movement attacks

**2. OU Protection**
- All OUs created with `-ProtectedFromAccidentalDeletion $true`
- Prevents accidental deletion and data loss
- Protects GPO structure integrity

**3. Service Account Isolation**
- Dedicated ServiceAccounts OU for non-human accounts
- Excluded from OKTA sync scope
- Separate password policies applied via GPO

**4. Naming Standards**
- Users: `firstname.lastname` (lowercase)
- Security Groups: `SG-[Purpose]-[Resource]`
- Service Accounts: `svc-[application]-[purpose]`
- OUs: PascalCase, descriptive

### OKTA Integration Architecture

**Sync Scope Design:**

What Syncs to OKTA:
- All users in `SG-OKTA-AllUsers` group (27 users)
- Department groups for role-based provisioning
- User attributes: UPN, email, department, title

What Does NOT Sync:
- Service accounts (svc-okta-agent)
- Administrative tier accounts
- Default AD containers

**Benefits:**
- Clean OKTA directory (only real users)
- License optimization (pay only for actual users)
- Enhanced security (admin accounts managed separately)
- Scalable provisioning (group-based control)

---

## Lessons Learned

### Successful Approaches

**PowerShell Automation:**
- Reduced manual effort from hours to minutes
- Ensured consistency across all objects
- Created repeatable process for future deployments
- Minimized human error in bulk operations

**Group-Based Sync Scoping:**
- Clean separation between synced and local-only accounts
- Simplified OKTA provisioning through group membership
- Scalable approach for enterprise (1,000+ users)
- Easy to add/remove users from cloud sync

**Tiered Admin Model:**
- Enterprise-grade security from initial implementation
- Aligned with Microsoft security best practices
- Foundation for advanced security (PAW, JIT access)

### Challenges Addressed

**Challenge:** Ensuring consistent UPN suffix across all users
**Solution:** Automated UPN assignment in bulk user script using email field from CSV

**Challenge:** Managing group memberships at scale
**Solution:** Script automatically assigns users to appropriate groups during account creation

**Challenge:** Organizing users across multiple departments
**Solution:** CSV-based provisioning with dynamic OU placement logic

---

## Next Steps: Phase 3 - OKTA Integration

With the Active Directory foundation complete, Phase 3 will focus on OKTA integration:

**1. OKTA AD Agent Installation**
- Install agent on srv1 (Domain Controller)
- Configure service account authentication (svc-okta-agent)
- Set sync scope: `OU=Employees,OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online`

**2. Directory Synchronization**
- Configure attribute mapping (AD ↔ OKTA)
- Set sync schedule (15-minute intervals)
- Execute initial full sync of 27 users

**3. Group-Based Provisioning**
- Map department groups to OKTA applications
- Configure MFA policies with exemptions
- Implement conditional access rules

**4. Validation & Testing**
- Verify all 27 users sync successfully to OKTA
- Confirm UPN format in OKTA (username@biira.online)
- Test group membership propagation
- Validate MFA exemptions for service accounts
- Test SSO with sample users

---

## Conclusion

I successfully designed and implemented an enterprise-grade Active Directory organizational structure that provides a solid foundation for hybrid identity management. The implementation demonstrates:

- Scalable architecture supporting 500-1000 user growth
- Microsoft tiered administrative security model
- Clean OKTA integration architecture with proper sync boundaries
- PowerShell automation for consistency and repeatability
- Industry-standard naming conventions and best practices
- Proper separation of service accounts and user accounts
- Professional UPN configuration for cloud SSO experience

The environment is now ready for OKTA AD Agent deployment and directory synchronization, completing the hybrid identity architecture.

---

**Implementation Details:**
- **Total Objects Created:** 56 (20 OUs + 9 Groups + 27 Users)
- **Automation Scripts:** 4 PowerShell scripts developed
- **Documentation:** Complete implementation guide with validation procedures
- **Status:** Phase 2 Complete 
