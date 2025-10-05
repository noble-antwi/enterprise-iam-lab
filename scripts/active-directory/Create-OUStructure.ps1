# Enterprise OU Structure Creation Script
# Creates Tier 2 (Departments) + Tier 3 (Admin Tiers)

$domainDN = "DC=ad,DC=biira,DC=online"

# Define OU structure (order matters - create parents first)
$OUs = @(
    # Root OU
    @{Name="BIIRA"; Path=$domainDN; Description="Biira Enterprise Root OU"},
    
    # First Level OUs
    @{Name="Users"; Path="OU=BIIRA,$domainDN"; Description="All user accounts"},
    @{Name="Groups"; Path="OU=BIIRA,$domainDN"; Description="All security and distribution groups"},
    @{Name="Computers"; Path="OU=BIIRA,$domainDN"; Description="All computer objects"},
    @{Name="Admin"; Path="OU=BIIRA,$domainDN"; Description="Administrative accounts (Tiered model)"},
    
    # Users Sub-OUs
    @{Name="Employees"; Path="OU=Users,OU=BIIRA,$domainDN"; Description="Corporate employees"},
    @{Name="ServiceAccounts"; Path="OU=Users,OU=BIIRA,$domainDN"; Description="Application service accounts"},
    
    # Department OUs (under Employees)
    @{Name="IT"; Path="OU=Employees,OU=Users,OU=BIIRA,$domainDN"; Description="IT Department"},
    @{Name="Finance"; Path="OU=Employees,OU=Users,OU=BIIRA,$domainDN"; Description="Finance Department"},
    @{Name="HR"; Path="OU=Employees,OU=Users,OU=BIIRA,$domainDN"; Description="Human Resources"},
    @{Name="Sales"; Path="OU=Employees,OU=Users,OU=BIIRA,$domainDN"; Description="Sales Department"},
    @{Name="Marketing"; Path="OU=Employees,OU=Users,OU=BIIRA,$domainDN"; Description="Marketing Department"},
    @{Name="Executive"; Path="OU=Employees,OU=Users,OU=BIIRA,$domainDN"; Description="Executive Leadership"},
    
    # Groups Sub-OUs
    @{Name="SecurityGroups"; Path="OU=Groups,OU=BIIRA,$domainDN"; Description="Security groups for access control"},
    @{Name="DistributionLists"; Path="OU=Groups,OU=BIIRA,$domainDN"; Description="Email distribution groups"},
    
    # Computers Sub-OUs
    @{Name="Workstations"; Path="OU=Computers,OU=BIIRA,$domainDN"; Description="User workstations and laptops"},
    @{Name="Servers"; Path="OU=Computers,OU=BIIRA,$domainDN"; Description="Member servers"},
    
    # Admin Tier OUs (Microsoft Tiered Admin Model)
    @{Name="Tier0-DomainAdmins"; Path="OU=Admin,OU=BIIRA,$domainDN"; Description="Tier 0: Domain and forest administrators"},
    @{Name="Tier1-ServerAdmins"; Path="OU=Admin,OU=BIIRA,$domainDN"; Description="Tier 1: Server administrators"},
    @{Name="Tier2-WorkstationAdmins"; Path="OU=Admin,OU=BIIRA,$domainDN"; Description="Tier 2: Workstation support staff"}
)

# Create OUs
Write-Host "`n=== Creating Enterprise OU Structure ===" -ForegroundColor Cyan
Write-Host "Domain: $domainDN`n" -ForegroundColor Cyan

foreach ($OU in $OUs) {
    $ouDN = "OU=$($OU.Name),$($OU.Path)"
    
    # Check if OU already exists
    $exists = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDN'" -ErrorAction SilentlyContinue
    
    if ($exists) {
        Write-Host "Already exists: $($OU.Name)" -ForegroundColor Yellow
    } else {
        try {
            New-ADOrganizationalUnit -Name $OU.Name `
                                     -Path $OU.Path `
                                     -Description $OU.Description `
                                     -ProtectedFromAccidentalDeletion $true
            Write-Host "✅ Created: $($OU.Name)" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed: $($OU.Name) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    Start-Sleep -Milliseconds 200
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$totalOUs = (Get-ADOrganizationalUnit -Filter * -SearchBase "OU=BIIRA,$domainDN").Count
Write-Host "Total OUs created under BIIRA: $totalOUs" -ForegroundColor Green

# Display structure
Write-Host "`n=== OU Tree Structure ===" -ForegroundColor Cyan
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=BIIRA,$domainDN" | 
    Select-Object Name, DistinguishedName | 
    Sort-Object DistinguishedName | 
    Format-Table -AutoSize

Write-Host "`n✅ OU Structure creation complete!" -ForegroundColor Green