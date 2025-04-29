# 1. Connect
Connect-MgGraph -NoWelcome -Scopes UserAuthenticationMethod.Read.All,Directory.Read.All

# 2. Get Members only
$users  = Get-MgUser -Filter "userType eq 'Member'" -All -Property Id,UserPrincipalName
# 3. Thread-safe bag
$report = [System.Collections.Concurrent.ConcurrentBag[PSCustomObject]]::new()

# 4. Parallel processing
$users | ForEach-Object -Parallel {
    $u   = $_
    $bag = $using:report

    $row = @{
        UserPrincipalName          = $u.UserPrincipalName
        Phone                      = ''
        Authenticator_PushOrNumber = ''
        Authenticator_Passwordless = ''
        SoftwareOATH_TOTP          = ''
        FIDO2                      = ''
    }

    try {
        $methods = Get-MgUserAuthenticationMethod -UserId $u.Id
        foreach ($m in $methods) {
            switch ($m.ODataType) {
                '#microsoft.graph.phoneAuthenticationMethod' {
                    $row.Phone = "$($m.PhoneType) → $($m.PhoneNumber)"
                }
                '#microsoft.graph.microsoftAuthenticatorAuthenticationMethod' {
                    if ($m.CreatedDateTime) {
                        $row.Authenticator_Passwordless = $m.DisplayName
                    } else {
                        $row.Authenticator_PushOrNumber = $m.DisplayName
                    }
                }
                '#microsoft.graph.softwareOathAuthenticationMethod' {
                    $row.SoftwareOATH_TOTP = $m.DisplayName
                }
                '#microsoft.graph.fido2AuthenticationMethod' {
                    $row.FIDO2 = $m.DisplayName
                }
            }
        }
    } catch {
        Write-Warning "Failed on $($u.UserPrincipalName): $_"
    }

    # **Correct Add** using local $bag
    $bag.Add([PSCustomObject]$row)

} -ThrottleLimit 50

# 5. Output
$report |
  Sort-Object UserPrincipalName |
  Format-Table UserPrincipalName,Phone,Authenticator_PushOrNumber,Authenticator_Passwordless,SoftwareOATH_TOTP,FIDO2 -AutoSize

# 6. (Optional) Export to CSV
$report | Export-Csv -Path .\MFAUsageReport.csv -NoTypeInformation