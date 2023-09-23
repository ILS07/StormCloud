Function Sync-SECFiling
{
    [CmdletBinding()]
    param (  [Parameter()][String[]]$Symbol )

    PROCESS
    {
        if ($Symbol.Count -gt 0)
        { $clause = "WHERE [StockSymbol] IN ('$($Symbol -join "','")')" }

        $stocks = @(Invoke-Sqlcmd @Script:db -Query "SELECT [StockSymbol] FROM [dbo].[STOCK] $clause")

        if ($stocks.Count -gt 0)
        {
            foreach ($x in $stocks)
            { Invoke-Sqlcmd @Script:db -Query "EXEC [dbo].[Sync_SEC_Filing] @stockSymbol = '$($x.StockSymbol)'" }
        }
    }
}