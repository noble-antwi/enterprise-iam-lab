# Create OKTA Integration Security Groups

$domainDN = "DC=ad,DC=biira,DC=online"
$sgOU = "OU=SecurityGroups,OU=Groups,OU=BIIRA,$domainDN"

# Define OKTA groups
$oktaGroups = @(
    @{Name="SG-OKTA-AllUsers"; Desc="All users synchronized to OKTA (primary sync scope)"},
    @{Name="SG-OKTA-Admins"; Desc="OKTA administrator console access"},
    @{Name="SG-OKTA-MFA-Exempt"; Desc="Users exempt from MFA requirements"}
)

Write-Host "`n=== Creating OKTA Security Groups ===" -ForegroundColor Cyan

foreach ($group in $oktaGroups) {
    $exists = Get-ADGroup -Filter "Name -eq '$($group.Name)'" -ErrorAction SilentlyContinue
    
    if ($exists) {
        Write-Host "Already exists: $($group.Name)" -ForegroundColor Yellow
    } else {
        New-ADGroup -Name $group.Name `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Path $sgOU `
                    -Description $group.Desc
        Write-Host " Created: $($group.Name)" -ForegroundColor Green
    }
}

# Verify
Write-Host "`n=== OKTA Groups Created ===" -ForegroundColor Cyan
Get-ADGroup -Filter "Name -like 'SG-OKTA-*'" | Select-Object Name, Description | Format-Table -AutoSize