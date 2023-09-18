Function Get-FredSeries
{
    [CmdletBinding()]
    param ( [Parameter(Mandatory)][String[]]$SeriesID )

    BEGIN
    {

    }

    PROCESS
    {
        foreach ($x in $SeriesID)
        {
            try
            {
                if ($null -ne ($info = Invoke-RestMethod -Method GET -Uri "$Script:urlFRED/series?series_id=$x&api_key=$Script:apiFRED&file_type=json"))
                { return $info.seriess }
            }
            catch { }
        }
    }
}