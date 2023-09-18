Function Set-HistoricalDataParameters
{
    [CmdletBinding()]
    param
    (
        [Parameter()][PSCustomObject]$ItemData,
        [Parameter()][String]$RecordType

    )

    PROCESS
    {
        $params = [ordered]@{Symbol = $ItemData.StockSymbol; $RecordType = $true}

        ### Check if a stock has an entry or not by the "Last" property data type, and set the StartDate accordingly.
        switch ($ItemData.Last.GetTypeCode())
        {
            "DateTime"
            {
                ### Skip a stock if the date of the selected record is alredy current for the Friday before a weekend.
                if ((([System.DateTime]::Today.DayOfWeek -eq "Saturday") -AND ([System.DateTime]$ItemData.Last) -eq [System.DateTime]::Today.AddDays(-1)) -OR `
                (([System.DateTime]::Today.DayOfWeek -eq "Sunday") -AND ([System.DateTime]$ItemData.Last) -eq [System.DateTime]::Today.AddDays(-2)))
                { return $null }

                ### Skip a stock if the LAST date for the current item is the same as today's date.
                ### Don't recally why this is here, I can only think this was for an obscure scenario where multiple hits per day are performed.
                # if ($RecordType -eq "Price" -AND $ItemData.Last -eq [DateTime]::Today.Date)
                if ($ItemData.Last -eq [DateTime]::Today.Date)
                { return $null }

                $params.Add("StartDate",($ItemData.Last.AddDays(1)))
                break
            }
            "DBNull"
            {
                $params.Add("StartDate","1/1/1920")
                $ItemData.Last = [DateTime]"1/1/1920"
                break
            }
        }

        ### Check market hours to know to avoid intraday activity that could result in incomplete volume or wrong high/low for the day.
        $utcNow = ([System.DateTimeOffset]([System.DateTime]::Now)).UtcDateTime

        if (@("Sunday","Saturday") -notcontains $utcNow.DayOfWeek)
        {
            if ($utcNow.ToString("HH:mm:ss") -gt "20:01:00")
            { $params.Add("EndDate",([System.DateTime]::Today.AddDays(1))) }
            else { $params.Add("EndDate",([System.DateTime]::Today)) }
        }
        else { $params.Add("EndDate",([System.DateTime]::Today)) }

        return $params
    }
}