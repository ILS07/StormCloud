Function Add-FREDSeries
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)][String]$SeriesID,
        [Parameter()][Switch]$Inactive = $false
    )

    PROCESS
    {
        if ($null -ne (Invoke-Sqlcmd @Script:db -Query "SELECT [FredSeriesID] FROM [FRED_SERIES] WHERE [FredSeriesID] = '$SeriesID'"))
        { Write-Output "'$SeriesID' already exists in the database."; return $null }

        try
        {
            if (($null -eq ($tree = Get-FREDCategoryTree -SeriesID $SeriesID)) -OR ($null -eq ($series = Get-FREDSeries -SeriesID $SeriesID)))
            { return $null }
        }
        catch { }

        try
        {
            foreach ($x in $tree[1..($tree.Count - 1)])
            {
                if ($null -eq (Invoke-Sqlcmd @Script:db -Query `
                    "SELECT [FredCatID] FROM [dbo].[FRED_CATEGORY] WHERE [FredCatID] = $($x.ID)"))
                {
                    Invoke-Sqlcmd @Script:db -Query `
                        "EXEC [dbo].[Add_FRED_Category]
                            @parentCatID = $($x.ParentID)
                            ,@thisCatID = $($x.ID)
                            ,@thisCatName = '$($x.Category)'"
                }
            }

            ### Some Series show "Daily, 7-Day" and the like, so we're taking the first
            ### frequency listed if there are more than one.  May need periodic checks.
            Invoke-Sqlcmd @Script:db -Query `
                "EXEC [dbo].[Add_FRED_Series]
                    @seriesID = '$($series.id)'
                    ,@categoryID = $($tree[-1].id)
                    ,@seriesTitle = '$($series.title)'
                    ,@isActive = $([int]!$Inactive.IsPresent)
                    ,@observeStart = '$($series.observation_start)'
                    ,@observeEnd = '$($series.observation_end)'
                    ,@freqLabel = '$(if (($temp = $series.frequency.Split(",").Trim()).Count -gt 1) { $temp[0] } else { $temp })'
                    ,@unitLabel = '$($series.units)'
                    ,@adjusted = $(if ($series.seasonal_adjustment -like 'Not*') { 0 } else { 1 })
                    ,@published = '$([DateTime]$series.last_updated)'"
        }
        catch { }
    }
}