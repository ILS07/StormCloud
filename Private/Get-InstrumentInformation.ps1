<#
.DESCRIPTION
A function to retrieve a variety of data about a stock, such as Exchange,
CUSIP, GICS, 52-week Low/High, Earnings Reporting Date, etc.

.PARAMETER Symbol
Specifies one or more stock symbols for which to return data.

.EXAMPLE
Get-StockData -Symbol MSFT
Get-StockData -Symbol AAPL,GOOGL,LNG

.NOTES
Cookie data is experimental, may break at any time.
Header data is functional but is a WIP as well.
#>
Function Get-InstrumentInformation
{
    [CmdletBinding()] 
    param ( [Parameter(Mandatory)][String[]]$Symbol )

    BEGIN
    {
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $session.UserAgent = $Script:userAgent
        $session.Cookies.Add((New-Object System.Net.Cookie("_ap130058-res-exp.csrf", "Oe5qFARygQYVzPif8Paj-nuF", "/", "digital.fidelity.com")))
        $session.Cookies.Add((New-Object System.Net.Cookie("_pr110448-quick-quote.csrf", "vADtaJQeKjM8vJ8Uy3f-X02C", "/", "digital.fidelity.com")))

        [System.Collections.ArrayList]$stock = @()
        [System.Collections.ArrayList]$etf = @()
    }

    PROCESS
    {
        foreach ($x in $Symbol)
        {
            try
            {
                $temp = Invoke-RestMethod -UseBasicParsing -Uri "https://digital.fidelity.com/prgw/digital/research/api/quote" `
                        -Method "POST" `
                        -WebSession $session `
                        -Headers @{
                            "authority"="digital.fidelity.com"
                            "method"="POST"
                            "path"="/prgw/digital/research/api/quote"
                            "scheme"="https"
                            "accept"="application/json,text/html"
                            "accept-encoding"="gzip, deflate, br"
                            "accept-language"="en-US,en;q=0.9"
                            "ap130058-csrf-token"="gTmz7aUk-IMWJLgTApWxaLt-WFcrqZIqCM2M"
                            "origin"="https://digital.fidelity.com"
                            "sec-ch-ua"="`"Chromium`";v=`"$Script:chromeVer`", `"Not A(Brand`";v=`"24`", `"Google Chrome`";v=`"$Script:chromeVer`""
                            "sec-ch-ua-mobile"="?0"
                            "sec-ch-ua-platform"="`"Windows`""
                            "sec-fetch-dest"="empty"
                            "sec-fetch-mode"="cors"
                            "sec-fetch-site"="same-origin"
                            "x-csrf-token"="gTmz7aUk-IMWJLgTApWxaLt-WFcrqZIqCM2M" } `
                        -ContentType "application/json" `
                        -Body "{`"symbol`":`"$x`"}"

                if (($null -ne $temp) -AND ($temp -ne ""))
                {
                    if ($temp.GetType().Name -eq "PSCustomObject")
                    { [void]$stock.Add($temp.quoteData) }

                    if ($temp.GetType().Name -eq "String")
                    {
                        ### The exchange MIC identifiers are duplicated for some reason for ETFs.  This cleans
                        ### them up so the data can be converted to an object without errors or duplicated properties.
                        foreach ($a in ([RegEx]::Matches($temp,'(?="[a-z]{3,5}ExchangeMic).*?(?=",)",').Value))
                        { $temp = $temp.Replace($a,"") }

                        $temp = $temp | ConvertFrom-Json
                        [void]$etf.Add($temp.quoteData)
                    }
                }
            }
            catch
            { Write-Error $_.Exception.Message }

            if ($Symbol.Count -gt 10)
            { Start-Sleep -Milliseconds 250 }
        }

        ### Not sure why, but empty array objects can still get added,
        ### even though they are filtered out above.  Oh well...
        return ([PSCustomObject]@{
            "Stock" = ($stock | Where-Object {$_ -ne ""})
            "ETF" = ($etf | Where-Object {$_ -ne ""})})
    }
}