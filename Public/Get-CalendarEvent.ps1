Function Get-CalendarEvent
{
    [CmdletBinding()]
    param
    (
        [Parameter()][ValidateSet("Earnings","Splits")][String]$EventType = "Earnings",
        [Parameter()][DateTime]$StartDate = [System.DateTime]::Today,
        [Parameter()][DateTime]$EndDate = $StartDate.AddDays(5)

    )

    BEGIN
    {
        # if (!($Script:yahooAuth))
        # { return $null }

        [String]$StartDate = $StartDate.ToString("yyyy-MM-dd")
        [String]$EndDate = $EndDate.AddDays(1).ToString("yyyy-MM-dd")
        $retSize = 250

        ### This will be for "other" items to include based on the event.
        ### For "Earnings", this will be whether "Before Open" or "After Close"
        $extras = switch ($EventType)
        {
            "Earnings"
            {

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
                    'startdatetime'
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
                'size': $retSize
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
                [void]$returnData.Add(([PSCustomObject]@{
                    "Event" = $EventType
                    "Symbol" = $x[0]
                    "EventDate" = ([DateTime]$x[1]).Date.AddDays(1).ToString("MM/dd/yyyy")
                }))
            }
        }

        return $returnData

        # if ($total -le $retSize)
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