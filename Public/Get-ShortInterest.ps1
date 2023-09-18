Function Get-ShortInterest
{
    [CmdletBinding()]
    param
    (
        [Parameter()][String]$SettlementDate,
        [Parameter()][String[]]$Symbol,
        [Parameter()][String]$SaveCopyPath = ""
    )

    BEGIN
    {
        Function SetBody
        {
            [CmdletBinding()]
            param
            (
                [Parameter()][String[]]$SymList,
                [Parameter()][String]$SettleDate,
                [Parameter()][Int]$Offset = 0
            )

            PROCESS
            {
                [System.Collections.ArrayList]$compFilter = @()
                [System.Collections.ArrayList]$orFilter = @()

                if ($SettleDate -ne "")
                {
                    [void]$compFilter.Add([PSCustomObject]@{
                        "fieldName" = "settlementDate"
                        "fieldValue" = $SettleDate
                        "compareType" = "EQUAL"
                    })
                }

                if ($SymList.Count -eq 1)
                {
                    [void]$compFilter.Add([PSCustomObject]@{
                        "fieldName" = "symbolCode"
                        "fieldValue" = $SymList[0]
                        "compareType" = "EQUAL"
                    })
                }
                elseif ($SymList.Count -gt 1)
                {
                    foreach ($x in $SymList)
                    {
                        [void]$orFilter.Add([PSCustomObject]@{
                            "fieldName" = "symbolCode"
                            "fieldValue" = $x
                            "compareType" = "EQUAL"
                        })
                    }
                }

                ### Kind of ugly, but condensed for minimum byte transmission since this can be repeated hundreds of times.
                ### Doing a from/to conversion would lose the nested comparative filters. May revisit later.
                $json = '
{"fields":["settlementDate","issueName","symbolCode","marketClassCode","currentShortPositionQuantity","previousShortPositionQuantity",
"changePreviousNumber","changePercent","averageDailyVolumeQuantity","daysToCoverQuantity","revisionFlag","stockSplitFlag"],
"dateRangeFilters": [],"domainFilters": [],
"compareFilters": ' + `
$(switch ($compFilter.Count)
{
    0 { "[]" }
    1 { "[$($($compFilter | ConvertTo-Json))]" }
    Default { "$($compFilter | ConvertTo-Json)" }
})  + ',"multiFieldMatchFilters":[],"orFilters":[' + `
$(switch ($orFilter.Count)
{ {$_ -gt 1} { '{"compareFilters": ' + $($orFilter | ConvertTo-Json) + "}" } })  + `
'],"aggregationFilter":null,"sortFields":["+symbolCode"],"limit":5000,"offset":' + "$Offset" + ',"delimiter":null,"quoteValues":false}'

                return $json
            }
        }

        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $session.UserAgent = $Script:userAgent
        $session.Cookies.Add((New-Object System.Net.Cookie("XSRF-TOKEN", "04176598-912d-41dc-8388-dc5fcbdd7612", "/", ".finra.org")))

        $params = @{
            Uri = "https://services-dynarep.ddwa.finra.org/public/reporting/v2/data/group/OTCMarket/name/ConsolidatedShortInterest"
            Method = "POST"
            WebSession = $session
            ContentType = "application/json"
            Headers = @{
                "authority"="services-dynarep.ddwa.finra.org"
                  "method"="POST"
                  "path"="/public/reporting/v2/data/group/OTCMarket/name/ConsolidatedShortInterest"
                  "scheme"="https"
                  "accept"="application/json, text/plain, */*"
                  "accept-encoding"="gzip, deflate, br"
                  "accept-language"="en-US,en;q=0.9"
                  "origin"="https://www.finra.org"
                  "referer"="https://www.finra.org/"
                  "sec-ch-ua"="`"Not.A/Brand`";v=`"8`", `"Chromium`";v=`"$Script:chromeVer`", `"Google Chrome`";v=`"$Script:chromeVer`""
                  "sec-ch-ua-mobile"="?0"
                  "sec-ch-ua-platform"="`"Windows`""
                  "sec-fetch-dest"="empty"
                  "sec-fetch-mode"="cors"
                  "sec-fetch-site"="same-site"
                  "x-xsrf-token"="04176598-912d-41dc-8388-dc5fcbdd7612"
            }
        }
    }

    PROCESS
    {
        try { $settle = ([DateTime]$SettlementDate).ToString("yyyy-MM-dd") }
        catch { return $null }

        #$settle = ([DateTime]$SettlementDate).ToString("yyyy-MM-dd")

        $initial = Invoke-RestMethod @params -Body (SetBody -SymList $Symbol -SettleDate $settle)
        [Int]$total = ($initial.returnBody.headers.'Record-Total')[0]

        if ($total -le 5000)
        { return (($initial).returnBody.data | ConvertFrom-Json) }
        elseif ($total -gt 5000)
        {
            [System.Collections.ArrayList]$returnData = @()

            foreach ($x in ((($initial).returnBody.data) | ConvertFrom-Json))
            { [void]$returnData.Add($x) }

            $page = switch ($total)
                    {
                        { $_ -lt 10000 } { 1; break }
                        { ($_ % 5000) -eq 0 } { $_ / 5000; break }
                        { $_ -gt 10000 } { [Math]::Floor($_ / 5000); break }
                    }
            
            for ($x = 1; $x -le $page; $x++)
            {
                foreach ($a in ((Invoke-RestMethod @params -Body (SetBody -SymList $Symbol -SettleDate $settle -Offset ($x * 5000))).returnBody.data | ConvertFrom-Json))
                { [void]$returnData.Add($a) }

                Start-Sleep -Seconds 1
            }

            if ($SaveCopyPath -ne "")
            { $returnData | Export-Csv "$SaveCopyPath\$settle.csv" -NoTypeInformation }

            return $returnData
                # | Select-Object @{N="Symbol";E={$_.symbolCode}},@{N="SettlementDate";E={$_.SettlementDate}},`
                # @{N="DaysToCover";E={$_.daysToCoverQuantity}},@{N="AvgDailyVolume";E={$_.averageDailyVolumeQuantity}},`
                # @{N="CurrentShortQty";E={$_.currentShortPositionQuantity}},@{N="PreviousShortQty";E={$_.previousShortPositionQuantity}},`
                # @{N="ChangePercent";E={$_.changePercent}},@{N="ChangeShortQty";E={$_.changePreviousNumber}}
        }
    }
}