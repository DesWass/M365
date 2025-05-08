<#

#>


$UserPrincipalName = "admin@M365B197291.onmicrosoft.com"

# Specify the name of the Microsoft Purview/Security & Compliance Center role group
# Examples: "Information Protection Admin", "Compliance Administrator"
$RoleGroupName = "Information Protection Admin"

try {
    # Connect to Exchange Online PowerShell (which includes Security & Compliance Center cmdlets)
    Connect-IPPSSession

    # Get the role group object
    $RoleGroup = Get-RoleGroup -Identity "$RoleGroupName"

    if ($RoleGroup) {
        # Check if the user is already a member
        $Member = Get-RoleGroupMember -Identity "$RoleGroupName" | Where-Object {$_.RecipientTypeDetails -eq "UserMailbox" -and $_.PrimarySmtpAddress -ceq $UserPrincipalName}

        if (-not $Member) {
            # Add the user to the role group
            Add-RoleGroupMember -Identity "$RoleGroupName" -Member "$UserPrincipalName"
            Write-Host "Successfully added user '$UserPrincipalName' to the role group '$RoleGroupName'." -ForegroundColor Green
        } else {
            Write-Host "User '$UserPrincipalName' is already a member of the role group '$RoleGroupName'." -ForegroundColor Yellow
        }
    } else {
        Write-Warning "Role group '$RoleGroupName' not found."
    }
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}
finally {
    # Disconnect the remote PowerShell session
    Disconnect-IPPSSession -Confirm:$false
}


