# Create Department Security Groups

$domainDN = "DC=ad,DC=biira,DC=online"
$sgOU = "OU=SecurityGroups,OU=Groups,OU=BIIRA,$domainDN"

$departments = @("IT", "Finance", "HR", "Sales", "Marketing", "Executive")

Write-Host "`n=== Creating Department Groups ===" -ForegroundColor Cyan

foreach ($dept in $departments) {
    $groupName = "SG-Dept-$dept"
    
    $exists = Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue
    
    if ($exists) {
        Write-Host "Already exists: $groupName" -ForegroundColor Yellow
    } else {
        New-ADGroup -Name $groupName `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Path $sgOU `
                    -Description "$dept department access group"
        Write-Host "Created: $groupName" -ForegroundColor Green
    }
}

Write-Host "`n=== Department Groups Created ===" -ForegroundColor Cyan
Get-ADGroup -Filter "Name -like 'SG-Dept-*'" | Select-Object Name | Format-Table -AutoSize