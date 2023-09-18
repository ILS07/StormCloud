Function Add-IndexHistoricalData
{
    [CmdletBinding()]
    param ( [Parameter()][String[]]$Symbol )

    PROCESS
    {
        if ($Symbol.Count -gt 0)
        { $filter = "WHERE [idx].[IndexCode] IN ('$($Symbol -join "','")')" }

        ### Sticking with [StockSymbol] since passing to an existing function that was designed with that in mind.
        $indexes = Invoke-Sqlcmd @db -Query `
            "SELECT
            [idx].[IndexID]
            ,[idx].[IndexCode] AS [StockSymbol]
            ,MAX([data].[TradingDate]) AS [Last]
            FROM [dbo].[MARKET_INDEX] [idx]
                LEFT JOIN [dbo].[MARKET_INDEX_HISTORY] [data]
                ON [idx].[IndexID] = [data].[IndexID] $filter
                GROUP BY [idx].[IndexID],[idx].[IndexCode]"

        foreach ($x in $indexes)
        {
            if ($null -eq ($parameters = Set-HistoricalDataParameters -ItemData $x -RecordType "Price"))
            { continue }

            if (($info = @(Get-StockHistoricalData @parameters | Where-Object { [DateTime]$_.Date -gt $x.Last })).Count -eq 0)
            { continue }

            if ($info.Count -gt 1000)
            {
                ### Use the folder holding the MDF file for temp storage of CSV since it's a known quantity.
                ### Column names must be specified in-line for BULK, so can take some massaging to get them to align.
                $tempPath = "$((Invoke-Sqlcmd -Query "SELECT SERVERPROPERTY('InstanceDefaultDataPath')").Column1)$($x.StockSymbol).csv"

                $info | Select-Object @{Name="IndexID";Expression={$($x.IndexID)}},@{Name="TradingDate";Expression={$_.Date}},`
                @{Name="OpenPrice";Expression={[Math]::Round($_.Open,4)}},@{Name="HighPrice";Expression={[Math]::Round($_.High,4)}},`
                @{Name="LowPrice";Expression={[Math]::Round($_.Low,4)}},@{Name="ClosePrice";Expression={[Math]::Round($_.Close,4)}},`
                @{Name="AdjClosePrice";Expression={[Math]::Round($_.'Adj Close',4)}},@{Name="Volume";Expression={$_.Volume}} | `
                ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_.Replace('"','').Replace("null","") } | Out-File $tempPath -Force

                try
                {
                    Invoke-Sqlcmd @db -Query ("BULK INSERT [dbo].[MARKET_INDEX_HISTORY] FROM '$tempPath' WITH ( FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2)")
                    ### Remove temp file if the insert was successful, leaving it will help in troubleshooting if a formatting or datatype issue.
                    if ($?)
                    { Remove-Item -Path $tempPath -Force }
                }
                catch { }
            }
            else
            {
                [System.Collections.ArrayList]$entries = @()

                foreach ($a in $info)
                {
                    [void]$entries.Add("($($x.IndexID),'$($entry.Date)',$([Math]::Round($entry.Open,4))," + `
                        "$([Math]::Round($entry.High,4)),$([Math]::Round($entry.Low,4)),$([Math]::Round($entry.Close,4))," + `
                        "$([Math]::Round($entry.'Adj Close',4)),$($entry.Volume))")
                }

                Invoke-Sqlcmd @db -Query ("INSERT INTO [dbo].[MARKET_INDEX_HISTORY] VALUES " + ($entries -join ","))
            }
        }
        
    }
}