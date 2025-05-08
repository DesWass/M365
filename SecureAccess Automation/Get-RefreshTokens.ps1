$ApplicationId = '27ae0072-8bd0-4a12-aead-7e2a83ea5ae9'
$ApplicationSecret = 'jte8Q~HodYn35H4lKi3P2pVrp3c3.SgIRHioLdov' | Convertto-SecureString -AsPlainText -Force
$TenantID = 'b0b5dc70-6792-4ce8-8298-05a08d698d9d'
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$token = New-PartnerAccessToken -ApplicationId $ApplicationID -Scopes 'https://api.partnercenter.microsoft.com/user_impersonation' -ServicePrincipal -Credential $credential -Tenant $TenantID -UseAuthorizationCode
$Exchangetoken = New-PartnerAccessToken -ApplicationId '27ae0072-8bd0-4a12-aead-7e2a83ea5ae9' -Scopes 'https://outlook.office365.com/.default' -Tenant $TenantID -UseDeviceAuthentication
Write-Host "================ Secrets ================"
Write-Host "`$ApplicationId         = $($applicationID)"
Write-Host "`$ApplicationSecret     = $($ApplicationSecret)"
Write-Host "`$TenantID              = $($tenantid)"
write-host "`$RefreshToken          = $($token.refreshtoken)" -ForegroundColor Blue
write-host "`$ExchangeRefreshToken  = $($ExchangeToken.Refreshtoken)" -ForegroundColor Green
Write-Host "================ Secrets ================"
Write-Host "    SAVE THESE IN A SECURE LOCATION     "
