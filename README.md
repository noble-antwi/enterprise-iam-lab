# Enterprise IAM Lab: Hybrid Identity Architecture

> **Building production-ready Identity and Access Management skills through hands-on implementation**  
> A comprehensive homelab demonstrating enterprise-grade IAM integration using Active Directory, OKTA, and Microsoft Entra ID

[![Lab Status](https://img.shields.io/badge/Status-Phase%202%20Complete-brightgreen)]()
[![AD Domain](https://img.shields.io/badge/AD%20Domain-ad.biira.online-blue)]()
[![OKTA](https://img.shields.io/badge/OKTA-Integrator%20Tenant-00297A)]()

---

## Project Vision

This repository chronicles my journey building a **500-1000 user enterprise IAM environment** from scratch. The lab simulates a medium-sized organization's identity infrastructure, implementing industry best practices for hybrid identity, zero-trust security, and modern access management.

**Real-World Application**: Every configuration, script, and architectural decision mirrors production enterprise environments - making this directly applicable to Fortune 500 IAM implementations.

---

## Architecture Overview

### Hybrid Identity Design

```
┌─────────────────────────────────────────────────────────────┐
│                    INTERNET / CLOUD                         │
│                                                             │
│  ┌──────────────┐              ┌──────────────────────┐   │
│  │   OKTA       │◄────────────►│  Microsoft Entra ID  │   │
│  │  (Primary    │   Federation │    (Azure AD)        │   │
│  │   IdP)       │              │                      │   │
│  └──────┬───────┘              └──────────────────────┘   │
│         │                                                   │
│         │ OKTA AD Agent                                    │
│         │ (Secure Tunnel)                                  │
└─────────┼───────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                 ON-PREMISES HOMELAB                         │
│                                                             │
│  ┌────────────────────────────────────────────────────┐   │
│  │  Active Directory Domain: ad.biira.online          │   │
│  │  UPN Suffix: biira.online                          │   │
│  │                                                    │   │
│  │  ┌──────────────┐         ┌──────────────────┐   │   │
│  │  │   srv1       │         │  Future:         │   │   │
│  │  │  (Domain     │         │  - srv2 (Replica │   │   │
│  │  │   Controller)│         │    DC)           │   │   │
│  │  │              │         │  - CA Server     │   │   │
│  │  │  192.168.50.2│         │  - ADFS (if req) │   │   │
│  │  └──────────────┘         └──────────────────┘   │   │
│  │                                                    │   │
│  └────────────────────────────────────────────────────┘   │
│                                                             │
│  Network: 192.168.50.0/24 (Management VLAN)                │
└─────────────────────────────────────────────────────────────┘
```

![Architectural Diagram](<assets/images/Architectural Diagram/ArchitecturalDiagram.png>)

### Domain Architecture: The Two Domains Explained

| Aspect | `ad.biira.online` | `biira.online` |
|--------|-------------------|----------------|
| **Type** | Active Directory Domain (Internal) | UPN Suffix + Public Domain |
| **Scope** | Homelab network only | Internet-routable |
| **Purpose** | AD forest root, computer auth | User-facing logins, SSO |
| **DNS** | Internal DNS on srv1 | Namecheap public DNS |
| **Example Use** | `AD\jsmith` login on domain PC | `jsmith@biira.online` OKTA login |
| **Kerberos Realm** | AD.BIIRA.ONLINE | N/A (UPN only) |

**Why This Matters**: This split-brain DNS design is enterprise-standard. Users authenticate with friendly `@biira.online` UPNs while AD internally uses `ad.biira.online` - enabling seamless cloud SSO without exposing internal domain structure.

---

## Technology Stack

### Identity & Directory Services
| Component | Technology | Status | Purpose |
|-----------|------------|--------|---------|
| **On-Prem Directory** | Windows Server 2022 Active Directory |  Deployed | User/computer management, GPOs |
| **Primary Cloud IdP** | OKTA Universal Directory |  Configured | SSO, MFA, adaptive auth |
| **Secondary Cloud IdP** | Microsoft Entra ID |  Planned | Microsoft 365, Azure integration |
| **Directory Sync** | OKTA AD Agent |  Next Phase | Real-time AD→OKTA provisioning |

---

## Current Implementation Status

### Phase 1: Foundation (COMPLETED)
- [x] Network design and VLAN segmentation
- [x] Windows Server 2022 deployment (srv1)
- [x] Active Directory Domain Services installation
- [x] Domain promotion: `ad.biira.online`
- [x] Static IP configuration (192.168.50.2)
- [x] UPN suffix configuration: `biira.online`
- [x] AD Domain Trusts configured
- [x] OKTA Integrator tenant provisioned
- [x] Custom branding with `biira.online` domain
- [x] Initial user creation and SSO validation

**Documentation:** `docs/guides/phase-1-foundation/00-foundation-summary.md`

---

### Phase 2: AD Structure & User Provisioning (COMPLETED)

#### Organizational Structure
- [x] Enterprise OU hierarchy (20 OUs)
- [x] Departmental organizational units (6 departments)
- [x] Administrative tier OUs (Tier 0/1/2)
- [x] Service account OU

#### Security Groups
- [x] OKTA integration groups (3 groups)
- [x] Department access groups (6 groups)
- [x] Administrative tier groups (3 groups)
- **Total: 12 security groups**

#### User Provisioning
- [x] Employee accounts: 27 users across 6 departments
- [x] Administrative accounts: 7 accounts (Tier 0/1/2)
- [x] Service account: 1 (svc-okta-agent)
- [x] Built-in Administrator: Disabled
- **Total: 35 accounts in Active Directory**

#### Account Distribution

**Regular Employee Accounts (27):**
- Executive: 4 users
- IT: 6 users
- Finance: 5 users
- HR: 3 users
- Sales: 5 users
- Marketing: 4 users

**Administrative Accounts (7):**
- Tier 0 Domain Admins: 1 account
- Tier 1 Server Admins: 4 accounts
- Tier 2 Workstation Admins: 2 accounts

#### Advanced Security Implementation

- [x] Microsoft Tiered Administrative Model
- [x] Dual-account pattern for IT staff
- [x] Kerberos hardening (AccountNotDelegated + Require Pre-Auth)
- [x] Built-in Administrator disabled
- [x] Admin accounts isolated from OKTA sync (3-layer protection)

**Documentation:**

- `docs/guides/phase-2-ad-structure/00-implementation-summary.md` (Employee provisioning)
- `docs/guides/phase-2-ad-structure/01-admin-account-implementation.md` (Admin tier implementation)

**Scripts Created:**

- `Create-OUStructure.ps1`
- `Create-OktaGroups.ps1`
- `Department_Group_Creation.ps1`
- `Bulk-CreateUsers.ps1`
- `Create-AdminGroups.ps1`
- `Create-Tier0-Admin.ps1`
- `Create-Tier1-Admins.ps1`
- `Create-Tier2-Admins.ps1`
- `Harden-AdminAccounts.ps1`

---

###  Phase 3: OKTA Integration (NEXT)

**Status:** Ready to start

#### Prerequisites Completed:

- AD OU structure created
- SG-OKTA-AllUsers group populated (27 members)
- svc-okta-agent service account created
- Test users have @biira.online UPN
- Admin accounts properly isolated

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
- Configure sync scope: OU=Employees,OU=Users,OU=BIIRA,DC=ad,DC=biira,DC=online
- Set user filter: memberOf=SG-OKTA-AllUsers
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
- Verify 27 users appear in OKTA
- Check group memberships
- Validate admin accounts NOT synced

**Documentation:** (To be created)
- `docs/guides/phase-3-okta-integration/01-okta-agent-install.md`
- `docs/guides/phase-3-okta-integration/02-directory-sync.md`

---

###  Phase 4: Advanced Security (PLANNED)
- [ ] Conditional Access policies
- [ ] Adaptive MFA (risk-based)
- [ ] Privileged access management
- [ ] Just-in-Time administration
- [ ] Audit logging and SIEM integration

---

###  Phase 5: Microsoft Entra ID (PLANNED)
- [ ] Azure AD Connect installation
- [ ] Hybrid identity synchronization
- [ ] Seamless SSO configuration
- [ ] Federation with OKTA (if applicable)

---

##  Implementation Progress

```
Phase 1: Foundation           ████████████████████ 100% 
Phase 2: AD Structure         ████████████████████ 100% 
Phase 3: OKTA Integration     ░░░░░░░░░░░░░░░░░░░░   0% 
Phase 4: Advanced Security    ░░░░░░░░░░░░░░░░░░░░   0% 
Phase 5: Entra ID            ░░░░░░░░░░░░░░░░░░░░   0% 
```

---

##  Repository Structure

```
enterprise-iam-lab/
├── README.md                          # Project overview
│
├── docs/
│   ├── architecture/                  # Design decisions, diagrams
│   ├── guides/                        # Step-by-step implementation
│   │   ├── phase-1-foundation/
│   │   │   └── 00-foundation-summary.md
│   │   └── phase-2-ad-structure/
│   │       ├── 00-implementation-summary.md
│   │       └── 01-admin-account-implementation.md
│   ├── runbooks/                      # Operations procedures
│   └── reference/                     # Standards, conventions
│
├── scripts/
│   ├── active-directory/              # AD automation (PowerShell)
│   │   ├── Create-OUStructure.ps1
│   │   ├── Create-OktaGroups.ps1
│   │   ├── Department_Group_Creation.ps1
│   │   ├── Bulk-CreateUsers.ps1
│   │   ├── Create-AdminGroups.ps1
│   │   ├── Create-Tier0-Admin.ps1
│   │   ├── Create-Tier1-Admins.ps1
│   │   ├── Create-Tier2-Admins.ps1
│   │   └── Harden-AdminAccounts.ps1
│   ├── okta/                          # OKTA API scripts
│   └── utilities/                     # General tools
│
├── configs/
│   ├── group-policies/                # GPO exports
│   ├── okta/                          # OKTA configs (sanitized)
│   └── templates/                     # User/group CSV templates
│
├── labs/                              # Hands-on exercises
└── assets/                            # Images, diagrams, videos
    ├── csv/
    │   └── biira_employees.csv
    └── images/
        └── screenshots/
            ├── phase-1/
            └── phase-2/
```

---

##  Learning Outcomes

By following this lab, you'll master:

### Technical Skills
- **Hybrid Identity Architecture**: Design and implement cloud + on-prem integration
- **Enterprise AD Management**: OUs, GPOs, security groups, delegation
- **OKTA Administration**: Universal Directory, SSO, lifecycle management, MFA
- **Automation**: PowerShell scripting, Microsoft Graph API, OKTA API
- **Security Hardening**: Defense-in-depth, least privilege, conditional access
- **Microsoft Tiered Admin Model**: Tier 0/1/2 privilege separation
- **Troubleshooting**: Directory sync issues, authentication failures, SSO debugging

### Enterprise Best Practices
- Split-brain DNS for hybrid environments
- Tiered admin model (Privileged Access Workstation principles)
- Dual-account pattern for administrative access
- Naming conventions and documentation standards
- Change management and rollback procedures
- Audit compliance (SOC 2, HIPAA, PCI-DSS considerations)

---

##  Quick Start

### Prerequisites
- Windows Server 2022 (or 2019)
- OKTA Integrator/Developer account
- Public domain (optional but recommended)
- VMware or Hyper-V for homelab
- PowerShell 5.1+ (7.x recommended)

### Getting Started
1. **Clone the repository**
   ```bash
   git clone https://github.com/noble-antwi/enterprise-iam-lab
   cd enterprise-iam-lab
   ```

2. **Follow the guides in order**
   - Start with `docs/guides/phase-1-foundation/`
   - Each phase builds on the previous
   - Validate with labs before proceeding

3. **Adapt to your environment**
   - Update `docs/reference/naming-conventions.md` with your details
   - Modify scripts with your domain names
   - Use `.env.example` patterns for sensitive data

---

## Security & Privacy

- **No sensitive data**: All configs are sanitized examples
- **Service account passwords**: Referenced in documentation, never committed
- **OKTA tenant details**: Masked in screenshots and configs
- **IP addresses**: Use your own network ranges

### Lab vs Production

While this lab follows enterprise best practices, remember:
- Homelab environments lack physical security controls
- Not all configurations scale to 10,000+ users
- Some features require enterprise licensing (Entra ID P2, OKTA Workforce Identity)

---

## Contributing

This is a learning project, but feedback is welcome!

- **Found an issue?** Open a GitHub issue with details
- **Have a suggestion?** Submit a pull request with improvements
- **Want to share your adaptation?** Fork and link back!

---

## Resources & References

### Official Documentation
- [OKTA Developer Documentation](https://developer.okta.com/)
- [Microsoft Active Directory Best Practices](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/)
- [Azure AD Hybrid Identity](https://learn.microsoft.com/en-us/azure/active-directory/hybrid/)

### IAM Industry Standards
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [SANS Critical Security Controls](https://www.sans.org/critical-security-controls/)
- [CIS Benchmarks - Active Directory](https://www.cisecurity.org/benchmark/microsoft_windows_server)
- [Microsoft Tiered Admin Model](https://learn.microsoft.com/en-us/security/privileged-access-workstations/privileged-access-access-model)

### Homelab Communities
- [r/homelab](https://reddit.com/r/homelab) - Homelab enthusiasts
- [r/activedirectory](https://reddit.com/r/activedirectory) - AD best practices
- [OKTA Community](https://support.okta.com/community) - OKTA-specific help

---

##  About This Project

**Author**: Noble W. Antwi  
**Purpose**: Skills demonstration, portfolio building, continuous learning  
**Status**: Active development (Phase 2 Complete, Phase 3 Starting)  

*Built with  and countless hours of troubleshooting*

---

**Last Updated**: October 2025  
**Next Milestone**: OKTA AD Agent deployment and directory synchronization