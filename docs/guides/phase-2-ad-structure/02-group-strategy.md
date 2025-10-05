# Phase 2: Security Group Strategy

## Overview
Enterprise security group design for OKTA integration, role-based access control, and resource management.

## Group Naming Conventions

### Standard Format
```
[Type]-[Purpose]-[Resource]
```

### Type Prefixes
| Prefix | Type | Scope | Purpose |
|--------|------|-------|---------|
| SG- | Security Group | Global | Access control |
| DL- | Distribution List | Universal | Email distribution |
| APP- | Application Group | Global | OKTA-managed apps |

### Examples
- `SG-OKTA-AllUsers` - Security group for OKTA sync
- `SG-Dept-IT` - IT department access group
- `SG-Resource-FileShare-Finance` - Finance file share access
- `DL-AllStaff` - Company-wide email distribution

## OKTA Integration Groups

### Critical OKTA Groups

**SG-OKTA-AllUsers**
- **Purpose:** Master sync scope for OKTA
- **OU:** ApplicationAccess
- **Members:** All users to sync to OKTA
- **Scope:** Global
- **Description:** All users synchronized to OKTA Universal Directory

**SG-OKTA-MFA-Exempt**
- **Purpose:** MFA exemption list
- **Members:** Service accounts, emergency access, VPN-only
- **OKTA Policy:** Exclude from MFA requirement
- **Use Case:** svc-okta-agent, emergency admin accounts

**SG-OKTA-Admins**
- **Purpose:** OKTA administrator access
- **Members:** IT administrators
- **OKTA Role:** Super Administrator
- **Access:** Full OKTA admin console

**SG-OKTA-AppAdmins**
- **Purpose:** Application administrators
- **Members:** Department app owners
- **OKTA Role:** Application Administrator
- **Access:** Manage app assignments, not org settings

**SG-OKTA-HelpDesk**
- **Purpose:** Helpdesk support access
- **Members:** IT support staff
- **OKTA Role:** Help Desk Administrator
- **Access:** Password resets, unlock users

### Creating OKTA Groups
```powershell
# Run from scripts/active-directory/
.\New-SecurityGroups.ps1

# Or manually:
$ouPath = "OU=ApplicationAccess,OU=SecurityGroups,OU=Groups,OU=BIIRA,DC=ad,DC=biira,DC=online"

New-ADGroup -Name "SG-OKTA-AllUsers" `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $ouPath `
            -Description "All users synchronized to OKTA (primary sync scope)"
```

## Department Access Groups

### Purpose
- User membership by department
- OKTA attribute sync (department field)
- Role-based access policies

### Standard Department Groups
```powershell
# Department access groups
$departments = @("Executive", "IT", "Finance", "HR", "Sales", "Marketing")
$ouPath = "OU=DepartmentAccess,OU=SecurityGroups,OU=Groups,OU=BIIRA,DC=ad,DC=biira,DC=online"

foreach ($dept in $departments) {
    New-ADGroup -Name "SG-Dept-$dept" `
                -GroupScope Global `
                -GroupCategory Security `
                -Path $ouPath `
                -Description "Access group for $dept department"
}
```

### Group Membership
| Group | Members | OKTA Use |
|-------|---------|----------|
| SG-Dept-IT | All IT employees | IT application access |
| SG-Dept-Finance | All Finance employees | Finance app access |
| SG-Dept-Sales | All Sales employees | Salesforce, CRM access |

## Application Access Groups

### SaaS Application Groups

**SG-App-Office365**
- **Purpose:** Microsoft 365 access
- **OKTA App:** Microsoft 365
- **Members:** All staff (nested from SG-OKTA-AllUsers)

**SG-App-Salesforce**
- **Purpose:** Salesforce CRM access
- **OKTA App:** Salesforce
- **Members:** Sales, Marketing, Executives

**SG-App-Workday**
- **Purpose:** Workday HCM access
- **OKTA App:** Workday
- **Members:** HR, Managers, Executives

**SG-App-GitHub**
- **Purpose:** GitHub Enterprise access
- **OKTA App:** GitHub
- **Members:** IT department, Developers

### Creating Application Groups
```powershell
$ouPath = "OU=ApplicationAccess,OU=SecurityGroups,OU=Groups,OU=BIIRA,DC=ad,DC=biira,DC=online"

$appGroups = @(
    @{Name="SG-App-Office365"; Desc="Microsoft 365 application access"},
    @{Name="SG-App-Salesforce"; Desc="Salesforce CRM access"},
    @{Name="SG-App-Workday"; Desc="Workday HCM access"}
)

foreach ($app in $appGroups) {
    New-ADGroup -Name $app.Name `
                -GroupScope Global `
                -GroupCategory Security `
                -Path $ouPath `
                -Description $app.Desc
}
```

## Resource Access Groups

### File Share Access (Domain Local)

**Why Domain Local?**
- Resource groups should be Domain Local scope
- Applied directly to NTFS permissions
- Can contain Global groups as members

**Standard Resource Groups:**
```powershell
$ouPath = "OU=ResourceAccess,OU=SecurityGroups,OU=Groups,OU=BIIRA,DC=ad,DC=biira,DC=online"

New-ADGroup -Name "SG-Resource-FileShare-IT" `
            -GroupScope DomainLocal `
            -GroupCategory Security `
            -Path $ouPath `
            -Description "IT department file share access"

New-ADGroup -Name "SG-Resource-FileShare-Finance" `
            -GroupScope DomainLocal `
            -GroupCategory Security `
            -Path $ouPath `
            -Description "Finance department file share access"
```

### AGDLP Best Practice
**Accounts → Global → Domain Local → Permissions**

Example for Finance file share:
1. **Accounts:** Individual users (john.smith, jane.doe)
2. **Global Group:** SG-Dept-Finance (contains users)
3. **Domain Local Group:** SG-Resource-FileShare-Finance (contains SG-Dept-Finance)
4. **Permissions:** Apply to file share (Grant SG-Resource-FileShare-Finance read/write)

## Distribution Lists

### Email Distribution Groups

**DL-AllStaff**
- **Purpose:** Company-wide announcements
- **Members:** All users (nested SG-OKTA-AllUsers)
- **Scope:** Universal (for Exchange)

**DL-IT-Team**
- **Purpose:** IT department email
- **Members:** IT department users
- **Scope:** Universal

### Creating Distribution Lists
```powershell
$ouPath = "OU=DistributionLists,OU=Groups,OU=BIIRA,DC=ad,DC=biira,DC=online"

New-ADGroup -Name "DL-AllStaff" `
            -GroupScope Universal `
            -GroupCategory Distribution `
            -Path $ouPath `
            -Description "Company-wide email distribution"
```

## Group Management

### Nesting Strategy

**Recommended Nesting:**
```
SG-OKTA-AllUsers (Global)
├── SG-Dept-IT (Global) → Contains IT users
├── SG-Dept-Finance (Global) → Contains Finance users
└── SG-Dept-Sales (Global) → Contains Sales users
```

**Application Access:**
```
SG-App-Salesforce (Global)
├── SG-Dept-Sales (nested)
└── SG-Dept-Marketing (nested)
```

### Dynamic Groups (Future)
PowerShell script to auto-populate:
```powershell
# Auto-add users to department group based on Department attribute
$itUsers = Get-ADUser -Filter "Department -eq 'IT'" -SearchBase "OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online"

foreach ($user in $itUsers) {
    Add-ADGroupMember -Identity "SG-Dept-IT" -Members $user
}
```

## OKTA Group Mapping

### Attribute Sync
When OKTA AD Agent syncs:

| AD Group | OKTA Group | OKTA Use |
|----------|------------|----------|
| SG-OKTA-AllUsers | AllUsers | Base sync scope |
| SG-Dept-IT | IT | Department-based rules |
| SG-App-Salesforce | Salesforce Users | App assignment |

### Group Rules in OKTA
OKTA can create dynamic groups based on AD attributes:
- `department = "IT"` → Add to IT OKTA group
- `title contains "Manager"` → Add to Managers group

## Validation

### List All Groups
```powershell
# All security groups in BIIRA
Get-ADGroup -Filter * -SearchBase "OU=Groups,OU=BIIRA,DC=ad,DC=biira,DC=online" | 
    Select-Object Name, GroupScope, GroupCategory | 
    Sort-Object Name

# OKTA-specific groups
Get-ADGroup -Filter "Name -like 'SG-OKTA-*'" | 
    Select-Object Name, Description
```

### Check Group Members
```powershell
# Members of OKTA AllUsers group
Get-ADGroupMember -Identity "SG-OKTA-AllUsers" | 
    Select-Object Name, SamAccountName

# Nested groups
Get-ADGroupMember -Identity "SG-OKTA-AllUsers" -Recursive
```

### Group Count
```powershell
# Count by category
$allGroups = Get-ADGroup -Filter * -SearchBase "OU=Groups,OU=BIIRA,DC=ad,DC=biira,DC=online"

$allGroups | Group-Object GroupCategory | 
    Select-Object Name, Count
```

## Checklist

- [ ] OKTA integration groups created
- [ ] Department access groups created
- [ ] Application access groups created
- [ ] Resource access groups created (Domain Local)
- [ ] Distribution lists created
- [ ] Groups in correct OUs
- [ ] Naming conventions followed

## Screenshots
_[Add screenshot: SecurityGroups OU showing all OKTA groups]_
_[Add screenshot: SG-OKTA-AllUsers properties]_
_[Add screenshot: PowerShell output listing all groups]_

## Next Steps
- ✅ Security groups created
- ⏭️ **Next:** Create test users (03-user-creation.md)
- ⏭️ **Next:** Populate group memberships

---
**Status:** ✅ Complete  
**Date Completed:** October 2025  
**Documented by:** Noble W. Antwi