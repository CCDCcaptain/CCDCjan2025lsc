# firewall blocks all inbounding and only allows poer 80, 90, and 445
New-NetFirewallRule -DisplayName "Block All Inbound" -Direction Inbound -Action Block -Profile Any
New-NetFirewallRule -DisplayName "Allow HTTP Port 80" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "Allow Port 443" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow -Profile Any
#New-NetFirewallRule -DisplayName "Allow SMB Port 445" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Allow -Profile Any
Write-Host "Firewall rules configured."


# lists local admins
$localAdmins = Get-LocalGroupMember -Group "Administrators"
Write-Host "Local Administrators:"
$localAdmins | Select Name, PrincipalSource

# makes a new local admin
$newAdminName = "newAdminUser"
$newAdminPassword = ConvertTo-SecureString -String "P@ssw0rd123" -AsPlainText -Force #TEST PASSWORD PLEASE CHANGE LATER
New-LocalUser -Name $newAdminName -Password $newAdminPassword -FullName "New Administrator" -Description "Local administrator account"
Add-LocalGroupMember -Group "Administrators" -Member $newAdminName
Write-Host "New local admin created: $newAdminName"

# deletes the old local admins
$oldAdmins = $localAdmins | Where-Object { $_.Name -ne $newAdminName }
foreach ($admin in $oldAdmins) {
    Remove-LocalGroupMember -Group "Administrators" -Member $admin.Name
    Write-Host "Removed old local admin: $($admin.Name)"
}
Write-Host "Old local administrators deleted."

# lists all user account
# Get all Active Directory users
$users = Get-ADUser -Filter * | Select-Object SamAccountName

# New password to set for all users
$newPassword = "NewP@ssw0rd"  # You should use a secure password or prompt for one

Write-Host "Changing passwords for all Active Directory users..."

# Loop through each user and set the new password
foreach ($user in $users) {
    try {
        # Retrieve the user's description
        $userDescription = (Get-ADUser -Identity $user.SamAccountName -Properties Description).Description
        
        # Check if the description matches "zCCDC Scoring User"
        if ($userDescription -eq "zCCDC Scoring User") {
            Set-ADAccountPassword -Identity $user.SamAccountName -NewPassword (ConvertTo-SecureString -AsPlainText $newPassword -Force) -Reset
            Write-Host "Password for $($user.SamAccountName) changed successfully."
        } else {
            Write-Host "User $($user.SamAccountName) does not have the required description."
        }
    }
    catch {
        Write-Host "Failed to change password for $($user.SamAccountName): $_"
    }
}

#script done
Write-Host "Harden Script Done"

#192.168.10.153
#192.168.10.53


https://shorturl.at/VHPLk