$sid = Read-Host "What is the SID: "
function Convert-AzureAdSidToObjectId {
    <#
    .SYNOPSIS
    Convert a Azure AD SID to Object ID
     
    .DESCRIPTION
    Converts an Azure AD SID to Object ID.
    Author: Oliver Kieselbach (oliverkieselbach.com)
    The script is provided "AS IS" with no warranties.
     
    .PARAMETER ObjectID
    The SID to convert
    #>
    
        param([String] $Sid)
    
        $text = $sid.Replace('S-1-12-1-', '')
        $array = [UInt32[]]$text.Split('-')
    
        $bytes = New-Object 'Byte[]' 16
        [Buffer]::BlockCopy($array, 0, $bytes, 0, 16)
        [Guid]$guid = $bytes
    
        return $guid
    }
    
    
    #$sid = 
    $objectId = Convert-AzureAdSidToObjectId -Sid $sid
    Write-Output $objectId
    
    # Output:
    
    # Guid
    # ----
    # 73d664e4-0886-4a73-b745-c694da45ddb4