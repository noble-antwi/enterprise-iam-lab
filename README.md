<img src="assets/brand/biira-bank-lockup-960.png" alt="Biira Bank" width="380">

# Enterprise IAM Lab: Hybrid Identity Architecture

> **Building regulatory-grade hybrid identity architecture for financial services**
> A comprehensive homelab demonstrating enterprise-grade IAM integration using Active Directory, OKTA, and Microsoft Entra ID for a regulated commercial bank

The bank is **Biira Bank**, and it is the same organisation documented in the sibling repository [enterprise-security-homelab](https://github.com/noble-antwi/enterprise-security-homelab), which covers the network, segmentation and infrastructure this identity estate runs on. Both repositories share one visual identity, documented in [assets/brand](assets/brand/README.md).

[![Lab Status](https://img.shields.io/badge/Status-Phase%205.1%20Complete-brightgreen)]()
[![AD Domain](https://img.shields.io/badge/AD%20Domain-ad.biira.online-blue)]()
[![OKTA](https://img.shields.io/badge/OKTA-Integrator%20Tenant-00297A)]()
[![SSO Domain](https://img.shields.io/badge/SSO-login.biira.online-orange)]()
[![Industry](https://img.shields.io/badge/Industry-Financial%20Services-darkgreen)]()

---

## Infrastructure substrate and migration note

This identity lab runs on the network substrate documented in the companion repository **[enterprise-security-homelab](https://github.com/noble-antwi/enterprise-security-homelab)** (pfSense, VLANs, managed switches, Proxmox VE). That repo is the authoritative source of truth for the network, firewall, and virtualization layer; this repo is the identity workload that runs on top of it.

Current domain controller facts (2026-09-02):

| Item | Current value |
|------|---------------|
| Hostname | **DC01** (originally deployed and screenshotted as `srv1`) |
| Operating system | **Windows Server 2025** (earlier phases were built on Windows Server 2022) |
| IP address | `192.168.50.2` (unchanged) |
| VLAN | **VLAN 50 · EnterpriseLAN** (`192.168.50.0/24`) |
| Domain | `ad.biira.online` (unchanged) |

The controller was renamed `srv1` → `DC01` and the platform moved to Windows Server 2025 as part of the substrate build-out. The IP (`192.168.50.2`) and domain (`ad.biira.online`) never changed, so all OKTA agent, DNS, and directory configuration carried over intact. **Some historical screenshots in the phase guides still show the earlier `srv1` / Windows Server 2022 labels** from when they were captured; the identity and configuration they document are otherwise equivalent to the current DC01.

---

## Project Vision

This repository chronicles my journey building a **500-1000 user enterprise IAM environment** from scratch. The lab simulates a state-chartered commercial bank's identity infrastructure, implementing financial services regulatory standards for hybrid identity, zero-trust security, and modern access management.

**Real-World Application**: Every configuration, script, and architectural decision mirrors production banking environments - making this directly applicable to financial services IAM implementations.

---

## Organization Profile

Biira Bank is a state-chartered commercial bank headquartered in Charlotte, North Carolina. As an FDIC-insured, NASDAQ-listed institution, the bank operates under dual regulatory oversight from the North Carolina Commissioner of Banks and the FDIC, with additional SEC reporting and Sarbanes-Oxley compliance obligations.

The IAM architecture implemented in this project is driven by the following regulatory framework:

| Regulation | Oversight Body | IAM Relevance |
|-----------|---------------|---------------|
| GLBA Safeguards Rule | FTC / FDIC | Access controls, MFA, customer data encryption |
| Sarbanes-Oxley (SOX) | SEC / PCAOB | Separation of duties, privileged access, audit trails |
| PCI-DSS v4.0 | PCI SSC | Unique user IDs, MFA for admin access, RBAC, network segmentation |
| FFIEC Auth Guidance (2021) | FFIEC | Risk-based auth, conditional access, network zones, anomaly monitoring |
| BSA/AML | FinCEN / FDIC | Geographic restrictions, transaction monitoring access controls |
| SOC 2 Type II | AICPA | Security, availability, processing integrity controls |

For the complete organization profile, see [docs/company-profile/00-company-profile.md](docs/company-profile/00-company-profile.md).

---

## Architecture Overview

### Hybrid Identity Design

```
+-----------------------------------------------------------------+
|                    INTERNET / CLOUD                               |
|                                                                   |
|  +------------------------------------------------------------+  |
|  |         Network-Based Conditional Access                    |  |
|  |  +------------------------------------------------------+  |  |
|  |  | Network Zones (Phase 5.1)                             |  |  |
|  |  | - Corporate Network (IP Zone)                         |  |  |
|  |  | - Allowed Countries (Geographic)                      |  |  |
|  |  | - Tor Blocking (Threat Intelligence)                  |  |  |
|  |  +------------------------------------------------------+  |  |
|  |  +------------------------------------------------------+  |  |
|  |  | Authentication Policies                               |  |  |
|  |  | Priority 1: Restricted Countries (DENY)               |  |  |
|  |  | Priority 2: Public Network (Hardware MFA)             |  |  |
|  |  | Priority 3: Corporate Network (Standard MFA)          |  |  |
|  |  +------------------------------------------------------+  |  |
|  +------------------------------------------------------------+  |
|                                                                   |
|  +----------------+              +------------------------+      |
|  |   OKTA         |<------------>|  Microsoft Entra ID    |      |
|  |  (Primary      |   Federation |    (Azure AD)          |      |
|  |   IdP)         |              |                        |      |
|  |                |              |                        |      |
|  | Applications   |              |  Microsoft 365         |      |
|  | +- Dropbox     |              |  Integration           |      |
|  | +- Box         |              |                        |      |
|  +-------+--------+              +------------------------+      |
|          |                                                        |
|          | OKTA AD Agent                                          |
|          | (Secure Tunnel)                                        |
+----------+--------------------------------------------------------+
           |
           v
+-----------------------------------------------------------------+
|                 ON-PREMISES HOMELAB                               |
|                                                                   |
|  +------------------------------------------------------------+  |
|  |  Active Directory Domain: ad.biira.online                  |  |
|  |  UPN Suffix: biira.online                                  |  |
|  |  SSO Portal: login.biira.online                            |  |
|  |  Identity Consumers: Retail Banking | Commercial Banking   |  |
|  |    | Wealth Advisory | Digital Banking                     |  |
|  |                                                             |  |
|  |  +----------------+         +--------------------+         |  |
|  |  |   DC01          |         |  Future:           |         |  |
|  |  |  (Domain        |         |  - srv2 (Replica   |         |  |
|  |  |   Controller)   |         |    DC)             |         |  |
|  |  |                 |         |  - CA Server       |         |  |
|  |  |  192.168.50.2   |         |  - ADFS (if req)   |         |  |
|  |  +----------------+         +--------------------+         |  |
|  |                                                             |  |
|  +------------------------------------------------------------+  |
|                                                                   |
|  Network: 192.168.50.0/24 (Management VLAN)                     |
+-----------------------------------------------------------------+
```

**Phase 5 Enhancement:** Network-based conditional access policies now enforce location-aware authentication requirements, with differentiated security controls for corporate versus public network access. Geographic restrictions and Tor blocking provide additional layers of defense.

---

## Project Phases

| Phase | Focus | Regulatory Driver | Status |
|-------|-------|-------------------|--------|
| **Phase 1** | Foundation -- Windows Server, AD DS, DNS, Okta tenant setup | FFIEC IT Examination, PCI-DSS Req. 1 | Complete |
| **Phase 2** | AD Structure -- Tiered admin model, OUs, security groups | SOX separation of duties, FFIEC privileged access | Complete |
| **Phase 3** | Okta Integration -- AD agent, provisioning, attribute mapping | GLBA Safeguards Rule, FFIEC cloud guidance | Complete |
| **Phase 4** | Advanced Okta -- SAML/SWA apps, group push, lifecycle management | SOX automated controls, GLBA least-privilege | Complete |
| **Phase 5** | Advanced Security -- Network zones, conditional access, MFA policies | FFIEC authentication guidance, BSA/AML | In Progress |

### Phase 1: Foundation (COMPLETE)
- [x] Windows Server 2025 deployment (dc01.ad.biira.online)
- [x] Active Directory Domain Services configuration
- [x] DNS infrastructure (split-brain architecture)
- [x] OKTA Integrator tenant provisioning
- [x] Custom domain configuration (biira.online)
- [x] Network infrastructure (VLAN segmentation)

**Documentation:** `docs/guides/phase-1-foundation/`

---

### Phase 2: Active Directory Structure (COMPLETE)
- [x] Organizational Unit hierarchy (20 OUs)
- [x] Tiered admin model implementation (Tier 0/1/2)
- [x] Employee account provisioning (27 users across 6 departments)
- [x] Administrative account creation (7 admin accounts)
- [x] Security group structure (15 groups)
- [x] Service account configuration (OKTA sync)
- [x] Custom AD schema extensions

**Documentation:** `docs/guides/phase-2-ad-structure/`

---

### Phase 3: OKTA Integration (COMPLETE)
- [x] OKTA AD Agent installation (version 3.21.0)
- [x] Secure cloud connectivity establishment
- [x] Directory synchronization configuration
- [x] User lifecycle management
- [x] Group synchronization with attribute mapping
- [x] Administrative account isolation
- [x] Sync schedule optimization (15-minute intervals)

**Documentation:** `docs/guides/phase-3-okta-integration/`

---

### Phase 4: Advanced OKTA Configuration (COMPLETE)
- [x] OKTA Expression Language automation
- [x] Geographic group assignment (OG-Location-Americas)
- [x] SAML 2.0 application integration (Dropbox Business)
- [x] SWA application integration (Box)
- [x] Automated user provisioning workflows
- [x] Application lifecycle management
- [x] Comprehensive testing and validation procedures
- [x] Operational procedures and troubleshooting guides

**Key Features:**
- Dynamic group assignment using Expression Language
- Cross-protocol application integration (SAML + SWA)
- Automated provisioning with attribute mapping
- Geographic-based access control
- Enterprise operational procedures

**Documentation:**
- `docs/guides/phase-4-advanced-okta/00-implementation-summary.md`
- `docs/guides/phase-4-advanced-okta/01-okta-groups-strategy.md`
- `docs/guides/phase-4-advanced-okta/02-application-integration-saml.md`
- `docs/guides/phase-4-advanced-okta/03-application-integration-swa.md`
- `docs/guides/phase-4-advanced-okta/04-provisioning-configuration.md`
- `docs/guides/phase-4-advanced-okta/05-testing-validation.md`
- `docs/guides/phase-4-advanced-okta/06-troubleshooting-operations.md`

---

### Phase 5: Advanced Authentication & Security (IN PROGRESS)
- [x] **Network-based conditional access (Phase 5.1) - COMPLETE**
- [x] IP network zones for corporate network identification
- [x] Dynamic zones for geographic and threat-based controls
- [x] Tor anonymizer blocking for anonymous proxy prevention
- [x] Authentication policies with graduated security requirements
  - Priority 1: Restricted Countries (DENY access)
  - Priority 2: Public Network (Hardware-protected MFA required)
  - Priority 3: Corporate Network (Standard MFA required)
- [x] Comprehensive testing with pilot users
- [x] Video demonstrations of authentication flows
- [ ] Adaptive MFA and risk-based authentication (Phase 5.2) PLANNED
- [ ] Device trust and posture evaluation (Phase 5.3) PLANNED
- [ ] Privileged access management (Phase 5.4) PLANNED
- [ ] Behavioral analytics and anomaly detection (Phase 5.5) PLANNED

**Phase 5.1 Achievements:**
- Three-tier network zone architecture (IP, Geographic, Threat)
- Context-aware authentication (corporate vs public network)
- Geographic access restrictions (country-level controls)
- Anonymous proxy detection and blocking
- Defense-in-depth security with graduated MFA requirements

**Video Demonstrations:**
- **Video - Public Network Flow:** [Public Network Authentication Flow](https://youtu.be/qLD-tUc5B5Y) - Hardware-protected MFA for untrusted networks
- **Video - Corporate Network Flow:** [Corporate Network Authentication Flow](https://youtu.be/JpR_oS2XjQc) - Expanded methods for trusted networks

**Documentation:**
- `docs/guides/phase-5-advanced-security/00-phase-5-overview.md`
- `docs/guides/phase-5-advanced-security/01-network-zones-implementation.md`
- `docs/guides/phase-5-advanced-security/README.md`

---

### Phase 6: Microsoft Entra ID Integration (PLANNED)
- [ ] Azure AD Connect installation
- [ ] Hybrid identity synchronization
- [ ] Seamless SSO configuration
- [ ] Microsoft 365 integration
- [ ] Federation with OKTA (if applicable)

---

## Implementation Progress

```
Phase 1: Foundation                %%%%%%%%%%%%%%%%%%%% 100%
Phase 2: AD Structure             %%%%%%%%%%%%%%%%%%%% 100%
Phase 3: OKTA Integration         %%%%%%%%%%%%%%%%%%%% 100%
Phase 4: Advanced Configuration   %%%%%%%%%%%%%%%%%%%% 100%
Phase 5: Advanced Security        %%%%%%%%____________  40% (Component 5.1 Complete)
Phase 6: Microsoft Entra ID       ____________________   0%
```

**Current Status:** Network-Based Conditional Access Operational
**Next Milestone:** Adaptive Multi-Factor Authentication (Phase 5.2)

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

### Security Infrastructure
- **Network Zones:** 3 total
  - IP Zones: 1 (Corporate Network)
  - Dynamic Zones: 2 (Allowed Countries, Tor Blocking)
- **Authentication Policy Rules:** 3
  - Priority 1: Restricted Countries (DENY)
  - Priority 2: Public Network (Hardware-Protected MFA)
  - Priority 3: Corporate Network (Standard MFA)
- **Geographic Controls:** Country-level access restrictions (United States)
- **Threat Protection:** Tor anonymizer proxy blocking enabled
- **MFA Enforcement:** 100% coverage across all access scenarios

### Infrastructure Components
- **Domain Controllers:** 1 (dc01.ad.biira.online)
- **OKTA AD Agents:** 1 (version 3.21.0)
- **DNS Architecture:** Split-brain (internal ad.biira.online + public biira.online)
- **SSO Portal:** login.biira.online
- **Network Segmentation:** EnterpriseLAN VLAN 50 (192.168.50.0/24)

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
- **Conditional Access**: Network-based policies, graduated security requirements
- **Risk-Based Authentication**: Context-aware MFA, hardware-protected factors
- **Geographic Controls**: Dynamic zones, country-level restrictions
- **Threat Intelligence**: Anonymous proxy detection, Tor blocking

### Financial Services Enterprise Standards
- Split-brain DNS for hybrid environments
- Tiered admin model (Privileged Access Workstation principles)
- Dual-account pattern for administrative access
- Naming conventions and documentation standards
- Change management and rollback procedures
- Regulatory compliance (GLBA, SOX, PCI-DSS, FFIEC, BSA/AML)
- Expression Language for dynamic business logic
- Cross-protocol application integration strategies
- Zero-trust security architecture principles
- Defense-in-depth security layering
- Context-aware authentication policies

---

## Quick Start

### Prerequisites
- Windows Server 2025 (or 2019)
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
   - Adjust network zones for your IP ranges

---

## Security & Privacy

- **No sensitive data**: All configs are sanitized examples
- **Service account passwords**: Referenced in documentation, never committed
- **OKTA tenant details**: Masked in screenshots and configs
- **IP addresses**: Use your own network ranges
- **Real-world ready**: All configurations based on financial services enterprise standards

### Lab vs Production

While this lab follows financial services enterprise standards, remember:
- Homelab environments lack physical security controls
- Not all configurations scale to 10,000+ users without optimization
- Some features require enterprise licensing (Entra ID P2, OKTA Workforce Identity)
- Advanced security features (PAM, advanced MFA) require additional implementation

---

## Repository Structure

```
+-- assets/              # CSV data, screenshots, diagrams, videos
+-- docs/
|   +-- company-profile/ # Biira Bank organization profile and regulatory context
|   +-- guides/          # Step-by-step implementation guides (per phase)
+-- scripts/             # PowerShell scripts for AD automation
+-- download/            # Downloaded exports and images
```

---

## Contributing

This is a learning project, but feedback is welcome!

- **Found an issue?** Open a GitHub issue with details
- **Have a suggestion?** Submit a pull request with improvements
- **Want to share your adaptation?** Fork and link back!
- **Implementing similar lab?** Share your experience!

---

## Project Timeline

- **Phase 1-2:** Foundation and AD Structure (October 2024)
- **Phase 3:** OKTA Integration (November 2024)
- **Phase 4:** Advanced OKTA Configuration (November 2024)
- **Phase 5.1:** Network-Based Conditional Access (December 2024)
- **Phase 5.2-5.5:** Advanced Authentication Features (Planned Q1-Q2 2025)
- **Phase 6:** Microsoft Entra ID Integration (Planned Q2-Q3 2025)

---

## Author

**Noble W. Antwi**
Enterprise IAM Lab - Building regulatory-grade hybrid identity architecture for financial services

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/your-profile)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black)](https://github.com/noble-antwi)

---

## License

This project is for educational purposes. Configurations and scripts are provided as-is for learning and reference.

---

## Acknowledgments

- **OKTA** for Integrator program access
- **Microsoft** for comprehensive Active Directory documentation
- **Community** for inspiration and knowledge sharing
- **Homelab Community** for architectural guidance

---

**Last Updated:** December 2024
**Current Phase:** 5.1 (Network-Based Conditional Access) - COMPLETE
**Documentation Standard:** Financial Services Enterprise Grade

---

## What Is This?

This repository documents a **500-1000 user enterprise IAM environment** built from scratch. It simulates a state-chartered commercial bank's identity infrastructure with hybrid identity, zero-trust security, and modern access management -- mirroring real financial services enterprise implementations.

## Architecture

```
                        +---------------------+
                        |       OKTA          |<----> Microsoft Entra ID
                        |   (Primary IdP)     |       (Azure AD / M365)
                        +---------+-----------+
                                  | OKTA AD Agent
                                  v
+--------------------------------------------------------------+
|                    ON-PREMISES HOMELAB                         |
|  +----------------------------------------------------------+ |
|  |  Active Directory Domain: ad.biira.online                | |
|  |  UPN Suffix: biira.online | SSO: login.biira.online      | |
|  |  Domain Controller: DC01 (192.168.50.2)                  | |
|  +----------------------------------------------------------+ |
+--------------------------------------------------------------+
```

## Project Phases

| Phase | Focus | Status |
|-------|-------|--------|
| **Phase 1** | Foundation -- Windows Server, AD DS, DNS, Okta tenant setup | Complete |
| **Phase 2** | AD Structure -- Tiered admin model, OUs, security groups | Complete |
| **Phase 3** | Okta Integration -- AD agent, provisioning, attribute mapping | Complete |
| **Phase 4** | Advanced Okta -- SAML/SWA apps, group push, lifecycle management | Complete |
| **Phase 5** | Advanced Security -- Network zones, conditional access, MFA policies | In Progress |

## Quick Start

1. **Review the architecture** -- See [docs/guides/README.md](docs/guides/README.md) for the full architecture overview
2. **Follow the phases** -- Each phase has detailed implementation guides in `docs/guides/phase-X-*/`
3. **Use the scripts** -- PowerShell automation scripts in `scripts/` for bulk operations

## Key Technologies

- **Windows Server 2025** -- Domain Controller with AD DS
- **Okta Workforce Identity** -- Cloud IdP with directory integration
- **Microsoft Entra ID** -- Azure AD federation for M365
- **PowerShell** -- Automation scripts for user/group management

## Documentation

For comprehensive documentation, start with the [Implementation Guides](docs/guides/README.md) which contains:
- Detailed architecture diagrams
- Step-by-step configuration walkthroughs
- Troubleshooting guides
- Best practices and lessons learned

## License

This project is for educational and demonstration purposes.

---

*Built as a learning lab to develop financial services enterprise IAM skills through practical implementation.*
