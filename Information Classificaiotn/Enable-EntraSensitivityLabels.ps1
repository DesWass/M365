<#

.SYNOPSIS
    Enable sensitivity labels for Microsoft 365 Groups in Entra ID.

.DESCRIPTION
    This script enables sensitivity labels for Microsoft 365 Groups in Entra ID. It connects to the Microsoft Graph API, retrieves the current directory setting for Microsoft 365 Groups, and updates it to enable sensitivity labels.

.NOTES
    2025-05-09: Script created by Des Wass.

#>

Connect-MgGraph -Scopes "Directory.ReadWrite.All" -NoWelcome

$grpUnifiedSetting = Get-MgBetaDirectorySetting | Where-Object { $_.Values.Name -eq "EnableMIPLabels" }

Write-Output "Enabling sensitivity labels for Microsoft 365 Groups."
$params = @{
    Values = @(
        @{
            Name = "EnableMIPLabels"
            Value = "True"
        }
    )
}

Update-MgBetaDirectorySetting -DirectorySettingId $grpUnifiedSetting.Id -BodyParameter $params

Write-Host "Validate the change has been applied. 'EnableMIPLabels' should be set to 'True'." -ForegroundColor Green
$Setting = Get-MgBetaDirectorySetting -DirectorySettingId $grpUnifiedSetting.Id
$Setting.Values | Where-Object { $_.Name -eq "EnableMIPLabels" } | Select-Object Name, Value