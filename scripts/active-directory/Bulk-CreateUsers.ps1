# Bulk user creation from CSV
$csvPath = "C:\Scripts\users.csv"
$domainDN = "DC=ad,DC=biira,DC=online"

# Import CSV
$users = Import-Csv $csvPath
Write-Host "`n=== Creating $($users.Count) Users ===" -ForegroundColor Cyan

foreach ($user in $users) {
    $username = "$($user.FirstName).$($user.LastName)".ToLower()
    $ou = "OU=$($user.Department),OU=Employees,OU=Users,OU=BIIRA,$domainDN"
    
    # Check if user exists
    $exists = Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue
    
    if ($exists) {
        Write-Host "Already exists: $username" -ForegroundColor Yellow
        continue
    }
    
    try {
        # Create user
        New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
                   -GivenName $user.FirstName `
                   -Surname $user.LastName `
                   -SamAccountName $username `
                   -UserPrincipalName $user.Email `
                   -EmailAddress $user.Email `
                   -Title $user.Title `
                   -Department $user.Department `
                   -Path $ou `
                   -AccountPassword (ConvertTo-SecureString "Welcome2Biira!" -AsPlainText -Force) `
                   -Enabled $true `
                   -ChangePasswordAtLogon $false
        
        # Add to OKTA sync group
        Add-ADGroupMember -Identity "SG-OKTA-AllUsers" -Members $username
        
        # Add to department group
        Add-ADGroupMember -Identity "SG-Dept-$($user.Department)" -Members $username
        
        Write-Host "Created: $username ($($user.Department))" -ForegroundColor Green
        
    } catch {
        Write-Host "Failed: $username - $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Milliseconds 200
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Total users in SG-OKTA-AllUsers: $((Get-ADGroupMember -Identity 'SG-OKTA-AllUsers').Count)" -ForegroundColor Green

# Show count by department
Write-Host "`nUsers by Department:" -ForegroundColor Cyan
Get-ADUser -Filter * -SearchBase "OU=Employees,OU=Users,OU=BIIRA,$domainDN" -Properties Department | 
    Group-Object Department | 
    Select-Object Name, Count | 
    Sort-Object Name | 
    Format-Table -AutoSize