Function Sync-ShortInterest
{
    [CmdletBinding()]
    param (  [Parameter()][String[]]$Symbol )

    PROCESS
    {
        if ($Symbol.Count -gt 0)
        { $clause = "WHERE [StockSymbol] IN ('$($Symbol -join "','")')" }

        $stocks = @(Invoke-Sqlcmd @db -Query "SELECT [StockSymbol] FROM [dbo].[STOCK] $clause")

        if ($stocks.Count -gt 0)
        {
            foreach ($x in $stocks)
            { Invoke-Sqlcmd @db -Query "EXEC [dbo].[Sync_Short_Interest] @stockSymbol = '$($x.StockSymbol)'" }
        }
    }
}