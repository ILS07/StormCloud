Function Update-ShortInterest
{
    [CmdletBinding()]
    param
    (
        [Parameter()][String]$SettlementDate,
        [Parameter()][String]$SaveCopyPath = ""
    )

    PROCESS
    {
        if ($SettlementDate -eq "")
        {
            ### Reference the nearest publish/settlement date combo from the short interest schedule.
            $reference = (Invoke-Sqlcmd -Database BULKDATA -Query "SELECT * FROM [dbo].[SHORT_INTEREST_SCHEDULE]" | `
                Where-Object { $_.PublishDate -ge [System.DateTime]::Today })[0]

            if ([System.DateTime]::Now.Date.ToShortDateString() -ge $reference.PublishDate.ToShortDateString())
            { $SettlementDate = $reference.SettlementDate.ToString('yyyy-MM-dd') }
        }
        else
        {
            try
            {
                ### Since a NULL DateTime can't be entered, check if what was entered is a valid DateTime
                $SettlementDate = ([DateTime]$SettlementDate).ToString("yyyy-MM-dd")
            }
            catch { return $null }
        }

        ### Work out something to avoid INSERT errors in case a prior date is rerun and already exists
        # if ((Invoke-Sqlcmd -Database BULKDATA -Query "SELECT MAX([SettlementDate]) FROM [dbo].[SHORT_INTEREST]").Column1 -eq $SettlementDate)
        # { return $null }

        if ($null -ne ($short = (Get-ShortInterest -SettlementDate $SettlementDate -SaveCopyPath $SaveCopyPath) | `
            Select-Object @{N="Symbol";E={$_.symbolCode}},@{N="SettlementDate";E={$_.SettlementDate}},`
            @{N="DaysToCover";E={$_.daysToCoverQuantity}},@{N="AvgDailyVolume";E={$_.averageDailyVolumeQuantity}},`
            @{N="CurrentShortQty";E={$_.currentShortPositionQuantity}},@{N="PreviousShortQty";E={$_.previousShortPositionQuantity}},`
            @{N="ChangePercent";E={$_.changePercent}},@{N="ChangeShortQty";E={$_.changePreviousNumber}} ))
        {
            $sqlPath = "$((Invoke-Sqlcmd -Query "SELECT SERVERPROPERTY('InstanceDefaultDataPath')").Column1)Short.csv"
            
            $short | ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_.Replace('"','') } | Out-File $sqlPath -Force
            Invoke-Sqlcmd -Database BULKDATA -Query ("BULK INSERT [dbo].[SHORT_INTEREST] FROM '$sqlPath' WITH ( FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2)")
            try { Remove-Item -Path $sqlPath -Force } catch { }
        }

        ### If last date on the schedule, update the schedule for the new reporting year.
        if ($reference -eq $schedule[-1])
        { Update-ShortInterestSchedule }
    }
}