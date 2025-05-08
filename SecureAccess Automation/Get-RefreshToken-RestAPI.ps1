# Define variables
$appId = '27ae0072-8bd0-4a12-aead-7e2a83ea5ae9'
$appSecret = 'SECRET'
$tenantId = 'b0b5dc70-6792-4ce8-8298-05a08d698d9d'
$scope = 'https://api.partnercenter.microsoft.com/.default'
$redirectUri = 'http://localhost:8400' # This should match the redirect URI registered in your app

# Construct authorization endpoint URL
$authEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize?client_id=$appId&response_type=code&redirect_uri=$redirectUri&scope=$scope"

# Navigate to authorization endpoint and obtain authorization code
Start-Process $authEndpoint
$code = Read-Host "Enter authorization code"

$body = "grant_type=authorization_code&client_id=$appId&client_secret=$appSecret&code=$code&redirect_uri=$redirectUri&scope=$scope"
$headers = @{ 'Content-Type' = 'application/x-www-form-urlencoded' }
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/token"
$response = Invoke-RestMethod -Method POST -Uri $tokenEndpoint -Body $body -Headers $headers

$AccessToken = $response.Access_Token
$AccessToken