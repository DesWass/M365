#
# Monitor a tenant's MFA configuration and alert if anyone is using unsafe MFA  methosds, such as SMS.
#
# https://www.cnet.com/tech/services-and-software/do-you-use-sms-for-two-factor-authentication-heres-why-you-shouldnt/
#

#$TenantToCheck = 'prfau.onmicrosoft.com'
$TenantToCheck = Read-Host -Prompt 'Which tenant are you checking? (XXX.onmicrosoft.com)'
Write-Host "Checking $TenantToCheck for unsafe MFA access" -ForegroundColor Green
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID

Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
$customers = Get-MsolPartnerContract -All | where-object {$_.DefaultDomainName -eq $TenantToCheck}
Write-Host "Checking users now" -ForegroundColor Green
$MFAType = foreach ($customer in $customers) {
    $users = Get-MsolUser -TenantId $customer.tenantid -all
 
    foreach ($user in $users) {
        $primaryMFA = if ($null -ne $user.StrongAuthenticationUserDetails) { ($user.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $true }).methodType } else { "MFA Disabled" } 
        $SecondaryMFA = if ($null -ne $user.StrongAuthenticationUserDetails) { ($user.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $false }).methodType } else { "No Secondary Option enabled" } 
        [PSCustomObject]@{
            "DisplayName"   = $user.DisplayName
            "user"          = $user.UserPrincipalName
            "Primary MFA"   = $primaryMFA
            "Secondary MFA" = $SecondaryMFA
        }
    }
}
 
$UnSafeMFAUsers = $MFAType | Where-Object { $_.'Primary MFA' -like "*SMS*" -or $_.'Primary MFA' -like "*voice*" }
 
if (!$UnSafeMFAUsers) {
    $UnSafeMFAUsers = "Healthy"
    Write-Host "There are NO users with SMS-based MFA or Phone"
} else {
    foreach ($UnSafeUser in $UnSafeMFAUsers) {
        Write-Host "$UnSafeUser"
    }
}