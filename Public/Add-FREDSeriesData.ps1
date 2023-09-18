Function Add-FREDSeriesData
{
    [CmdletBinding()]
    param
    ( [Parameter(Mandatory)][String]$SeriesID )

    BEGIN
    {
        $getSeries = { Invoke-Sqlcmd -Database $Script:database -Query "SELECT TOP (1) * FROM [dbo].[FRED_SERIES] WHERE [FredSeriesID] = '$SeriesID'" }

        if ($null -eq ($series = (& $getSeries)))
        {
            try { Add-FredSeries -SeriesID $SeriesID }
            catch { return $null }

            $series = & $getSeries
        }

        if ($series.FredSeriesID -eq $SeriesID)
        {
            ### Some entries have no data and are marked as a decimal in the value.
            ### We need to filter these out since the SQL column will only accept DECIMAL.
            $data = Get-FredSeriesData -SeriesID $SeriesID | Where-Object { $_.value -ne "." }

            if ($series.LastRecord.GetTypeCode() -ne "DBNull")
            { $data = $data | Where-Object { $_.date -gt [DateTime]$series.LastRecord} }

            ### I opted against using BULK INSERT due to complexity of implementation and will probably remove it from the Add-*HistoricalData
            ### function at some point. This uses regular insert up to the 1,000 row limit as many times as are needed to add the data.  It's
            ### not as fast or as light on the T-logs as BULK INSERT, but it's the next best thing, despite some math gynmastics.
            $writeSQL = { Invoke-Sqlcmd -Database $Script:database -Query "INSERT INTO [dbo].[FRED_HISTORY] VALUES `n$($values -join ",`n")" }
            
            if ($data.Count -le 1000)
            {
                [System.Collections.ArrayList]$values = @()
                for ($x = 0; $x -lt $data.Count; $x++)
                { [void]$values.Add("($($series.FredSeries),'$($data[$x].date)',$($data[$x].value))") }

                & $writeSQL
            }
            elseif ($data.Count -gt 1000)
            {
                $x = 0
                $offset = 0

                while ($x -lt $data.Count)
                {
                    [System.Collections.ArrayList]$values = @()
                    for ($x = ((999 * $offset) + $offset); $x -le (999 * ($offset + 1) + $offset); $x++)
                    {
                        if ($x -eq ($data.Count - 1)) { & $writeSQL; break }
                        [void]$values.Add("($($series.FredSeries),'$($data[$x].date)',$($data[$x].value))")
                    }

                    $offset++
                    if ($x -eq ($data.Count - 1)) { break }

                    & $writeSQL
                }
            }
        }
    }
}