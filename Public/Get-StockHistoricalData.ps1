Function Get-StockHistoricalData
{
    [CmdletBinding(DefaultParameterSetName = "PriceMax")]
    param
    (
        [Parameter(Mandatory,ValueFromPipeline,Position = 0,ParameterSetName = "PriceMax")]
        [Parameter(Mandatory,ValueFromPipeline,Position = 0,ParameterSetName = "DividendMax")]
        [Parameter(Mandatory,ValueFromPipeline,Position = 0,ParameterSetName = "SplitMax")]
        [Parameter(Mandatory,ValueFromPipeline,Position = 0,ParameterSetName = "PriceRange")]
        [Parameter(Mandatory,ValueFromPipeline,Position = 0,ParameterSetName = "DividendRange")]
        [Parameter(Mandatory,ValueFromPipeline,Position = 0,ParameterSetName = "SplitRange")]
            [String]$Symbol,
        [Parameter(Mandatory,Position = 1,ParameterSetName = "PriceRange")]
        [Parameter(Mandatory,Position = 1,ParameterSetName = "DividendRange")]
        [Parameter(Mandatory,Position = 1,ParameterSetName = "SplitRange")]
            [DateTime]$StartDate,
        [Parameter(Position = 2,ParameterSetName = "PriceRange")]
        [Parameter(Position = 2,ParameterSetName = "DividendRange")]
        [Parameter(Position = 2,ParameterSetName = "SplitRange")]
            [DateTime]$EndDate,
        [Parameter(ParameterSetName = "PriceMax")]
        [Parameter(ParameterSetName = "DividendMax")]
        [Parameter(ParameterSetName = "SplitMax")]
            [Parameter()][Switch]$MaxDateRange = $false,
        [Parameter(ParameterSetName = "PriceMax")]
        [Parameter(ParameterSetName = "PriceRange")]
            [Parameter()][Switch]$Price = $false,
        [Parameter(ParameterSetName = "DividendMax")]
        [Parameter(ParameterSetName = "DividendRange")]
            [Parameter()][Switch]$Dividend = $false,
        [Parameter(ParameterSetName = "SplitMax")]
        [Parameter(ParameterSetName = "SplitRange")]
            [Parameter()][Switch]$Split = $false
    )

    BEGIN
    {
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $session.UserAgent = $Script:userAgent

        $session.Cookies.Add((New-Object System.Net.Cookie("A1", "d=AQABBEcufmQCEIoSmSSHdY6xLuNQn7ilUnQFEgEBAQF_f2SIZNxS0iMA_eMAAA&S=AQAAAuvgs0Pmb1lz2D-pGZmdpMM", "/", ".yahoo.com")))
        $session.Cookies.Add((New-Object System.Net.Cookie("A3", "d=AQABBEcufmQCEIoSmSSHdY6xLuNQn7ilUnQFEgEBAQF_f2SIZNxS0iMA_eMAAA&S=AQAAAuvgs0Pmb1lz2D-pGZmdpMM", "/", ".yahoo.com")))
        $session.Cookies.Add((New-Object System.Net.Cookie("A1S", "d=AQABBEcufmQCEIoSmSSHdY6xLuNQn7ilUnQFEgEBAQF_f2SIZNxS0iMA_eMAAA&S=AQAAAuvgs0Pmb1lz2D-pGZmdpMM&j=US", "/", ".yahoo.com")))
        $session.Cookies.Add((New-Object System.Net.Cookie("cmp", "t=1685990985&j=0&u=1YNN", "/", ".yahoo.com")))
        $session.Cookies.Add((New-Object System.Net.Cookie("gpp", "DBABBgAA~BVoIgACQ.QAAA", "/", ".yahoo.com")))
        $session.Cookies.Add((New-Object System.Net.Cookie("gpp_sid", "8", "/", ".yahoo.com")))
        $session.Cookies.Add((New-Object System.Net.Cookie("tbla_id", "bd3fc1df-ad2e-4f44-8266-c2dfaac0f068-tuctb77b3ca", "/", ".yahoo.com")))
        $session.Cookies.Add((New-Object System.Net.Cookie("gam_id", "y-jKYlvoNE2uI0telE5gmOBavCPyn0AitO~A", "/", ".yahoo.com")))
        $session.Cookies.Add((New-Object System.Net.Cookie("B", "78kl5n1i7sbi7&b=3&s=u6", "/", ".yahoo.com")))
        $session.Cookies.Add((New-Object System.Net.Cookie("GUC", "AQEBAQFkf39kiEIccQQw", "/", ".yahoo.com")))
        #$session.Cookies.Add((New-Object System.Net.Cookie("PRF", "t%3D$Symbol%26newChartbetateaser%3D0%252C1687200592313", "/", ".finance.yahoo.com")))

        Function GetTheData([String]$stockInput)
        {
            # $day = 0
            # $now = [System.DateTime]::Now

            # if ([System.DayOfWeek].GetFields()[2..6].Name -contains [System.DateTime]::Today.DayOfWeek -AND $now -ge '17:30:00')
            # {
            #     $day = 1
            # }

            # [System.DateTime]::Now.AddHours([Math]::Abs([System.DateTimeOffset]::Now.Offset.Hours)).ToString("HH:mm:ss") -eq '15:29:10'

            if ($PSCmdlet.ParameterSetName -like "*Max")
            {
                $StartDate = -2177452800
                $EndDate = [System.DateTime]::Today.AddDays(1)
            }
            else
            {
                # if ($EndDate -gt [System.DateTime]::Today -OR $null -eq $EndDate)
                # { $EndDate = [System.DateTime]::Today } #.AddDays(1) }

                # if ($StartDate -gt $EndDate)
                # {
                #     if ($StartDate -ge [System.DateTime]::Today)
                #     {
                #         $StartDate = [System.DateTime]::Today.AddDays(-1)
                #         $EndDate = [System.DateTime]::Today
                #     }
                #     else
                #     { $StartDate = $EndDate.AddDays(-1) }
                # }

                # if ($StartDate -eq $EndDate)
                # { $EndDate = $EndDate.AddDays(1) }

                ### Convert DateTime information to integer of seconds from UNIX base time
                [int]$StartDate = (New-TimeSpan -Start $dateBase -End $StartDate).TotalSeconds
            }

            ### Convert to epoch date, removing the seconds via modulo operation.
            [int]$EndDate = (New-TimeSpan -Start $dateBase -End $EndDate).TotalSeconds
            $StartDate = ($StartDate - ($StartDate % 86400)).ToString()
            $EndDate = ($EndDate - ($EndDate % 86400)).ToString()

            $report = switch -Wildcard ($PSCmdlet.ParameterSetName)
            {
                "Price*" { "history" }
                "Dividend*" { "div" }
                "Split*" { "split" }
            }

            ### Had to add a conditional filter to check for Close to not have "null" as a value.
            ### At least the VIX would show every day, including non-trading days with no values.
            return (Invoke-WebRequest -UseBasicParsing -Uri ("https://query1.finance.yahoo.com/v7/finance/download/" + `
                $stockInput + "?period1=" + $StartDate + "&period2=" + $EndDate + `
                "&interval=1d&events=" + $report + "&includeAdjustedClose=true") `
                -WebSession $session -Headers `
                    @{"authority"="query1.finance.yahoo.com"
                    "method"="GET"
                    "path"="/v7/finance/download/$Symbol`?period1=$StartDate&period2=$EndDate&interval=1d&events=$report&includeAdjustedClose=true"
                    "scheme"="https"
                    "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
                    "accept-encoding"="gzip, deflate, br"
                    "accept-language"="en-US,en;q=0.9"
                    # "referer"="https://finance.yahoo.com/quote/$Symbol/history?period1=$StartDate&period2=$EndDate&interval=1d&filter=$report&frequency=1d&includeAdjustedClose=true"
                    "sec-ch-ua"="`"Not.A/Brand`";v=`"8`", `"Chromium`";v=`"$Script:chromeVer`", `"Google Chrome`";v=`"$Script:chromeVer`""
                    "sec-ch-ua-mobile"="?0"
                    "sec-ch-ua-platform"="`"Windows`""
                    "sec-fetch-dest"="document"
                    "sec-fetch-mode"="navigate"
                    "sec-fetch-site"="same-site"
                    "sec-fetch-user"="?1"
                    "upgrade-insecure-requests"="1"}
                ).Content | ConvertFrom-CSV | Where-Object { $_.Close -ne "null" } | Sort-Object Date -Descending
        }

        # $progress = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
        ### Yahoo offsets their time stamps in seconds either negative or positve from the UNIX epoch (midnight, January 1, 1970).
        [DateTime]$dateBase = "01/01/1970"
    }

    PROCESS
    {
        ### Yahoo has some symbols prefixed with special chars, like ^DJI for the Dow. These need to be converted to be HTML friendly.
        ### And for some reason they use hyphens where everyone else uses dots, so BRK.B is BRK-B to Yahoo, so need to check for both.
        $stock = [System.Web.HttpUtility]::UrlEncode($Symbol)

        try
        {
            try { GetTheData $stock }
            catch { GetTheData ($stock.Replace(".","-")) }
        }
        catch
        { }
    }

    #  END { $ProgressPreference = $progress }
}