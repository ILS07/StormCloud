Function Get-SECFilingIndex
{
    [CmdletBinding()]
    param
    (
        [Parameter()][DateTime]$StartDate = "01/01/1993",
        [Parameter()][DateTime]$EndDate = [System.DateTime]::Today,
        [Parameter()][String]$SavePath = "",
        [Parameter()][Switch]$NoReturn = $false
    )

    BEGIN
    {
        Function Get-CalendarQuarter ([DateTime]$Date)
        {
            $qtr = switch ($Date.DayOfYear)
            {
                ((1..(([DateTime]"03/31/$(($Date).Year)").DayOfYear)) -eq $_) { 1 }
                ((([DateTime]"04/01/$($Date.Year)").DayOfYear..([DateTime]"06/30/$($Date.Year)").DayOfYear) -eq $_) { 2 }
                ((([DateTime]"07/01/$($Date.Year)").DayOfYear..([DateTime]"09/30/$($Date.Year)").DayOfYear) -eq $_) { 3 }
                ((([DateTime]"10/01/$($Date.Year)").DayOfYear..([DateTime]"12/31/$($Date.Year)").DayOfYear) -eq $_) { 4 }
            }

            return $qtr
        }
    }

    PROCESS
    {
        [System.Collections.ArrayList]$report = @()
        $params = New-SECUserData
        $startQtr = Get-CalendarQuarter $StartDate
        $endQtr = Get-CalendarQuarter $EndDate

        for ($a = $StartDate.Year; $a -le $EndDate.Year; $a++)
        {
            $z = if ($a -eq $EndDate.Year) {$endQtr} else {4}
            for ($x = if ($a -eq $StartDate.Year) {$startQtr} else {1}; $x -le $z; $x++)
            {
                try
                {
                    $data = (Invoke-RestMethod -Method GET -UseBasicParsing -Headers $params `
                            -Uri "https://www.sec.gov/Archives/edgar/full-index/$a/QTR$x/company.idx").Split("`n")

                    [System.Collections.ArrayList]$temp = @()
                    $headRow = $data.IndexOf(($data[0..15] | Where-Object { $_ -like "*Form Type*" }))
                    $colForm = [RegEx]::Match($data[$headRow],'Company Name(.*)(?=Form Type)').Length
                    $colCIK = [RegEx]::Match($data[$headRow],'Company Name(.*)(?=CIK)').Length
                    $colDate = [RegEx]::Match($data[$headRow],'Company Name(.*)(?=Date Filed)').Length
                    $colFile = [RegEx]::Match($data[$headRow],'Company Name(.*)(?=File Name)').Length
                    
                    foreach ($r in ($data[($headRow + 2)..($data.Count - 1)]))
                    {
                        $dateFiled = ($r[$colDate..($colFile - 1)] -join "").Trim()

                        ### Cutting off the edgar/data/<CIK>/ part of the file name.
                        ### It's static and will reduce the data footprint in SQL.
                        ### Example: https://www.sec.gov/Archives/edgar/data/789019/0000891020-94-000070.txt

                        if ($dateFiled -ge $StartDate.ToString("yyyy-MM-dd") -AND $dateFiled -le $EndDate.ToString("yyyy-MM-dd") )
                        {
                            [void]$temp.Add([PSCustomObject]@{
                                "CompanyName" = ($r[0..($colForm - 1)] -join "").Trim()
                                "FormType" = ($r[$colForm..($colCIK - 1)] -join "").Trim()
                                "CIK" = ($r[$colCIK..($colDate - 1)] -join "").Trim()
                                "DateFiled" = $dateFiled
                                "FileName" = ((($r[$colFile..($r.Length - 1)] -join "").Trim()).Split("/")[-1]).Replace(".txt","")
                            })
                        }
                    }

                    if (!($NoReturn.IsPresent))
                    { foreach ($q in $temp) {[void]$report.Add($q)} }

                    if ($SavePath -ne "")
                    {
                        if (!(Test-Path "$SavePath\$a"))
                        { New-Item -Path "$SavePath\$a" -ItemType Directory -Force }

                        $temp | Export-Csv -Path "$SavePath\$a\Q$x.csv" -NoTypeInformation
                    }
                }
                catch
                { }
            }
        }

        if (!($NoReturn.IsPresent))
        { return ($report | Sort-Object DateFiled) }
    }
}