# Enterprise IAM Lab: Hybrid Identity Architecture

> **Building production-ready Identity and Access Management skills through hands-on implementation**  
> A comprehensive homelab demonstrating enterprise-grade IAM integration using Active Directory, OKTA, and Microsoft Entra ID

[![Lab Status](https://img.shields.io/badge/Status-Phase%202%20In%20Progress-yellow)]()
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

![Architectural DIagram](<assets/images/Architectural Diagram/ArchitecturalDiagram.png>)

### Domain Architecture: The Two Domains Explained

| Aspect | `ad.biira.online` | `biira.online` |
|--------|-------------------|----------------|
| **Type** | Active Directory Domain (Internal) | UPN Suffix + Public Domain |
| **Scope** | Homelab network only | Internet-routable |
| **Purpose** | AD forest root, computer auth | User-facing logins, SSO |
| **DNS** | Internal DNS on srv1 | Namecheap public DNS |
| **Example Use** | `AD\jsmith` login on domain PC | `jsmith@biira.online` OKTA login |
| **Kerberos Realm** | AD.BIIRA.ONLINE | N/A (UPN only) |

**Why This Matters**: This split-brain DNS design is enterprise-standard. Users authenticate with friendly `@biira.online` UPNs while AD internally uses `ad.biira.online`- enabling seamless cloud SSO without exposing internal domain structure.

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

##  Current Implementation Status

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

###  Phase 2: AD Structure & Preparation (IN PROGRESS)
- [ ] Enterprise OU hierarchy design
- [ ] Departmental organizational units
- [ ] Security group structure (role-based access)
- [ ] Service account creation (OKTA Agent)
- [ ] Group Policy baseline (password, audit, security)
- [ ] Bulk user creation (realistic test users)
- [ ] AD documentation and runbooks

### Phase 3: OKTA Integration (NEXT)
- [ ] OKTA AD Agent installation
- [ ] Directory synchronization configuration
- [ ] Attribute mapping (AD ↔ OKTA)
- [ ] Group-based provisioning rules
- [ ] SSO application integration
- [ ] MFA enforcement policies

### Phase 4: Advanced Security (PLANNED)
- [ ] Conditional Access policies
- [ ] Adaptive MFA (risk-based)
- [ ] Privileged access management
- [ ] Just-in-Time administration
- [ ] Audit logging and SIEM integration

### Phase 5: Microsoft Entra ID (PLANNED)
- [ ] Azure AD Connect installation
- [ ] Hybrid identity synchronization
- [ ] Seamless SSO configuration
- [ ] Federation with OKTA (if applicable)

---

##  Repository Structure

```
enterprise-iam-lab/
├── docs/
│   ├── architecture/        # Design decisions, diagrams
│   ├── guides/             # Step-by-step implementation
│   ├── runbooks/           # Operations procedures
│   └── reference/          # Standards, conventions
│
├── scripts/
│   ├── active-directory/   # AD automation (PowerShell)
│   ├── okta/              # OKTA API scripts
│   └── utilities/         # General tools
│
├── configs/
│   ├── group-policies/    # GPO exports
│   ├── okta/             # OKTA configs (sanitized)
│   └── templates/        # User/group CSV templates
│
├── labs/                  # Hands-on exercises
└── assets/               # Images, diagrams, videos
```

See [Repository Structure Guide](docs/reference/repository-structure.md) for detailed organization.

---

##  Learning Outcomes

By following this lab, you'll master:

### Technical Skills
- **Hybrid Identity Architecture**: Design and implement cloud + on-prem integration
- **Enterprise AD Management**: OUs, GPOs, security groups, delegation
- **OKTA Administration**: Universal Directory, SSO, lifecycle management, MFA
- **Automation**: PowerShell scripting, Microsoft Graph API, OKTA API
- **Security Hardening**: Defense-in-depth, least privilege, conditional access
- **Troubleshooting**: Directory sync issues, authentication failures, SSO debugging

### Enterprise Best Practices
- Split-brain DNS for hybrid environments
- Tiered admin model (Privileged Access Workstation principles)
- Naming conventions and documentation standards
- Change management and rollback procedures
- Audit compliance (SOC 2, HIPAA considerations)

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

##  Lab Environment Highlights

### Active Directory Configuration
*Image: UPN Suffix Configuration showing `biira.online` added as alternative UPN*

### OKTA Dashboard
*Image: OKTA Admin Console showing 4 active users, 8 SSO apps, operational status*

### Custom Branding
*Image: OKTA custom domain configuration with `www.biira.online`*

---

## Important Notes

### Security & Privacy
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

### Homelab Communities
- [r/homelab](https://reddit.com/r/homelab) - Homelab enthusiasts
- [r/activedirectory](https://reddit.com/r/activedirectory) - AD best practices
- [OKTA Community](https://support.okta.com/community) - OKTA-specific help

---

## About This Project

**Author**: Noble W. Antwi  
**Purpose**: Skills demonstration, portfolio building, continuous learning  
**Status**: Active development (Phase 2)  

*Built with  and countless hours of troubleshooting*

---

**Last Updated**: October 2025  
**Next Milestone**: Complete AD OU structure and OKTA Agent deployment