### I'm trying to embrace PSCore more.  It behaves differently due to differences in its RFCs,
### so depending on if it's used, some things need to be set differently to work as designed.
### The reasoning is it's designed to work with Linux and Mac as well, so...
#############################################################################################################################
if ($PSEdition -eq "Desktop") { Add-Type -AssemblyName System.Web }

if ($PSVersionTable.PSVersion.Major -ge 6)
{
    $PSDefaultParameterValues.Add("Invoke-RestMethod:SkipHeaderValidation",$true)
    $PSDefaultParameterValues.Add("Invoke-RestMethod:SkipCertificateCheck",$true)
}


### Variables used throughout many functions of the module.
#############################################################################################################################
$Script:database = "FINDATA"
$Script:db = @{Database = $Script:database}

$Script:chromeVer = "120"
$Script:userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/$Script:chromeVer.0.0.0 Safari/537.36"

[Bool]$Script:yahooAuth = $true

### Yahoo persistent cookies.  Used for pulling historical income statements, balance sheets, etc.
#############################################################################################################################
$Script:yahoo = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$Script:yahoo.UserAgent = "$Script:userAgent Edg/$Script:chromeVer.0.0.0"
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("cmp", "t=1704201720&j=0&u=1YNN", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("gpp", "DBAA", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("gpp_sid", "-1", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("gam_id", "y-h7D88DJE2uLuvVq9ENYAey91UDFUVxgD~A", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("axids", "gam=y-h7D88DJE2uLuvVq9ENYAey91UDFUVxgD~A&dv360=eS1QWjJQdU01RTJ1RlVTRUhHVVdIWG41V2haRGtmeDBPa35B&ydsp=y-z9Ir7BRE2uI2Ox_o856Uwfh5vwBn_UWG~A", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("tbla_id", "03f37796-67e4-448f-9116-9d75e8668e2a-tuctc8d9390", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("__gpi", "UID=00000db043ba5a13:T=1704201744:RT=1704202721:S=ALNI_MZemPT-y0y6A0QyhD7rni06YWn6BQ", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("OTH", "v=2&s=2&d=eyJraWQiOiIwMTY0MGY5MDNhMjRlMWMxZjA5N2ViZGEyZDA5YjE5NmM5ZGUzZWQ5IiwiYWxnIjoiUlMyNTYifQ.eyJjdSI6eyJndWlkIjoiQk9XQ0paTFVXUlpORFY2MlNRWlpBQ1ZIMkUiLCJwZXJzaXN0ZW50Ijp0cnVlLCJzaWQiOiJiMmRpRDU0dHVmRGoifX0.gbxRefhWEw-Di61fjO4yuzxwWBGUJk9qmn9gmUulcWasKKn2MAE0IhgeVaetC0_KGhQEiogbVI0hhYXLKVkpBN96UoIn2OpSKFNOTNDS5ioWOPHk8ZXDeUuNv0TnfUhyDkTiZdoR0elKWnShwVKSn7vxLduR0WesOQ3yFSt7EC4", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("T", "af=JnRzPTE3MDQyMDI4MDImcHM9NlJ1ZW0xUE01Y2t3TGQ5WnQ4ajNtdy0t&d=bnMBeWFob28BZwFCT1dDSlpMVVdSWk5EVjYyU1FaWkFDVkgyRQFhYwFBT3piQWZBQQFhbAFid2hlZWxlckB3aGVlbGVydGVjaGluYy5jb20Bc2MBZGVza3RvcF93ZWIBZnMBbFNWa2V5MWxsQkl5AXp6AXlJQmxsQkE3RQFhAVFBRQFsYXQBeUlCbGxCAW51ATA-&kt=EAAFhX_z84drej8kUefiUutTA--~I&ku=FAABAFyX_zSZ_sll84qVOfgphcywWNsdzawrI_vnli9Fj1HORAPSTVUGRyaI7bhrSbl69Ej_FAsqWGTZ56yprW3vV6b.P.PXxUnl4GoVWwUj7fTa62FakamADtUXEZfqzJZ6ZrvDEUnKvE8FtDTnpFZqHjJXUeufadkjTPa.bXPCDc-~E", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("F", "d=XoCClfE9vDB8a4MEsBF1TF8NePkAg.L.iSkoDS9QRxTjQ7F8dAgqKdNkt30d0GA-", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("PH", "l=en-US", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("Y", "v=1&n=2ofbjh0keh4m1&l=pvxtxkmdvhspmad48f2du1gbun344m8wcgh1nun0/o&p=02ivvvv00000000&r=19q&intl=us", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("GUCS", "ARRrgL3p", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("GUC", "AQEACAJllV9lwEId_wSX&s=AQAAAOp9RXGQ&g=ZZQSPQ", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("A1", "d=AQABBDVeW2UCEKTJfd3g84Iobqw-vxgVZTgFEgEACAJflWXAZdxS0iMA_eMBAAcINV5bZRgVZTgID1e5lpuMm21f-C3rxPzheQkBBwoBbg&S=AQAAAhTuzTqYth8gWNqvKyEDuFQ", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("A3", "d=AQABBDVeW2UCEKTJfd3g84Iobqw-vxgVZTgFEgEACAJflWXAZdxS0iMA_eMBAAcINV5bZRgVZTgID1e5lpuMm21f-C3rxPzheQkBBwoBbg&S=AQAAAhTuzTqYth8gWNqvKyEDuFQ", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("A1S", "d=AQABBDVeW2UCEKTJfd3g84Iobqw-vxgVZTgFEgEACAJflWXAZdxS0iMA_eMBAAcINV5bZRgVZTgID1e5lpuMm21f-C3rxPzheQkBBwoBbg&S=AQAAAhTuzTqYth8gWNqvKyEDuFQ", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("PRF", "t%3DMSFT%26newChartbetateaser%3D1", "/", ".finance.yahoo.com")))

# try { Get-StockFundamentalData -Symbol MSFT -Report IncomeStatement | Select-Object -First 1 } catch { $Script:yahooAuth = $false }

### Yahoo "crumb".  Seems to be used as a validation check for some data items, such as calendars (splits, earnings, etc.)
#############################################################################################################################
$Script:yahooCrumb = (Invoke-WebRequest -Method GET -UseBasicParsing -Uri "https://query1.finance.yahoo.com/v1/test/getcrumb" -WebSession $Script:yahoo -ContentType "text/plain" -Headers @{
    "path"="/v1/test/getcrumb"
    "scheme"="https"
    "accept"="*/*"
    "accept-encoding"="gzip, deflate, br"
    "accept-language"="en-US,en;q=0.9"
    "origin"="https://finance.yahoo.com"
    "referer"="https://finance.yahoo.com/calendar/"
    "sec-ch-ua"="`"Not_A Brand`";v=`"8`", `"Chromium`";v=`"$Script:chromeVer`", `"Microsoft Edge`";v=`"$Script:chromeVer`""
    "sec-ch-ua-mobile"="?0"
    "sec-ch-ua-platform"="`"Windows`""
    "sec-fetch-dest"="empty"
    "sec-fetch-mode"="cors"
    "sec-fetch-site"="same-site"
}).Content


### API Keys, Tokens, URLs, and other access stuff
#############################################################################################################################
$Script:apiFRED = "33acf6fe5fefac3a25b436c5ca0cdc67"
$Script:apiEOD = "64a48bc93a9988.68242263"
$Script:apiFINRA = "MQBiADIANQBkADcANQBjAGYAOABiAGEANABmADIAOQA5AGMAZgA1ADoAewA0ADkAKgBAAGEAYwBqADIAOAAwACMAUQB+ACEA"
# $Script:apiStockAnalysis = "AAAAB3NzaC1yc2EAAAADAQABAAABAQDNK7jARJUOF5HofsvEkZi6T80FW4Shxx1k6tGnyw1bMyrGXOuMg7xx"


$Script:urlFRED = "https://api.stlouisfed.org/fred"
$Script:urlFINRA = "https://api.finra.org"