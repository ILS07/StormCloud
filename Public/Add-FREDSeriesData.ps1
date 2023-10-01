Function Add-FREDSeriesData
{
    [CmdletBinding()]
    param
    ( [Parameter(Mandatory)][String]$SeriesID )

    BEGIN
    {
        $getSeries = { Invoke-Sqlcmd @Script:db -Query "SELECT TOP (1) * FROM [dbo].[FRED_SERIES] WHERE [FredSeriesID] = '$SeriesID'" }

        if ($null -eq ($series = (& $getSeries)))
        {
            try { Add-FredSeries -SeriesID $SeriesID }
            catch { return $null }

            $series = & $getSeries
        }

        if ($series.FredSeriesID -eq $SeriesID)
        {
            ### Some entries have no data and are marked as a single period in the value, so a CHAR.
            ### We need to filter these out since the SQL column will only accept actual DECIMAL values.
            $data = Get-FredSeriesData -SeriesID $SeriesID | Where-Object { $_.value -ne "." }

            if ($series.LastRecord.GetTypeCode() -ne "DBNull")
            { $data = $data | Where-Object { $_.date -gt [DateTime]$series.LastRecord} }

            $writeSQL = { Invoke-Sqlcmd @Script:db -Query "INSERT INTO [dbo].[FRED_HISTORY] VALUES `n$($values -join ",`n")" }
            
            if ($data.Count -le 1000)
            {
                [System.Collections.ArrayList]$values = @()
                for ($x = 0; $x -lt $data.Count; $x++)
                { [void]$values.Add("($($series.FredSeries),'$($data[$x].date)',$($data[$x].value))") }

                & $writeSQL
            }
            ### TO DO: Implement BULK INSERT if record count exceed 1,000...
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