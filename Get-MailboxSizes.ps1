
# Requires ExchangeOnlineManagement module
# Install-Module ExchangeOnlineManagement -Scope CurrentUser

Connect-ExchangeOnline -ShowBanner:$false

$mailboxes = Get-EXOMailbox -ResultSize Unlimited

$result = foreach ($mbx in $mailboxes) {
    $stats = Get-EXOMailboxStatistics -Identity $mbx.UserPrincipalName

    # Convert to GB safely
    $bytes = $stats.TotalItemSize.Value.ToBytes()
    $sizeGB = [math]::Round($bytes / 1GB, 2)

    [pscustomobject]@{
        DisplayName = $mbx.DisplayName
        Email       = $mbx.PrimarySmtpAddress
        SizeGB      = $sizeGB
    }
}

#$result | Sort-Object SizeGB -Descending | Format-Table -Auto
$result | Export-Csv -Path ".\MailboxSizes.csv" -NoTypeInformation -Encoding UTF8

