

# Make sure the Microsoft Graph module is installed.
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

# Import the Microsoft Graph Identity cmdlets.
Connect-MgGraph -Scopes "IdentityRiskyUser.Read.All" -ForceRefresh

# Get the Risky Users.
$riskyUsers = Get-MgRiskyUser -Filter "RiskLevel ne 'none'"

# Output the risky users to a table.
$riskyUsers |
    Select-Object -Property userDisplayName, userPrincipalName, riskLevel, riskState, riskLastUpdatedDateTime |
    Format-Table -AutoSize

# End.
