
# Install modules if needed:
# Install-Module Microsoft.Graph.Users -Scope CurrentUser
# Install-Module Microsoft.Graph.Identity.DirectoryManagement -Scope CurrentUser
# Or install the meta module:
# Install-Module Microsoft.Graph -Scope CurrentUser

# Connect with scopes that allow reading user license/service plan data
Connect-MgGraph -Scopes "User.Read","Directory.Read.All"

# Get the current signed-in account (UPN)
$ctx = Get-MgContext
$meUpn = $ctx.Account

# 1) License details per SKU
$licenseDetails = Get-MgUserLicenseDetail -UserId $meUpn

# 2) Assigned plans directly from the user object (effective provisioning)
$user = Get-MgUser -UserId $meUpn -Property "assignedPlans" -Select "assignedPlans"
$assignedPlans = $user.AssignedPlans

# 3) Pull subscribed SKUs to help map SkuId -> SkuPartNumber (optional, but useful)
$subscribedSkus = Get-MgSubscribedSku

# Build lookups for friendly SKU data
$skuLookup = @{}
foreach ($sku in $subscribedSkus) {
    # Some tenants have multiple SKU entries: prefer the one with a part number
    $part = $sku.SkuPartNumber
    if ([string]::IsNullOrEmpty($part)) { $part = $sku.ServicePlans[0]?.ServicePlanName }
    $skuLookup[$sku.SkuId.Guid] = [PSCustomObject]@{
        SkuId         = $sku.SkuId.Guid
        SkuPartNumber = $part
        SkuDisplay    = $sku.PrepaidUnits?.Enabled ? $part : $part
        ServicePlans  = $sku.ServicePlans
    }
}

# Expand licenseDetails -> service plans (SKU-scoped)
$fromLicenseDetails = foreach ($lic in $licenseDetails) {
    $skuPart = if ($lic.SkuPartNumber) { $lic.SkuPartNumber } else { $skuLookup[$lic.SkuId.Guid]?.SkuPartNumber }
    foreach ($sp in $lic.ServicePlans) {
        [PSCustomObject]@{
            Source             = "licenseDetails"
            SkuId              = $lic.SkuId.Guid
            SkuPartNumber      = $skuPart
            ServicePlanName    = $sp.ServicePlanName
            ServicePlanId      = $sp.ServicePlanId
            ProvisioningStatus = $sp.ProvisioningStatus
            AppliesTo          = $sp.AppliesTo
        }
    }
}

# Expand assignedPlans -> service plans (effective user provisioning)
$fromAssignedPlans = foreach ($ap in $assignedPlans) {
    $skuPart = $skuLookup[$ap.CapabilityStatus] # not correct: we'll derive differently
}

# assignedPlans objects typically include:
#  - capabilityStatus (e.g. Enabled/Disabled)
#  - service (string)
#  - servicePlanId (GUID)
#  - assignedDateTime (ISO 8601)
# They DO NOT include SkuId; we’ll match the GUID to any known names we already have.

# Build a quick map of plan GUID -> name seen in licenseDetails/subscribedSkus
$planNameById = @{}
foreach ($item in $fromLicenseDetails) { $planNameById[$item.ServicePlanId] = $item.ServicePlanName }
foreach ($sku in $subscribedSkus) {
    foreach ($sp in $sku.ServicePlans) {
        if ($sp.ServicePlanId) {
            # Microsoft.Graph.Identity.DirectoryManagement returns ServicePlanId as GUID string
            $planNameById[$sp.ServicePlanId] = $sp.ServicePlanName
        }
    }
}

# Now transform assignedPlans using the plan name map
$fromAssignedPlans = foreach ($ap in $assignedPlans) {
    $planId = $ap.ServicePlanId
    $name = $planNameById[$planId]
    [PSCustomObject]@{
        Source             = "assignedPlans"
        SkuId              = $null
        SkuPartNumber      = $null
        ServicePlanName    = $name
        ServicePlanId      = $planId
        ProvisioningStatus = $ap.CapabilityStatus      # Enabled / Disabled
        AppliesTo          = $null
        AssignedDateTime   = $ap.AssignedDateTime
        Service            = $ap.Service               # High-level service category
    }
}

# Combine and present
$combined = $fromLicenseDetails + $fromAssignedPlans

Write-Host "`n=== Consolidated service plans (SKU-scoped and effective) ===`n" -ForegroundColor Cyan
$combined |
    Sort-Object Source, SkuPartNumber, ServicePlanName |
    Format-Table -AutoSize Source, SkuPartNumber, ServicePlanName, ServicePlanId, ProvisioningStatus

# Distinct list of GUIDs (the main thing you asked for)
Write-Host "`n=== Distinct service plan GUIDs (from both sources) ===`n" -ForegroundColor Cyan
$combined.ServicePlanId | Where-Object { $_ } | Sort-Object -Unique

# Optional: show only effectively enabled plans for the user
# $fromAssignedPlans | Where-Object { $_.ProvisioningStatus -eq 'Enabled' } |
#   Sort-Object ServicePlanName | Format-Table -AutoSize ServicePlanName, ServicePlanId, AssignedDateTime
