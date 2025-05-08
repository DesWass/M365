<#

#>

# Get the UPN from the command line arguments.
param (
    [string]$UserPrincipalName = $null
)

# Connect to Exchange Online PowerShell (which includes Security & Compliance Center cmdlets)
Connect-IPPSSession -UserPrincipalName $UserPrincipalName

Execute-AzureADLabelSync