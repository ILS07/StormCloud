Function Add-Stock
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)][String]$Symbol,
        [Parameter()][Switch]$NotActive = $false
    )

    PROCESS
    {
        if ($null -eq ($stockName = Get-StockName -Symbol $Symbol))
        { $stockName = "NULL" }

        $stockData = (Get-InstrumentInformation -Symbol ($Symbol.Replace(".","/"))).Stock
        $cusip = if ($stockData.cusip -ne "") { "'$($stockData.cusip)'" } else { "NULL" }
        ### May need a better field for dividends, possiblility of error.
        $div = if (($stockData.dividendType -eq "" -AND $stockData.annualizedDividend -eq "")) { 0 } else { 1 }
        # $gics = "'$((Invoke-Sqlcmd @db -Query "SELECT [GicsNode].ToString() FROM [dbo].[GICS] WHERE [GicsCode] = '$($stockData.gicsCode)'").Column1)'"
        if ($gics -eq "") { $gics = "NULL"}
        # $index = $null

        $options = switch ($stockData.optionTypes)
        {
            "--" { 0 }
            Default { 1 }
        }
        
        ### Can alternatively pull the CUSIP from StockAnalysis
        $stockIDs = try { Invoke-RestMethod -UseBasicParsing -uri "https://stockanalysis.com/api/symbol/s/$Symbol/profile" } catch { $null }
        $isin = if ($null -ne ($x = $stockIDs.data.details.isin)) { "'$x'" } else { "NULL" }
        $cik = if ($null -ne ($x = $stockIDs.data.details.cik)) { "'$x'" } else { "NULL" }
        $sic = if ($null -ne ($x = $stockIDs.data.details.sic)) { "'$x'" } else { "NULL" }
        #if ($cusip -eq "NULL") { $cusip = $stockData.data.details.cusip }

        foreach ($x in $($stockData.primaryExchange,$stockIDs.data.details.exchange))
        {
            $exch = switch -Wildcard ($x)
            {
                {$_ -like "NYSE*" -OR $_ -eq "AMERICAN*" -OR $_ -like "*ARCA*"} { "'XNYS'"; break }
                {$_ -like "NASDAQ*"} { "'XNAS'"; break }
                {$_ -like "BATS*" -OR $_ -like "BATY"} { "'XCBO'"; break }
                Default { "NULL" }
            }

            #if ($null -ne $exch) { break }
        }

        try
        {
            $query = `
            "EXEC [dbo].[Add_Stock]
            @stockSymbol = '$Symbol'
            ,@stockName = '$($stockName.Replace("'","''"))'
            ,@isActive = $($([int]!$NotActive.IsPresent))
            ,@exchCode = $exch
            ,@cusip = $cusip
            ,@cik = $cik
            ,@isin = $isin
            ,@sic = $sic
            ,@options = $options
            ,@dividend = $div
            ,@gics = '$($stockData.gicsCode)'"
             
            Invoke-Sqlcmd @Script:db -Query $query
        }
        catch
        { Write-Output "Unable to add '$Symbol' to the database!`n`n$($_.Exception.Message)" }
    }
}