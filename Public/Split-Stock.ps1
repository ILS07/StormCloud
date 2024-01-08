Function Split-Stock
{
    [CmdletBinding()]
    param
    ( 
        [Parameter(Mandatory)][String]$Symbol,
        [Parameter(Mandatory)][String]$SplitRatio,
        [Parameter(Mandatory)][DateTime]$SplitDate
    )

    PROCESS
    {
        if ($null -ne ($stkID = Invoke-Sqlcmd @Script:db -Query "SELECT [StockID] FROM [dbo].[STOCK] WHERE [StockSymbol] = '$Symbol'"))
        { break }

        $vals = @($SplitRatio -split ":")
        $factor = [int]$vals[0]/[int]$vals[1]

        Invoke-Sqlcmd @Script:database -Query "UPDATE [dbo].[PRICE_HISTORY] SET 
            [OpenPrice] = ([OpenPrice] / $factor)
            ,[HighPrice] = ([HighPrice] / $factor)
            ,[LowPrice] = ([LowPrice] / $factor)
            ,[ClosePrice] = ([ClosePrice] / $factor)
            ,[AdjClosePrice] = ([AdjClosePrice] / $factor)
            ,[Volume] = ([Volume] * $factor)
                WHERE [StockID] = $stkID AND [PriceDate] < '$($SplitDate.Date)'"

        ### May need to do the same for short interest.
        ### Waiting for an alignment of events to check.        
    }
}