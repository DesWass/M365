$FirewallProfiles = Get-NetFirewallProfile | Where-Object { $_.Enabled -eq $false}
If(!$FirewallProfiles) { $ProfileStatus = "Healthy"} else { $ProfileStatus = "$($FirewallProfiles.name) Profile is disabled"}
$FirewallAllowed = Get-NetFirewallProfile | Where-Object { $_.DefaultInboundAction -ne "NotConfigured"}
If(!$FirewallAllowed) { $DefaultAction = "Healthy"} else { $DefaultAction = "$($FirewallAllowed.name) Profile is set to $($FirewallAllowed.DefaultInboundAction) inbound traffic"}