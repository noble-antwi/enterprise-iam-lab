# Enterprise IAM Lab - Implementation Guide

> **Quick start guide to implement the complete Active Directory and OKTA integration**

## 🎯 What You're Building

A production-ready IAM environment with:
- ✅ Windows Server 2022 Domain Controller
- ✅ Active Directory with 500-1000 user structure
- ✅ OKTA integration for cloud SSO
- ✅ Enterprise security groups and OUs
- ✅ Documentation for portfolio/GitHub

---

## 📋 Implementation Phases

### ✅ Phase 1: Foundation (COMPLETE)
**Status:** Already done ✓

**What you've built:**
- srv1 Domain Controller (192.168.50.2)
- Domain: ad.biira.online
- UPN Suffix: biira.online configured
- OKTA Integrator tenant provisioned

**Documentation:**
- `docs/guides/phase-1-foundation/01-server-deployment.md`
- `docs/guides/phase-1-foundation/02-ad-domain-setup.md`
- `docs/guides/phase-1-foundation/03-dns-configuration.md`

---

### 🔄 Phase 2: AD Structure (IN PROGRESS)
**Status:** Documentation ready, implementation needed

#### Step 1: Create OU Structure (30 minutes)

**Option A - Automated (Recommended):**
```powershell
# On srv1, run:
cd C:\enterprise-iam-lab\scripts\active-directory
.\Create-OUStructure.ps1
```

**Option B - Manual:**
Follow: `docs/guides/phase-2-ad-structure/01-ou-design.md`

**Validation:**
```powershell
# Verify OUs created
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=BIIRA,DC=ad,DC=biira,DC=online" | 
    Select-Object Name | 
    Sort-Object Name
```

#### Step 2: Create Security Groups (15 minutes)

```powershell
# Run script
cd C:\enterprise-iam-lab\scripts\active-directory
.\New-SecurityGroups.ps1
```

**Critical groups created:**
- SG-OKTA-AllUsers (main sync scope)
- SG-OKTA-Admins
- SG-Dept-IT, SG-Dept-Finance, etc.

**Validation:**
```powershell
Get-ADGroup -Filter "Name -like 'SG-OKTA-*'"
```

#### Step 3: Create Users (20 minutes)

**Create CSV file:**
1. Copy template from `configs/templates/user-template.csv`
2. Add your test users (minimum 10)

**Run bulk creation:**
```powershell
cd C:\enterprise-iam-lab\scripts\active-directory
.\New-BulkUsers.ps1
```

**Validation:**
```powershell
# Verify users
Get-ADUser -Filter * -SearchBase "OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online" -Properties UserPrincipalName | 
    Select-Object Name, UserPrincipalName

# Check SG-OKTA-AllUsers membership
Get-ADGroupMember -Identity "SG-OKTA-AllUsers"
```

**Documentation:**
- `docs/guides/phase-2-ad-structure/01-ou-design.md`
- `docs/guides/phase-2-ad-structure/02-group-strategy.md`
- `docs/guides/phase-2-ad-structure/03-user-creation.md`

---

### 📋 Phase 3: OKTA Integration (NEXT)
**Status:** Ready to start after Phase 2

#### Prerequisites:
- ✅ AD OU structure created
- ✅ SG-OKTA-AllUsers group populated
- ✅ svc-okta-agent service account created
- ✅ Test users have @biira.online UPN

#### Implementation Steps:

**1. Download OKTA AD Agent**
- Log into OKTA Admin Console
- Navigate to: Directory → Directory Integrations
- Click: Add Active Directory
- Download AD Agent installer

**2. Install AD Agent (on srv1)**
```
- Run installer as Domain Admin
- Connect to OKTA tenant
- Use svc-okta-agent for AD authentication
- Configure sync scope: OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online
```

**3. Configure Attribute Mapping**
- Map AD attributes to OKTA profile
- Key mappings:
  - userPrincipalName → login
  - mail → email
  - department → department
  - title → title

**4. Initial Sync**
- Start manual sync
- Verify users appear in OKTA
- Check group memberships

**Documentation:** (Create next)
- `docs/guides/phase-3-okta-integration/01-okta-agent-install.md`
- `docs/guides/phase-3-okta-integration/02-directory-sync.md`

---

## 🚀 Quick Commands Reference

### Active Directory

**Check domain status:**
```powershell
Get-ADDomain
dcdiag /v
```

**List all users:**
```powershell
Get-ADUser -Filter * -SearchBase "OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online"
```

**List all groups:**
```powershell
Get-ADGroup -Filter * -SearchBase "OU=Groups,OU=BIIRA,DC=ad,DC=biira,DC=online"
```

**Verify OKTA sync group:**
```powershell
Get-ADGroupMember -Identity "SG-OKTA-AllUsers"
```

### OKTA

**Access admin console:**
```
https://integrator-9057042-admin.okta.com
```

**Check sync status:**
- Directory → Directory Integrations → Active Directory

**View synced users:**
- Directory → People

---

## 📸 Screenshot Checklist

### Phase 2 Screenshots Needed:

**AD Structure:**
- [ ] ADUC showing BIIRA OU tree expanded
- [ ] Corporate departmental OUs
- [ ] SecurityGroups OU with OKTA groups
- [ ] Service account (svc-okta-agent) properties

**Users & Groups:**
- [ ] Test users in IT OU showing @biira.online UPN
- [ ] User properties showing UPN configuration
- [ ] SG-OKTA-AllUsers members tab
- [ ] PowerShell output showing user verification

**Save to:** `assets/images/screenshots/`

---

## ✅ Validation Checklist

Before proceeding to Phase 3:

**Active Directory:**
- [ ] All OUs created under BIIRA
- [ ] All security groups created
- [ ] SG-OKTA-AllUsers exists
- [ ] Test users created (minimum 10)
- [ ] All users have @biira.online UPN
- [ ] Users are members of SG-OKTA-AllUsers
- [ ] svc-okta-agent service account exists
- [ ] PowerShell scripts run without errors

**OKTA:**
- [ ] OKTA tenant accessible
- [ ] Custom branding configured (biira.online)
- [ ] Ready for AD Agent installation

**Documentation:**
- [ ] Phase 1 docs complete
- [ ] Phase 2 docs complete
- [ ] Screenshots captured
- [ ] All committed to GitHub

---

## 🆘 Troubleshooting

### Issue: OUs not appearing in ADUC
**Solution:**
```powershell
# Refresh ADUC (F5) or restart
# Verify with PowerShell
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=BIIRA,DC=ad,DC=biira,DC=online"
```

### Issue: Users have wrong UPN
**Solution:**
```powershell
# Fix individual user
Set-ADUser -Identity "username" -UserPrincipalName "username@biira.online"

# Fix all users
$users = Get-ADUser -Filter * -SearchBase "OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online"
foreach ($user in $users) {
    $newUPN = "$($user.SamAccountName)@biira.online"
    Set-ADUser -Identity $user -UserPrincipalName $newUPN
}
```

### Issue: Script execution blocked
**Solution:**
```powershell
# Set execution policy (on srv1)
Set-ExecutionPolicy RemoteSigned -Force

# Unblock downloaded scripts
Unblock-File -Path ".\Create-OUStructure.ps1"
```

---

## 📊 Current Progress

```
Phase 1: Foundation           ████████████████████ 100% ✅
Phase 2: AD Structure         ████████░░░░░░░░░░░░  40% 🔄
Phase 3: OKTA Integration     ░░░░░░░░░░░░░░░░░░░░   0% 📋
Phase 4: Advanced Security    ░░░░░░░░░░░░░░░░░░░░   0% 📋
Phase 5: Entra ID            ░░░░░░░░░░░░░░░░░░░░   0% 📋
```

---

## 🎯 Immediate Next Steps

**RIGHT NOW:**
1. Run `Create-OUStructure.ps1` on srv1
2. Run `New-SecurityGroups.ps1` on srv1  
3. Create user CSV file
4. Run `New-BulkUsers.ps1` on srv1
5. Take screenshots
6. Commit to GitHub

**THEN:**
1. Download OKTA AD Agent
2. Install on srv1
3. Configure sync
4. Test first sync

---

## 📚 Documentation Structure

```
enterprise-iam-lab/
├── README.md                          # ← Update with progress
├── IMPLEMENTATION-GUIDE.md            # ← This file (quick reference)
│
├── docs/
│   ├── guides/
│   │   ├── phase-1-foundation/        # ✅ Complete
│   │   ├── phase-2-ad-structure/      # 🔄 In progress  
│   │   └── phase-3-okta-integration/  # 📋 Coming next
│   │
│   └── reference/
│       ├── naming-conventions.md
│       └── service-accounts.md
│
├── scripts/
│   └── active-directory/
│       ├── Create-OUStructure.ps1
│       ├── New-SecurityGroups.ps1
│       └── New-BulkUsers.ps1
│
└── configs/
    └── templates/
        └── user-template.csv
```

---

## 🎓 Learning Resources

**Active Directory:**
- [Microsoft AD Best Practices](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/)
- [AD OU Design Guide](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc771547(v=ws.10))

**OKTA:**
- [OKTA AD Agent Docs](https://help.okta.com/en-us/content/topics/directory/ad-agent-main.htm)
- [OKTA Directory Integration](https://developer.okta.com/docs/guides/directory-integration/)

**PowerShell:**
- [AD PowerShell Module](https://learn.microsoft.com/en-us/powershell/module/activedirectory/)

---

**Last Updated:** October 2025  
**Next Milestone:** Complete Phase 2 AD Structure  
**Status:** Ready for implementation 🚀