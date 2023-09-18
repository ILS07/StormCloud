Function Get-EarningsCalendar
{
    [CmdletBinding()]
    param ( [Parameter()][Int]$InNextDays = 1 )

    BEGIN
    {
        $earnings = (Invoke-RestMethod -Method GET -Uri "https://stockanalysis.com/stocks/earnings-calendar/__data.json").nodes[1].data

        $time = [ordered]@{
            "bmo" = "Before Open"
            "amc" = "After Close"
        }

        [System.Collections.ArrayList]$report = @()
    }

    PROCESS
    {
        $data = foreach ($x in ($earnings[$earnings[$earnings[0].days]]))
        {
            if ([DateTime]$earnings[$x.date] -ge [System.DateTime]::Today.AddDays(1) -AND [DateTime]$earnings[$x.date] -le [System.DateTime]::Today.AddDays($InNextDays + 1))
            { $x | Select-Object date,day,@{N="index";E={$_.count}} }
        }

        for ($i = 0; $i -le ($data.Count - 2); $i++)
        {
            foreach ($x in ($earnings[($data[$i].date)..($data[$i + 1].date)] | Where-Object `
                { $null -ne $_ -AND $_.GetType().Name -eq "PSCustomObject" -AND ($_ | Get-Member).Name -contains "eg" }))
            {
                $eps = [Decimal]$earnings[$x.e]
                $rev = $earnings[$x.r]
                $date = [System.DateTime]$earnings[$data[$i].date]

                [void]$report.Add([PSCustomObject]@{
                    "ReportingDate" = $date #.ToShortDateString()
                    "Day" = $date.DayOfWeek
                    "Symbol" = $earnings[$x.s]
                    "CompanyName" = $earnings[$x.n]
                    "Reporting" = try { $time[$earnings[$x.t]] } catch { $null };
                    "EstimatedEPS" = try { if ($null -ne $eps) { $eps } else { $null }} catch { $null };
                    "EstimatedRevenue" = try { if ($null -ne $rev) { $rev.ToString("N0") } else { $null }} catch { $null };
                    "MarketCap" = try { ($earnings[$x.m]).ToString("N0") } catch { $null }
                })
            }
        }

        return $report | Sort-Object -Property @{Expression = "ReportingDate"; Descending = $false},@{Expression = "EstimatedEPS"; Descending = $true} | `
            Select-Object @{N="ReportingDate";E={$_.ReportingDate.ToShortDateString()}},Day,Symbol,CompanyName,Reporting,`
                @{N="EstimatedEPS";E={$_.EstimatedEPS.ToString("0.00")}},EstimatedRevenue,MarketCap

        # return $report | Sort-Object ReportingDate,EstimatedEPS -Descending | Select-Object `
        #     ReportingDate,Day,Symbol,CompanyName,Reporting,@{N="EstimatedEPS";E={$_.EstimatedEPS.ToString("0.00")}},`
        #     @{N="EstimatedRevenue";E={$_.EstimatedRevenue.ToString("N0")}},@{N="MarketCap";E={$_.MarketCap.ToString("N0")}}
    }
}