# Enterprise IAM Lab Documentation

## Implementation Phases

### [Phase 1: Foundation](phase-1-foundation/)
- Windows Server 2022 deployment
- Active Directory setup
- OKTA tenant configuration

### [Phase 2: AD Structure](phase-2-ad-structure/) 
- OU hierarchy implementation
- User provisioning (27 employees)
- Administrative accounts (7 admin accounts)

### [Phase 3: OKTA Integration](phase-3-okta-integration/)
- AD Agent installation
- Directory synchronization
- Advanced provisioning

### [Phase 4: Advanced OKTA](phase-4-advanced-okta/) 
- Expression Language automation
- SAML/SWA application integration  
- Enterprise operational procedures

### [Phase 5: Advanced Security](phase-5-advanced-security/)
- Network-based conditional access
- IP and dynamic network zones
- Authentication policy rules
- Tor anonymizer blocking

## Quick Reference
- **Total Users:** 35 (27 employees + 7 admins + 1 service account)
- **Applications Integrated:** 2 (Dropbox Business, Box)
- **Authentication Protocols:** SAML 2.0, SWA
- **Automation:** Geographic group assignment, automated provisioning
- **Network Zones:** 3 (Corporate, Allowed Countries, Tor Blocking)
- **Authentication Policies:** 3 graduated security rules
- **MFA Enforcement:** 100% across all access scenarios