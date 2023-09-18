Function Update-ShortInterestSchedule
{
    [System.Collections.ArrayList]$insert = @()

    foreach ($x in Get-ShortInterestSchedule)
    { [void]$insert.Add("('$($x.SettlementDate)','$($x.PublishDate)')") }

    Invoke-Sqlcmd -Database BULKDATA -Query "DELETE FROM [dbo].[SHORT_INTEREST_SCHEDULE]"
    Invoke-Sqlcmd -Database BULKDATA -Query "INSERT INTO [dbo].[SHORT_INTEREST_SCHEDULE] VALUES $($insert -join ",`n")"
}