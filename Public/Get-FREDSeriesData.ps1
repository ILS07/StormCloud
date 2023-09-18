Function Get-FREDSeriesData
{
    [CmdletBinding()]
    param
    ( [Parameter(Mandatory)][String]$SeriesID )

    PROCESS
    {
        return ((Invoke-RestMethod -Method GET -Uri `
            "https://api.stlouisfed.org/fred/series/observations?series_id=$SeriesID&api_key=$Script:apiFRED&file_type=json").observations | `
                Select-Object date,value)
    }
}