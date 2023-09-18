Function Get-StockListingChange
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)][ValidateSet("Listed","Delisted")][String]$Action,
        [Parameter()][Int]$InLastDays = 7
    )

    BEGIN
    {
        $stocks = (Invoke-RestMethod -Method Get -Uri "https://stockanalysis.com/actions/$Action/__data.json").nodes[1].data
        [System.Collections.ArrayList]$report = @()
    }

    PROCESS
    {
        $data = $stocks[$stocks.IndexOf("slxw") + 1]

        foreach ($x in $data)
        {
            $temp = $stocks[$x]

            [void]$report.Add([PSCustomObject]@{
                "$Action`Date" = ([System.DateTime]$stocks[$temp.date]).ToShortDateString()
                "Symbol" = ($stocks[$temp.symbol]).Replace("$","")
                "Name" = $stocks[$temp.name]
            })
        }

        return ($report | Where-Object { [System.DateTime]$_."$Action`Date" -gt [System.DateTime]::Today.AddDays(-$InLastDays) })
    }
}