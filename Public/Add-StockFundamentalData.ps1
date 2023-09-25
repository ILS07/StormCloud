Function Add-StockFundamentalData
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$Symbol,
        [Parameter()][ValidateSet("IncomeStatement","BalanceSheet","CashFlowStatement")][String[]]$Report
    )

    PROCESS
    {
        if ($Report.Count -eq 0)
        { $Report = @("IncomeStatement","BalanceSheet","CashFlowStatement") }

        if ($null -ne ($stockID = (Invoke-Sqlcmd @Script:db -Query "SELECT [StockID] FROM [dbo].[STOCK] WHERE [StockSymbol] = '$Symbol'").StockID))
        {
            foreach ($a in $Report)
            {
                $table = switch ($a)
                {
                    "IncomeStatement"{ "INCOME_STATEMENT" }
                    "BalanceSheet" { "BALANCE_SHEET" }
                    "CashFlowStatement" { "CASH_FLOW" }
                }

                $tempPath = "$((Invoke-Sqlcmd -Query "SELECT SERVERPROPERTY('InstanceDefaultDataPath')").Column1)$Symbol`_$a.csv"

                $excludeDates = @(Invoke-Sqlcmd @Script:db -Query "SELECT [ReportDate] FROM [dbo].[$table] WHERE [StockID] = $stockID" | Select-Object ReportDate)

                ### 09/24/2023 - Found an issue where some statements aren't filed quarterly.
                ### This results in a [PSCustomObject] being returned as opposed to an [Array].
                ### Add a condition to not insert if GetTypeCode() -eq "PSCustomObject"
                (Get-StockFundamentalData -Symbol $Symbol -Report $a | Where-Object { $excludeDates -notcontains $_.ReportDate }) | `
                    ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_.Replace('"','') } | Out-File $tempPath -Force

                Invoke-Sqlcmd @Script:db -Query ("BULK INSERT [dbo].[$table] FROM '$tempPath' WITH ( FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2)")
                
                try { Remove-Item -Path $tempPath -Force }
                catch { }

                if ($Report.Count -gt 1)
                { Start-Sleep -Milliseconds 750 }
            }
        }
        else
        { return $null }
    }
}