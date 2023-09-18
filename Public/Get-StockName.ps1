<#
.SYNOPSIS
Returns the company name for a given stock symbol.

.DESCRIPTION
A function to retrieve a company's name from Yahoo Finance for a stock symbol.

.PARAMETER Symbol
Specifies a stock symbol to reference a company name.

.EXAMPLE
Get-StockName -Symbol MSFT
#>
Function Get-StockName
{
    [Alias("Get-ETFName")]
    [CmdletBinding()]
    param ( [Parameter(Mandatory,ValueFromPipeline)][String]$Symbol )

    PROCESS
    {
        $ProgressPreference = "SilentlyContinue"

        try
        {
            $temp = [System.Web.HttpUtility]::HtmlDecode(([Regex]::Match((Invoke-WebRequest -UseBasicParsing -Uri `
                ("https://finance.yahoo.com/quote/$([System.Web.HttpUtility]::UrlEncode($Symbol.Replace(".","-")))")),`
                    "(?<=><title>)(.*?)(?= \x28$Symbol\x29 Stock Price,)").Value))
            
            ### Need to replace single apostrophe with double for SQL entry,
            ### check if calling func is one that edits any database.
            # switch ((Get-PSCallStack)[1].Command)
            # {
            #     (@("Add-Stock","Add-ETF","Update-StockName") -contains $_) { return ($temp.Replace("'","''")); break }
            #     Default {  }
            # }

            return $temp
        }
        catch { return $null }
    }
}