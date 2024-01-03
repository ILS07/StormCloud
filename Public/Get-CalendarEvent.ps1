Function Get-CalendarEvent
{
    [CmdletBinding()]
    param
    (
        [Parameter()][ValidateSet("Earnings","Splits")][String]$EventType = "Earnings",
        [Parameter()][DateTime]$StartDate = [System.DateTime]::Today,
        [Parameter()][DateTime]$EndDate = $StartDate.AddDays(6),
        [Parameter()][int16]$ReturnSize = 250
    )

    BEGIN
    {
        # if (!($Script:yahooAuth))
        # { return $null }

        [String]$StartDate = $StartDate.ToString("yyyy-MM-dd")
        [String]$EndDate = $EndDate.AddDays(1).ToString("yyyy-MM-dd")

        ### This will be for "other" items to include based on the event.
        ### For "Earnings", this will be whether "Before Open" or "After Close"
        $extras = switch ($EventType)
        {
            "Earnings"
            {
                "'eventname',
                'startdatetimetype',
                'epsestimate'"
            }

            "Splits"
            {
                "'old_share_worth',
                'share_worth'"
            }
        }

        $params = @{
            "Method" = "POST"
            "Uri" = "https://query1.finance.yahoo.com/v1/finance/visualization?crumb=$Script:yahooCrumb&lang=en-US&region=US&corsDomain=finance.yahoo.com"
            "ContentType" = "application/json"
            "WebSession" = $Script:yahoo
            "Body" = "{
                'sortType': 'DESC',
                'entityIdType': '$EventType',
                'sortField': 'startdatetime',
                'includeFields': [
                    'ticker',
                    'startdatetime',
                    $extras
                ],
                'query': {
                    'operator': 'and',
                    'operands': [
                        {
                            'operator': 'gte',
                            'operands': [
                                'startdatetime',
                                '$StartDate'
                            ]
                        },
                        {
                            'operator': 'lt',
                            'operands': [
                                'startdatetime',
                                '$EndDate'
                            ]
                        },
                        {
                            'operator': 'eq',
                            'operands': [
                                'region',
                                'us'
                            ]
                        }
                    ]
                },
                'offset': 0,
                'size': $ReturnSize
            }"
        }
    }

    PROCESS
    {
        [System.Collections.ArrayList]$returnData = @()
        $data = (Invoke-RestMethod @params).finance.result
        [Int]$total = $data.total

        foreach ($x in $data.documents.rows)
        {
            if ($returnData.Symbol -notcontains $x[0])
            {
                switch ($EventType)
                {
                    "Earnings"
                    {
                        if ($x[2] -like "*Earnings Release")
                        {
                            [void]$returnData.Add(([PSCustomObject]@{
                                "Event" = $EventType
                                "Symbol" = $x[0]
                                "Annoucement" = ([DateTime]$x[1]) #.ToString("MM/dd/yyyy h:mm tt")
                                "EPSEstimate" = $x[4]
                                # "EventTime" = ([DateTime]$x[1]).AddDays(1).ToString("hh:mm tt")
                                # "MarketPeriod" = switch ($x[3])
                                #     {
                                #         "AMC" { "After Close" }
                                #         "BMO" { "Before Open" }
                                #         Default { "Not Specified" }
                                #     }
                            }))
                        }
                    }

                    "Splits"
                    {
                        [void]$returnData.Add(([PSCustomObject]@{
                            "Event" = $EventType
                            "Symbol" = $x[0]
                            "EventDate" = ([DateTime]$x[1]).Date.AddDays(1).ToString("MM/dd/yyyy")
                            "Split" = "$($x[3]) : $($x[2])"
                            "SplitRatio" = $x[3] / $x[2]
                        }))
                    }
                }
                
            }
        }

        return $returnData

        # if ($total -le $ReturnSize)
        # { return $returnData }
        # else
        # {


        # }


        # foreach ($x in ((Invoke-RestMethod @params).finance.result.documents.rows))
        # {
        #     if ($returnData -notcontains $x)
        #     {
        #         [void]$returnData.Add(([PSCustomObject]@{
        #             "Event" = $EventType
        #             "Symbol" = $x[0]
        #             "EventDate" = ([DateTime]$x[1]).Date.AddDays(1)
        #         }))
        #     }
        # }

        # return $returnData
    }
}