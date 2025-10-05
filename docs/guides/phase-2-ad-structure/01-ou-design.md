# Phase 2: Active Directory OU Design

## Overview
Enterprise-grade Organizational Unit (OU) structure for OKTA integration and role-based access control.

## OU Design Principles

### Why Proper OU Structure Matters
1. **Group Policy Application:** Targeted GPO deployment
2. **Delegation:** Granular administrative permissions
3. **OKTA Sync Scope:** Define what syncs to cloud
4. **Scalability:** Support growth from 100 to 10,000+ users
5. **Security:** Implement tiered admin model

### Design Philosophy
- **Isolation:** Separate custom objects from default containers
- **Simplicity:** Logical, intuitive structure
- **Consistency:** Follow naming conventions
- **Protection:** Enable accidental deletion protection

## Enterprise OU Hierarchy

### Full Structure
```
ad.biira.online
│
├── Domain Controllers (default)
├── Computers (default)
├── Users (default)
│
└── BIIRA (Root custom OU)
    │
    ├── Users
    │   ├── Corporate
    │   │   ├── Executive
    │   │   ├── IT
    │   │   ├── Finance
    │   │   ├── HR
    │   │   ├── Sales
    │   │   └── Marketing
    │   ├── Contractors
    │   └── ServiceAccounts
    │
    ├── Groups
    │   ├── SecurityGroups
    │   │   ├── DepartmentAccess
    │   │   ├── ApplicationAccess
    │   │   └── ResourceAccess
    │   └── DistributionLists
    │
    ├── Computers
    │   ├── Workstations
    │   ├── Servers
    │   └── MobileDevices
    │
    ├── Resources
    │   ├── SharedFolders
    │   └── Printers
    │
    └── Admin
        ├── Tier0-DomainAdmins
        ├── Tier1-ServerAdmins
        └── Tier2-WorkstationAdmins
```

## OU Descriptions

### Root: BIIRA
- **Purpose:** Container for all custom enterprise objects
- **Protection:** Enabled (prevent accidental deletion)
- **GPO Link:** Company-wide baseline policies

### Users OUs

**BIIRA\Users**
- **Purpose:** All user accounts
- **Sub-structure:** By employment type and department

**BIIRA\Users\Corporate**
- **Purpose:** Full-time employees
- **Sub-OUs:** Departmental (Executive, IT, Finance, HR, Sales, Marketing)
- **GPO:** Standard user policies

**BIIRA\Users\Contractors**
- **Purpose:** Temporary and contract workers
- **GPO:** Restricted access policies, auto-expiration

**BIIRA\Users\ServiceAccounts**
- **Purpose:** Application and service accounts
- **Naming:** svc-application-purpose
- **GPO:** No password expiration, no interactive logon

### Groups OUs

**BIIRA\Groups\SecurityGroups**
- **Purpose:** Access control groups
- **Categories:**
  - DepartmentAccess: Department membership groups
  - ApplicationAccess: SaaS/application access (OKTA sync)
  - ResourceAccess: File shares, printers

**BIIRA\Groups\DistributionLists**
- **Purpose:** Email distribution groups
- **Examples:** DL-AllStaff, DL-IT-Team

### Computers OUs

**BIIRA\Computers\Workstations**
- **Purpose:** User desktops and laptops
- **GPO:** Desktop security baseline, software deployment

**BIIRA\Computers\Servers**
- **Purpose:** Member servers (non-DC)
- **GPO:** Server hardening, monitoring

**BIIRA\Computers\MobileDevices**
- **Purpose:** Tablets, smartphones (if hybrid-joined)
- **GPO:** Mobile device management policies

### Admin OUs (Tiered Model)

**BIIRA\Admin\Tier0-DomainAdmins**
- **Purpose:** Domain Admin and Enterprise Admin accounts
- **Access:** Full domain control
- **GPO:** Maximum security, PAW requirements

**BIIRA\Admin\Tier1-ServerAdmins**
- **Purpose:** Server administrator accounts
- **Access:** Server infrastructure only
- **GPO:** Elevated security, jump server restrictions

**BIIRA\Admin\Tier2-WorkstationAdmins**
- **Purpose:** Helpdesk and workstation admin accounts
- **Access:** Workstation support only
- **GPO:** Standard admin security

## Creating the OU Structure

### Option 1: Manual Creation (GUI)

**Step-by-step:**
1. Open: Active Directory Users and Computers (ADUC)
2. Right-click domain → New → Organizational Unit
3. Name: BIIRA
4. ✅ Check: "Protect container from accidental deletion"
5. Repeat for all sub-OUs

### Option 2: Automated (PowerShell)

**Use provided script:**
```powershell
# Run from scripts/active-directory/ folder
.\Create-OUStructure.ps1

# Preview changes first
.\Create-OUStructure.ps1 -WhatIf
```

**Script creates:**
- All 25+ OUs in correct hierarchy
- Accidental deletion protection enabled
- Descriptions and metadata

## OKTA Integration Considerations

### Sync Scope Definition

**What to sync to OKTA:**
```
✅ Sync: BIIRA\Users\Corporate\*
✅ Sync: BIIRA\Users\Contractors
❌ Do NOT sync: BIIRA\Users\ServiceAccounts
❌ Do NOT sync: BIIRA\Admin\*
```

**Why this scope:**
- Service accounts don't need OKTA access
- Admin accounts managed separately (PAW model)
- Contractors get limited OKTA access

### OKTA AD Agent Configuration
The OU structure supports:
- Selective synchronization
- User filtering by OU
- Group-based provisioning
- Attribute mapping per OU

## Group Policy Linking Strategy

### Recommended GPO Links

| OU | GPO | Purpose |
|----|-----|---------|
| BIIRA | BIIRA-Baseline-Security | Company-wide settings |
| Users\Corporate | BIIRA-User-Standard | Standard user restrictions |
| Users\ServiceAccounts | BIIRA-ServiceAccount-Policy | Service account settings |
| Computers\Workstations | BIIRA-Workstation-Security | Desktop hardening |
| Admin\Tier0 | BIIRA-Admin-Tier0 | PAW enforcement |

### GPO Inheritance
```
BIIRA (Baseline) 
  ↓ Inherited by all child OUs
  ↓ Can be overridden by more specific GPOs
  └─ Users\Corporate (adds user-specific policies)
```

## Naming Conventions

### OU Naming
- **Format:** PascalCase
- **Examples:** Users, Corporate, ServiceAccounts
- **Avoid:** Spaces, special characters

### User Placement Rules
| User Type | OU Path | Example |
|-----------|---------|---------|
| IT Employee | Corporate\IT | john.smith@biira.online |
| Contractor | Contractors | jane.doe@biira.online |
| Service Account | ServiceAccounts | svc-okta-agent@biira.online |
| Domain Admin | Admin\Tier0 | admin-jsmith@biira.online |

## Validation

### PowerShell Verification
```powershell
# List all BIIRA OUs
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=BIIRA,DC=ad,DC=biira,DC=online" | 
    Select-Object Name, DistinguishedName | 
    Sort-Object DistinguishedName

# Check protection status
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=BIIRA,DC=ad,DC=biira,DC=online" -Properties ProtectedFromAccidentalDeletion | 
    Select-Object Name, ProtectedFromAccidentalDeletion

# Count OUs
(Get-ADOrganizationalUnit -Filter * -SearchBase "OU=BIIRA,DC=ad,DC=biira,DC=online").Count
```

### Expected Results
- Total OUs: 25+
- All protected from deletion: True
- Hierarchy depth: 4 levels maximum

## Screenshots
_[Add screenshot: ADUC showing BIIRA OU tree fully expanded]_
_[Add screenshot: OU properties showing protection enabled]_
_[Add screenshot: PowerShell output listing all OUs]_

## Next Steps
- ✅ OU structure designed
- ⏭️ **Next:** Create security groups (02-group-strategy.md)
- ⏭️ **Next:** Create test users (03-user-creation.md)

---
**Status:** ✅ Complete  
**Date Completed:** October 2025  
**Documented by:** Noble W. Antwi