
<#
.SYNOPSIS
  Check whether a customer has an MCA on file and return the acceptance date.

.DESCRIPTION
  Uses Partner Center PowerShell to query a specific customer (by GUID).
  Exits with code 0 if MCA is provided, 2 if not provided, and 1 on error.

.PARAMETER CustomerId
  The Partner Center CustomerId (tenant GUID) to query.

.PARAMETER Quiet
  If specified, outputs only the status line (handy for scripting).

.EXAMPLE
  .\Get-MCAStatus.ps1 -CustomerId 46a62ece-10ad-42e5-b3f1-b2ed53e6fc08

.EXAMPLE
  .\Get-MCAStatus.ps1 -CustomerId $env:CUSTOMER_ID -Quiet

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9a-fA-F-]{36}$')]
    [string]$CustomerId,

    [switch]$Quiet
)

# Fail fast on errors we don't handle
$ErrorActionPreference = 'Stop'

function Write-Status {
    param(
        [string]$Message,
        [ConsoleColor]$Colour = [ConsoleColor]::Gray
    )
    if (-not $Quiet) {
        $old = $Host.UI.RawUI.ForegroundColor
        $Host.UI.RawUI.ForegroundColor = $Colour
        Write-Host $Message
        $Host.UI.RawUI.ForegroundColor = $old
    } else {
        Write-Output $Message
    }
}

try {
    # Ensure module is available
    #if (-not (Get-Module -ListAvailable -Name PartnerCenter)) {
    #    Write-Status "PartnerCenter module not found. Install with: Install-Module PartnerCenter -Scope CurrentUser" Yellow
    #    throw "PartnerCenter module missing."
    #}

    #Import-Module PartnerCenter -ErrorAction Stop

    # Connect once per session; if already connected, this will reuse token
    #if (-not (Get-PartnerContext -ErrorAction SilentlyContinue)) {
    #    Write-Status "Connecting to Partner Center..." Cyan
    #    Connect-PartnerCenter -ErrorAction Stop | Out-Null
    #}

    # Query MCA status for the given customer
    # The AgreementType filter ensures we are checking the Microsoft Customer Agreement
    $agreement = Get-PartnerCustomerAgreement `
        -CustomerId $CustomerId `
        -AgreementType MicrosoftCustomerAgreement `
        -ErrorAction SilentlyContinue

    if ($null -ne $agreement) {
        # Acceptance found
        $contact = $null
        if ($agreement.PrimaryContact) {
            $contact = ("{0} {1} <{2}>" -f `
                $agreement.PrimaryContact.FirstName, `
                $agreement.PrimaryContact.LastName, `
                $agreement.PrimaryContact.Email).Trim()
        }

        $obj = [PSCustomObject]@{
            CustomerId    = $CustomerId
            AgreementType = $agreement.AgreementType
            Status        = 'Provided'
            DateAgreed    = $agreement.DateAgreed
            TemplateId    = $agreement.TemplateId
            Contact       = $contact
        }

        if ($Quiet) {
            "{0} | Provided | {1:yyyy-MM-dd}" -f $CustomerId, $agreement.DateAgreed
        } else {
            $obj | Format-List
        }

        exit 0
    }
    else {
        # No attestation present
        if ($Quiet) {
            "{0} | Not provided" -f $CustomerId
        } else {
            [PSCustomObject]@{
                CustomerId    = $CustomerId
                AgreementType = 'MicrosoftCustomerAgreement'
                Status        = 'Not provided'
                DateAgreed    = $null
            } | Format-List
        }

        # Exit code 2 to distinguish "not provided" from "error"
        exit 2
    }
}
catch {
    Write-Status "Error: $($_.Exception.Message)" Red
    exit 1
}
