Function Get-ShortInterestSchedule
{
    $ProgressPreference = "SilentlyContinue"

    ### Not sure if intentional or accidental, but they have a non-breaking space between the year and the
    ### 'Short Interest...' label. It's possible future failures could be from this turning into a 'real' space.
    [xml]$data = [RegEx]::Match((Invoke-WebRequest -UseBasicParsing -Uri `
        "https://www.finra.org/filing-reporting/regulatory-filing-systems/short-interest").Content,`
        "(?<=<h2>2023$([char]0x00A0)Short Interest Reporting Dates<\/h2>\n\n)[\s\S]*(?=<hr \/><p>)").Value
    
    $fields = $data.table.tbody.tr.td | Where-Object { $_.'data-th' -notlike "Due Date*" }
    [System.Collections.ArrayList]$report = @()

    for ($i = 0; $i -le $fields.Count - 1; $i = $i + 2)
    {
        $settle = [DateTime]($fields[$i].p.strong)
        $rpt = ([DateTime]($fields[$i + 1].p.strong))
        
        [void]$report.Add([PSCUstomObject]@{
            "SettlementDate" = $settle
            "PublishDate" = if ((New-TimeSpan -Start $settle -End $rpt).Days -lt 0) {$rpt.AddYears(1)} else {$rpt}
        })
    }

    return $report
}