# Enterprise IAM Lab: Hybrid Identity Architecture

> **Building production-ready Identity and Access Management skills through hands-on implementation**  
> A comprehensive homelab demonstrating enterprise-grade IAM integration using Active Directory, OKTA, and Microsoft Entra ID

[![Lab Status](https://img.shields.io/badge/Status-Phase%204%20Complete-brightgreen)]()
[![AD Domain](https://img.shields.io/badge/AD%20Domain-ad.biira.online-blue)]()
[![OKTA](https://img.shields.io/badge/OKTA-Integrator%20Tenant-00297A)]()
[![SSO Domain](https://img.shields.io/badge/SSO-login.biira.online-orange)]()

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
│  │              │              │                      │   │
│  │ Applications │              │  Microsoft 365       │   │
│  │ ├─ Dropbox   │              │  Integration         │   │
│  │ └─ Box       │              │                      │   │
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
│  │  SSO Portal: login.biira.online                    │   │
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
| **On-Prem Directory** | Windows Server 2022 Active Directory | ✅ Deployed | User/computer management, GPOs |
| **Primary Cloud IdP** | OKTA Universal Directory | ✅ Configured | SSO, MFA, adaptive auth |
| **Secondary Cloud IdP** | Microsoft Entra ID | 📋 Planned | Microsoft 365, Azure integration |
| **Directory Sync** | OKTA AD Agent | ✅ Operational | Real-time AD→OKTA provisioning |

### Application Integration
| Application | Protocol | Status | Users | Purpose |
|-------------|----------|--------|-------|---------|
| **Dropbox Business** | SAML 2.0 | ✅ Operational | 4 users | Enterprise file sharing |
| **Box** | SWA (Password Vaulting) | ✅ Operational | 4 users | Legacy application integration |
| **Microsoft 365** | SAML/OIDC | 📋 Planned | All users | Productivity suite |
| **AWS Console** | SAML | 📋 Planned | IT users | Cloud infrastructure |

---

## Current Implementation Status

### Phase 1: Foundation (COMPLETED ✅)
- [x] Network design and VLAN segmentation
- [x] Windows Server 2022 deployment (srv1)
- [x] Active Directory Domain Services installation
- [x] Domain promotion: `ad.biira.online`
- [x] Static IP configuration (192.168.50.2)
- [x] UPN suffix configuration: `biira.online`
- [x] AD Domain Trusts configured
- [x] OKTA Integrator tenant provisioned
- [x] Custom branding with `login.biira.online` domain
- [x] Initial user creation and SSO validation

**Documentation:** `docs/guides/phase-1-foundation/00-foundation-summary.md`

---

### Phase 2: AD Structure & User Provisioning (COMPLETED ✅)

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

### Phase 3: OKTA Integration (COMPLETED ✅)

#### Prerequisites Completed:
- [x] AD OU structure created
- [x] SG-OKTA-AllUsers group populated (27 members)
- [x] svc-okta-agent service account created
- [x] Test users have @biira.online UPN
- [x] Admin accounts properly isolated

#### Implementation Completed:
- [x] OKTA AD Agent 3.21.0 installed and configured
- [x] Secure directory synchronization (27 users, 12 groups)
- [x] Complete administrative account isolation (0 admin accounts synced)
- [x] Hourly synchronization schedule
- [x] Domain architecture optimization (www.biira.online → login.biira.online)
- [x] Advanced provisioning configuration
- [x] Attribute mapping strategy
- [x] User lifecycle management

**Documentation:**
- `docs/guides/phase-3-okta-integration/00-implementation-summary.md`
- `docs/guides/phase-3-okta-integration/01-domain-architecture-optimization.md`
- `docs/guides/phase-3-okta-integration/02-advanced-provisioning-configuration.md`
- `docs/guides/phase-3-okta-integration/03-attribute-mapping-strategy.md`
- `docs/guides/phase-3-okta-integration/04-user-lifecycle-management.md`

---

### Phase 4: Advanced OKTA Configuration (COMPLETED ✅)

#### OKTA Groups Strategy
- [x] Expression Language implementation for dynamic group assignment
- [x] OG-Location-Americas group with geographic business logic
- [x] Real-time group assignment based on user attributes
- [x] Hybrid group architecture (AD-sourced + OKTA-mastered)

#### Application Integration
- [x] **SAML 2.0 Integration:** Dropbox Business with automated provisioning
- [x] **SWA Integration:** Box with secure password vaulting
- [x] Group-based application assignment (4 users per application)
- [x] Cross-protocol authentication testing and validation

#### Automated Provisioning
- [x] Real-time user lifecycle management (create/update/deactivate)
- [x] Advanced attribute mapping with conditional logic
- [x] API integration with comprehensive error handling
- [x] Cross-application provisioning coordination

#### Testing & Validation
- [x] Comprehensive user experience testing (joshua.brooks@biira.online)
- [x] Cross-browser compatibility validation
- [x] Performance testing and optimization
- [x] Security testing and compliance validation

#### Operational Excellence
- [x] 24/7 monitoring and alerting systems
- [x] Comprehensive troubleshooting procedures
- [x] Incident response workflows
- [x] Performance optimization and capacity planning

**Key Achievements:**
- **Applications Integrated:** 2 (Dropbox Business SAML, Box SWA)
- **Authentication Protocols:** SAML 2.0 + Secure Web Authentication
- **Automation:** Geographic group assignment, automated provisioning
- **User Experience:** <3 second average application access time
- **Security:** 100% admin account isolation, complete audit trail

**Documentation:**
- `docs/guides/phase-4-advanced-okta/00-implementation-summary.md`
- `docs/guides/phase-4-advanced-okta/01-okta-groups-strategy.md`
- `docs/guides/phase-4-advanced-okta/02-application-integration-saml.md`
- `docs/guides/phase-4-advanced-okta/03-application-integration-swa.md`
- `docs/guides/phase-4-advanced-okta/04-provisioning-configuration.md`
- `docs/guides/phase-4-advanced-okta/05-testing-validation.md`
- `docs/guides/phase-4-advanced-okta/06-troubleshooting-operations.md`

---

### Phase 5: Advanced Authentication & Security (PLANNED 📋)
- [ ] Multi-Factor Authentication (MFA) implementation
- [ ] Adaptive authentication and risk-based policies
- [ ] Privileged Access Management (PAM) integration
- [ ] Just-in-Time administration
- [ ] Conditional Access policies
- [ ] Advanced threat detection and response

---

### Phase 6: Microsoft Entra ID Integration (PLANNED 📋)
- [ ] Azure AD Connect installation
- [ ] Hybrid identity synchronization
- [ ] Seamless SSO configuration
- [ ] Microsoft 365 integration
- [ ] Federation with OKTA (if applicable)

---

## Implementation Progress

```
Phase 1: Foundation                ████████████████████ 100% 
Phase 2: AD Structure             ████████████████████ 100% 
Phase 3: OKTA Integration         ████████████████████ 100% 
Phase 4: Advanced Configuration   ████████████████████ 100% 
Phase 5: Advanced Security        ░░░░░░░░░░░░░░░░░░░░   0% 
Phase 6: Microsoft Entra ID       ░░░░░░░░░░░░░░░░░░░░   0% 
```

**Current Status:** Advanced Identity Orchestration Platform Operational  
**Next Milestone:** Multi-Factor Authentication and Conditional Access implementation

---

## Current Environment Statistics

### Identity Infrastructure
- **Total User Accounts:** 35
  - Employee Accounts: 27 (across 6 departments)
  - Administrative Accounts: 7 (Tier 0/1/2 model)
  - Service Accounts: 1 (OKTA AD Agent)
- **Security Groups:** 15 total
  - AD-Sourced Groups: 12 (departments + admin tiers)
  - OKTA-Mastered Groups: 3 (location-based dynamic groups)
- **Organizational Units:** 20 (hierarchical enterprise structure)

### Application Ecosystem
- **Integrated Applications:** 2
  - Dropbox Business (SAML 2.0 + automated provisioning)
  - Box (SWA + password vaulting)
- **Authentication Protocols:** SAML 2.0, SWA
- **User Coverage:** 4 users with application access via OG-Location-Americas

### Infrastructure Components
- **Domain Controllers:** 1 (srv1.ad.biira.online)
- **OKTA AD Agents:** 1 (version 3.21.0)
- **DNS Architecture:** Split-brain (internal ad.biira.online + public biira.online)
- **SSO Portal:** login.biira.online
- **Network Segmentation:** Management VLAN 50 (192.168.50.0/24)

---

## Repository Structure

```
enterprise-iam-lab/
├── README.md                          # Project overview (this file)
│
├── docs/
│   ├── architecture/                  # Design decisions, diagrams
│   ├── guides/                        # Step-by-step implementation
│   │   ├── phase-1-foundation/
│   │   │   └── 00-foundation-summary.md
│   │   ├── phase-2-ad-structure/
│   │   │   ├── 00-implementation-summary.md
│   │   │   └── 01-admin-account-implementation.md
│   │   ├── phase-3-okta-integration/
│   │   │   ├── 00-implementation-summary.md
│   │   │   ├── 01-domain-architecture-optimization.md
│   │   │   ├── 02-advanced-provisioning-configuration.md
│   │   │   ├── 03-attribute-mapping-strategy.md
│   │   │   └── 04-user-lifecycle-management.md
│   │   └── phase-4-advanced-okta/
│   │       ├── 00-implementation-summary.md
│   │       ├── 01-okta-groups-strategy.md
│   │       ├── 02-application-integration-saml.md
│   │       ├── 03-application-integration-swa.md
│   │       ├── 04-provisioning-configuration.md
│   │       ├── 05-testing-validation.md
│   │       └── 06-troubleshooting-operations.md
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
│   ├── okta/                          # OKTA API and automation scripts
│   └── utilities/                     # General tools
│
├── configs/
│   ├── group-policies/                # GPO exports
│   ├── okta/                          # OKTA configs (sanitized)
│   │   ├── saml-templates/
│   │   ├── swa-templates/
│   │   └── expression-examples.txt
│   └── templates/                     # User/group CSV templates
│
├── labs/                              # Hands-on exercises
└── assets/                            # Images, diagrams, videos
    ├── csv/
    │   └── biira_employees.csv
    └── images/
        ├── Architectural Diagram/
        └── screenshots/
            ├── phase-1/
            ├── phase-2/
            ├── phase-3/
            └── phase-4/
```

---

## Learning Outcomes

By following this lab, you'll master:

### Technical Skills
- **Hybrid Identity Architecture**: Design and implement cloud + on-prem integration
- **Enterprise AD Management**: OUs, GPOs, security groups, delegation
- **OKTA Administration**: Universal Directory, SSO, lifecycle management, MFA
- **Application Integration**: SAML 2.0, SWA, automated provisioning
- **Automation**: PowerShell scripting, OKTA Expression Language, API integration
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
- Expression Language for dynamic business logic
- Cross-protocol application integration strategies

---

## Quick Start

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
   - Validate with testing procedures before proceeding

3. **Adapt to your environment**
   - Update scripts with your domain names
   - Modify Expression Language rules for your business logic
   - Configure applications for your specific requirements

---

## Security & Privacy

- **No sensitive data**: All configs are sanitized examples
- **Service account passwords**: Referenced in documentation, never committed
- **OKTA tenant details**: Masked in screenshots and configs
- **IP addresses**: Use your own network ranges
- **Real-world ready**: All configurations based on enterprise best practices

### Lab vs Production

While this lab follows enterprise best practices, remember:
- Homelab environments lack physical security controls
- Not all configurations scale to 10,000+ users without optimization
- Some features require enterprise licensing (Entra ID P2, OKTA Workforce Identity)
- Advanced security features (PAM, advanced MFA) require additional implementation

---

## Contributing

This is a learning project, but feedback is welcome!

- **Found an issue?** Open a GitHub issue with details
- **Have a suggestion?** Submit a pull request with improvements
- **Want to share your adaptation?** Fork and link back!
- **Implementing similar lab?** Feel free to use as reference and share your learnings

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

## About This Project

**Author**: Noble W. Antwi  
**Purpose**: Skills demonstration, portfolio building, continuous learning  
**Status**: Active development (Phase 4 Complete, Phase 5 Planning)  
**LinkedIn**: [Connect for IAM discussions](https://linkedin.com/in/noble-antwi)

*Built with ❤️ and countless hours of troubleshooting*

---

**Last Updated**: November 2025  
**Next Milestone**: Multi-Factor Authentication and Conditional Access implementation  
**Current Focus**: Advanced authentication protocols and security enhancement
