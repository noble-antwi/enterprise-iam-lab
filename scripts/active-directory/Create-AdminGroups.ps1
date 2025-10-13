# Create Admin Security Groups
# Run this on srv1 as Domain Admin

$domainDN = "DC=ad,DC=biira,DC=online"
$adminOU = "OU=Admin,OU=BIIRA,$domainDN"
$sgOU = "OU=SecurityGroups,OU=Groups,OU=BIIRA,$domainDN"

# Tier 0 Group
New-ADGroup -Name "SG-Tier0-DomainAdmins" `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $sgOU `
            -Description "Tier 0: Domain and forest administrators"

# Tier 1 Group
New-ADGroup -Name "SG-Tier1-ServerAdmins" `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $sgOU `
            -Description "Tier 1: Server infrastructure administrators"

# Tier 2 Group
New-ADGroup -Name "SG-Tier2-WorkstationAdmins" `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $sgOU `
            -Description "Tier 2: Workstation support and help desk"

Write-Host "`n=== Admin Groups Created ===" -ForegroundColor Cyan
Get-ADGroup -Filter "Name -like 'SG-Tier*'" | Select-Object Name, Description | Format-Table -AutoSize