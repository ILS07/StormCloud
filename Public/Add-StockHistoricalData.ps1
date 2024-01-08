Function Add-StockHistoricalData
{
    [CmdletBinding()]
    param
    (
        [Parameter()][String[]]$Symbol,
        [Parameter()][ValidateSet("Price","Dividend","Split")][String[]]$Record
        #[Parameter()][Int]$Delay # = 600
    )

    BEGIN
    {
        ### Record Type, SQL Table, Fields to insert on
        $data = @{
        "Price" = @("PRICE_HISTORY","([StockID],[PriceDate],[OpenPrice],[HighPrice],[LowPrice],[ClosePrice],[AdjClosePrice],[Volume])")
        "Dividend" = @("DIVIDEND_HISTORY","([StockID],[DividendDate],[DividendAmount])")
        "Split" = @("SPLIT_HISTORY","([StockID],[SplitDate],[SplitRatio])") }

        if ($Record.Count -eq 0)
        { $Record = @("Price","Dividend","Split") }
    }

    PROCESS
    {
        foreach ($y in $Record)
        {
            $baseQuery = "INSERT INTO [dbo].[$($data[$y][0])] $($data[$y][1]) VALUES "
            $filter1 = $null
            $filter2 = $null

            ### If a Dividend record, apply a conditional filter so that only stocks that have dividends are returned.
            ### This will reduce calls for non-pertinent stocks and reduce wait time.
            if ($y -eq "Dividend") { $filter1 = "AND [stk].[HasDividend] = 1" }
            ### If one or more symbol(s) are specified, apply a conditional filter to return only those stocks.
            if ($Symbol.Count -gt 0)
            { $filter2 = "AND [stk].[StockSymbol] IN ('$($Symbol -join "','")')" }

            $stocks = Invoke-Sqlcmd @Script:db -Query `
                "SELECT
                [stk].[StockID]
                ,[stk].[StockSymbol]
                ,MAX([data].[$y`Date]) AS [Last]
                FROM [dbo].[STOCK] [stk]
                    LEFT JOIN [dbo].[$($data[$y][0])] [data]
                    ON [stk].[StockID] = [data].[StockID]
                        WHERE [stk].[IsActive] = 1 $filter1 $filter2
                    GROUP BY [stk].[StockID],[stk].[StockSymbol]"

            foreach ($x in $stocks)
            {
                if ($null -eq ($parameters = Set-HistoricalDataParameters -ItemData $x -RecordType $y))
                { continue }

                ### Check if there's no data and skip the stock if so.
                if (($info = @(Get-StockHistoricalData @parameters | Where-Object { [DateTime]$_.Date -gt $x.Last })).Count -eq 0)
                { continue }

                ### Price is the heavy transaction hitter, so if there's more than 1000 records, we'll use BULK INSERT from a
                ### CSV to help keep the transaction log size down. Anything a thousand or less will go through the loop for a max INSERT query.
                if ($info.Count -gt 1000 -AND $y -eq "Price")
                {
                    ### Use the folder holding the MDF file for temp storage of CSV since it's a known quantity.
                    ### Column names must be specified in-line for BULK, so can take some massaging to get them to align.
                    $tempPath = "$((Invoke-Sqlcmd -Query "SELECT SERVERPROPERTY('InstanceDefaultDataPath')").Column1)$($x.StockSymbol).csv"

                    $info | Select-Object @{Name="StockID";Expression={$($x.StockID)}},@{Name="PriceDate";Expression={$_.Date}},`
                    @{Name="OpenPrice";Expression={[Math]::Round($_.Open,4)}},@{Name="HighPrice";Expression={[Math]::Round($_.High,4)}},`
                    @{Name="LowPrice";Expression={[Math]::Round($_.Low,4)}},@{Name="ClosePrice";Expression={[Math]::Round($_.Close,4)}},`
                    @{Name="AdjClosePrice";Expression={[Math]::Round($_.'Adj Close',4)}},@{Name="Volume";Expression={$_.Volume}} | `
                    ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_.Replace('"','').Replace("null","") } | Out-File $tempPath -Force

                    try
                    {
                        Invoke-Sqlcmd @Script:db -Query ("BULK INSERT [dbo].[PRICE_HISTORY] FROM '$tempPath' WITH ( FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2)")
                        ### Remove temp file if the insert was successful, leaving it will help in troubleshooting if a formatting or datatype issue.
                        if ($?)
                        { Remove-Item -Path $tempPath -Force }
                    }
                    catch { }
                }
                else
                {
                    [System.Collections.ArrayList]$entries = @()

                    switch ($y)
                    {
                        "Price"
                        {
                            foreach ($a in $info)
                            {
                                [void]$entries.Add("($($x.StockID),'$($a.Date)',$([Math]::Round($a.Open,4))," + `
                                    "$([Math]::Round($a.High,4)),$([Math]::Round($a.Low,4)),$([Math]::Round($a.Close,4))," + `
                                    "$([Math]::Round($a.'Adj Close',4)),$($a.Volume))")
                            }
                        }

                        "Dividend"
                        {
                            foreach ($a in $info)
                            { [void]$entries.Add("($($x.StockID),'$($a.Date)',$($a.Dividends))") }
                        }

                        "Split"
                        {
                            foreach ($a in $info)
                            { [void]$entries.Add("($($x.StockID),'$($a.Date)','$($a.'Stock Splits')')") }
                        }
                    }

                    Invoke-Sqlcmd @Script:db -Query ($baseQuery + ($entries -join ","))
                }

                ### Gradually increase the delay as the stock count goes up to avoid tiggering a block. It can run faster, but no rush.
                ### I think 2,000 per hour is Yahoo's limit, so playing it a little safe on the upper end.
                switch ($stocks.Count)
                {
                    {$_ -le 1899} { Start-Sleep -Milliseconds 800 }
                    #{$_ -ge 1001 -AND $_ -le 1799} { Start-Sleep -Milliseconds 850 }
                    {$_ -ge 1900} { Start-Sleep -Milliseconds 1950 }
                }
            }
            
            if ($Record.Count -gt 1) { Start-Sleep -Milliseconds 600 }
        }
    }
}