# Biira Bank - Organization Profile

## Purpose

This document serves as the authoritative reference for the organizational context applied throughout the Enterprise IAM Lab project. All identity architecture decisions, access control implementations, and security configurations are justified against the regulatory and operational requirements of a state-chartered commercial bank.

---

## Organization Identity

| Attribute | Value |
|-----------|-------|
| **Legal Name** | Biira Bank |
| **Industry** | Financial Services -- Commercial Banking |
| **Charter Type** | State-chartered commercial bank (North Carolina) |
| **Primary Regulators** | North Carolina Commissioner of Banks (NCCOB), Federal Deposit Insurance Corporation (FDIC) |
| **Headquarters** | Charlotte, North Carolina, United States |
| **Founded** | 2006 |
| **Employee Count** | 500-1000 |
| **Operational Footprint** | Southeastern United States (North Carolina, South Carolina) with national digital banking services |
| **Stock Exchange** | NASDAQ (ticker: BIRA) |
| **Fiscal Year End** | December 31 |
| **Branch Network** | 12 locations across North Carolina and South Carolina |
| **Total Assets** | Approximately $4.2 billion |
| **Monthly Transaction Volume** | Approximately 2.3 million |

---

## Business Description

Biira Bank is a state-chartered commercial bank headquartered in Charlotte, North Carolina -- the second-largest banking center in the United States by total assets. The bank provides retail and commercial banking services to individuals, families, and small-to-medium businesses across the Southeastern United States. Core services include deposit accounts, consumer and commercial lending, mortgage origination, treasury management, wealth advisory services, and digital banking through web and mobile platforms.

As a state-chartered FDIC-insured institution, Biira Bank operates under dual regulatory oversight from the North Carolina Commissioner of Banks and the FDIC. The bank's publicly traded status on NASDAQ additionally subjects it to SEC reporting requirements and Sarbanes-Oxley compliance obligations.

---

## Department Structure

The following six departments map directly to the Active Directory OU structure implemented in the lab. The table below maps each department to its AD organizational unit, users, and banking-specific function.

### Department-to-AD Mapping

| Department | AD OU Path | User Count | Banking Function |
|-----------|-----------|-----------|-----------------|
| Executive Leadership | OU=Executive,OU=Employees,OU=Users,OU=BIIRA | 4 | Strategic direction, fiduciary responsibility, regulatory relationships |
| Information Technology | OU=IT,OU=Employees,OU=Users,OU=BIIRA | 6 | Infrastructure, cybersecurity, IAM, regulatory technology compliance |
| Finance | OU=Finance,OU=Employees,OU=Users,OU=BIIRA | 5 | Financial reporting, Call Reports, SEC filings, SOX compliance, treasury |
| Human Resources | OU=HR,OU=Employees,OU=Users,OU=BIIRA | 3 | Talent management, BSA/AML training, identity lifecycle triggering |
| Sales | OU=Sales,OU=Employees,OU=Users,OU=BIIRA | 5 | Relationship management, lending, wealth advisory, transaction processing |
| Marketing | OU=Marketing,OU=Employees,OU=Users,OU=BIIRA | 4 | Brand identity, digital presence, regulatory advertising compliance |

### Department Descriptions

**Executive Leadership (4 users)**

Provides strategic direction and maintains fiduciary responsibility to shareholders, regulators, depositors, and customers. The C-suite oversees all business lines and regulatory relationships from the Charlotte headquarters.

| Name | Title | AD Username |
|------|-------|-------------|
| David Brown | Chief Technology Officer | david.brown |
| Jessica Clark | Chief Financial Officer | jessica.clark |
| Laura King | Chief Operating Officer | laura.king |
| Stephanie Adams | Chief Marketing Officer | stephanie.adams |

**Information Technology (6 users)**

Operates as a centralized function providing infrastructure, cybersecurity, identity management, application support, and regulatory technology compliance. In a bank, IT is directly examined by FDIC and state regulators during IT examinations, making IAM controls a direct regulatory obligation rather than a best practice.

| Name | Title | AD Username |
|------|-------|-------------|
| John Smith | IT Manager | john.smith |
| Emily Davis | Network Engineer | emily.davis |
| Christopher Garcia | Security Analyst | christopher.garcia |
| Matthew Harris | DevOps Engineer | matthew.harris |
| Kevin Hall | Systems Engineer | kevin.hall |
| Justin Hill | Help Desk Lead | justin.hill |

**Finance (5 users)**

Manages financial reporting, regulatory filings (Call Reports, SEC filings), treasury operations, SOX compliance, and internal audit coordination. Finance staff access core banking platforms and financial reporting systems that are subject to SOX internal controls over financial reporting (ICFR).

| Name | Title | AD Username |
|------|-------|-------------|
| Sarah Williams | Finance Director | sarah.williams |
| Robert Martinez | Senior Accountant | robert.martinez |
| Jennifer Rodriguez | Compliance Analyst | jennifer.rodriguez |
| Nicole Allen | Treasury Analyst | nicole.allen |
| Rachel Scott | Financial Analyst | rachel.scott |

**Human Resources (3 users)**

Provides talent management, benefits administration, regulatory training compliance (BSA/AML training, information security awareness), and employee lifecycle management. HR actions (hire, transfer, termination) are the triggering events for identity provisioning and deprovisioning -- a direct FFIEC examination point.

| Name | Title | AD Username |
|------|-------|-------------|
| Mary Taylor | HR Director | mary.taylor |
| Amanda Walker | HR Generalist | amanda.walker |
| Tyler Green | Recruiting Coordinator | tyler.green |

**Sales (5 users)**

Encompasses client-facing relationship managers and business development professionals across retail banking, commercial banking, mortgage lending, and wealth advisory. These roles access customer financial data (GLBA-protected), process transactions (BSA/AML-monitored), and manage lending relationships.

| Name | Title | AD Username |
|------|-------|-------------|
| Michael Johnson | VP of Business Development | michael.johnson |
| James Wilson | Senior Relationship Manager | james.wilson |
| Daniel Lee | Commercial Banker | daniel.lee |
| Andrew Lewis | Mortgage Loan Officer | andrew.lewis |
| Brandon Wright | Financial Advisor | brandon.wright |

**Marketing (4 users)**

Manages brand identity, digital presence, client communications, and regulatory advertising compliance. Bank marketing materials are subject to Truth in Lending Act (TILA), Truth in Savings Act (TISA), and FDIC advertising requirements, requiring careful content review workflows.

| Name | Title | AD Username |
|------|-------|-------------|
| Lisa Anderson | Marketing Director | lisa.anderson |
| Patricia White | Digital Marketing Manager | patricia.white |
| Ryan Young | Content Specialist | ryan.young |
| Michelle Lopez | Graphic Designer | michelle.lopez |

---

## Regulatory Framework

The following regulations apply to Biira Bank and provide business justification for the technical implementations throughout this project.

### Gramm-Leach-Bliley Act (GLBA) - Safeguards Rule

**Oversight Body:** Federal Trade Commission (FTC), FDIC, State Banking Regulators

Requires the bank to develop, implement, and maintain a comprehensive information security program. Mandates access controls based on business need, MFA for accessing customer information systems, and encryption of customer data. The 2023 amendments added specific MFA and access control requirements.

**IAM Relevance:** Justifies every access control, MFA policy, and data protection measure in the project. The Safeguards Rule is the single broadest regulatory driver for IAM in a bank.

### Sarbanes-Oxley Act (SOX) - Sections 302 and 404

**Oversight Body:** Securities and Exchange Commission (SEC), Public Company Accounting Oversight Board (PCAOB)

As a publicly traded bank, Biira Bank must maintain internal controls over financial reporting (ICFR). SOX Section 302 requires CEO/CFO certification of financial reports. Section 404 requires management assessment and external auditor attestation of internal controls.

**IAM Relevance:** Justifies the tiered administrative model (separation of duties), access reviews, privileged access management, and audit trail requirements. Any system that touches financial data requires SOX-compliant access controls.

### Payment Card Industry Data Security Standard (PCI-DSS v4.0)

**Oversight Body:** PCI Security Standards Council

The bank processes credit and debit card transactions, requiring compliance with PCI-DSS.

**IAM Relevance:** Justifies unique user identification (Requirement 8), MFA for administrative access to cardholder data environments (Requirement 8.3), role-based access control (Requirement 7), and network segmentation (Requirement 1).

### FFIEC Authentication and Access Guidance (2021)

**Oversight Body:** Federal Financial Institutions Examination Council (FDIC, OCC, Federal Reserve, NCUA, State Regulators)

The FFIEC guidance provides the examination framework that FDIC and state examiners use to evaluate IAM controls during IT examinations. This is the single most important regulatory reference for this project because it directly defines examiner expectations for authentication, access management, and network architecture.

**IAM Relevance:** Justifies risk-based authentication, conditional access policies, network zone architecture, layered security controls, and anomalous activity monitoring.

### Bank Secrecy Act / Anti-Money Laundering (BSA/AML)

**Oversight Body:** Financial Crimes Enforcement Network (FinCEN), FDIC

Requires controls preventing use of banking services for money laundering and terrorist financing. The bank must file Currency Transaction Reports (CTRs) and Suspicious Activity Reports (SARs).

**IAM Relevance:** Justifies geographic access restrictions (network zones), transaction monitoring system access controls, and suspicious activity reporting access restrictions.

### SOC 2 Type II

**Oversight Body:** American Institute of Certified Public Accountants (AICPA)

The bank maintains SOC 2 certification for technology infrastructure. Trust service criteria (security, availability, processing integrity, confidentiality, privacy) align directly with IAM controls.

**IAM Relevance:** Provides third-party attestation that IAM controls operate effectively over time. SOC 2 criteria map to specific controls implemented in each phase.

---

## Data Classification

Biira Bank classifies data into four tiers that inform access control decisions throughout the IAM architecture.

| Classification | Description | Examples | Access Requirements |
|---------------|-------------|----------|-------------------|
| **Restricted** | Highest sensitivity; regulatory or legal exposure if disclosed | Customer SSNs, account numbers, cardholder data (PAN, CVV), examination reports | Explicit approval, MFA, full audit logging |
| **Confidential** | Business-sensitive; competitive or privacy impact if disclosed | Customer financial statements, loan applications, employee compensation, internal audit findings | Role-based authorization, audit logging |
| **Internal** | For internal use; no significant harm if disclosed to employees | Organizational charts, policies, project documentation, training materials | Authenticated employee status |
| **Public** | Approved for external distribution | Marketing materials, published financial statements, press releases | Basic authentication |

---

## Geographic and Operational Context

**Headquarters:** Charlotte, North Carolina -- the second-largest banking center in the United States by total assets, home to Bank of America and Truist Financial Corporation.

**Branch Network:** 12 locations across two states:
- North Carolina: Charlotte (headquarters + 4 branches), Raleigh (2 branches), Greensboro (1 branch), Winston-Salem (1 branch)
- South Carolina: Charleston (1 branch), Columbia (1 branch), Greenville (1 branch)

**Digital Banking:** National reach through web and mobile banking platforms, enabling deposit accounts, bill pay, mobile check deposit, and account management for customers nationwide.

**Operational Hours:** Branches operate Monday-Friday 9:00 AM - 5:00 PM ET, Saturday 9:00 AM - 1:00 PM ET. Digital banking and ATM services available 24/7. IT operations maintain 24/7 monitoring for critical infrastructure.

---

## IAM Architecture Justification by Phase

The following table maps each phase of the Enterprise IAM Lab to the regulatory requirements that justify the technical implementations.

| Phase | Implementation | Primary Regulatory Driver | Justification |
|-------|---------------|--------------------------|---------------|
| **Phase 1: Foundation** | Windows Server, AD DS, DNS, VLAN segmentation | FFIEC IT Examination, PCI-DSS Req. 1 | Segmented network environments for critical infrastructure; split-brain DNS protects internal systems from external exposure |
| **Phase 2: AD Structure** | Tiered admin model, OUs, security groups, dual-account pattern | SOX (separation of duties), GLBA (access controls), FFIEC (privileged access) | Separation of duties for financial system access; least-privilege administrative model; department-based access controls |
| **Phase 3: OKTA Integration** | AD Agent, directory sync, attribute mapping, admin isolation | GLBA Safeguards Rule, FFIEC cloud guidance | Authoritative identity source remains under institutional control; administrative credentials isolated from cloud environments |
| **Phase 4: Advanced OKTA** | SAML/SWA apps, Expression Language, provisioning, lifecycle management | SOX (automated controls), GLBA (least-privilege), FFIEC (automated lifecycle) | Automated provisioning reduces human error; least-privilege application access; automated deprovisioning prevents orphaned accounts |
| **Phase 5: Advanced Security** | Network zones, conditional access, MFA policies, geographic controls | FFIEC authentication guidance, BSA/AML, PCI-DSS Req. 8, GLBA Safeguards Rule | Risk-based authentication; geographic access restrictions for AML compliance; hardware-protected MFA for untrusted networks |
| **Phase 6: Entra ID** | Azure AD Connect, hybrid identity, M365 integration | FFIEC cloud computing guidance, GLBA | Extended hybrid identity with consistent access controls across cloud platforms |

---

**Document Type:** Organization Reference Profile
**Applies To:** All Enterprise IAM Lab documentation
**Last Updated:** December 2024
**Classification:** Internal
