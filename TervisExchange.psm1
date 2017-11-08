function Import-TervisExchangePSSession {
    [CmdletBinding()]
    param ()

    $Sessions = Get-PsSession |
    Where ComputerName -eq "exchange2016.tervis.prv"
    
    $Sessions |
    Where State -eq "Broken" |
    Remove-PSSession

    $Session = $Sessions |
    Where State -eq "Opened" |
    Select -First 1

    if (-Not $Session) {
        $FunctionInfo = Get-Command Get-ExchangeMailbox -ErrorAction SilentlyContinue
        if ($FunctionInfo) {
            Remove-Module -Name $FunctionInfo.ModuleName            
        }
        
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://exchange2016.tervis.prv/PowerShell/       
    }

    $FunctionInfo = Get-Command Get-ExchangeMailbox -ErrorAction SilentlyContinue
    if (-not $FunctionInfo) {
        Import-Module (Import-PSSession $Session -DisableNameChecking -AllowClobber) -DisableNameChecking -Global -Prefix "Exchange"
    }
}

function Enable-TervisExchangeMailbox {
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]$UserPrincipalName
    )
    begin {
        Import-TervisExchangePSSession
        $MailboxDatabase = Get-ExchangeMailboxDatabase | 
        Where Name -NotLike "Temp*" | 
        Select -Index 0 | 
        Select -ExpandProperty Name
    }
    process {
        Enable-ExchangeMailbox -Identity $UserPrincipalName -Database $MailboxDatabase
    }
}
