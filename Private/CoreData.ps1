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


### Yahoo persistent cookies.  Used for pulling historical income statements, balance sheets, etc.
#############################################################################################################################
$Script:yahoo = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$Script:yahoo.UserAgent = "$Script:userAgent Edg/$Script:chromeVer.0.0.0"
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("tbla_id", "9f80a4de-0d1a-4b97-b8cb-b3475516aae0-tuctbff8c86", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("F", "d=XoCClfE9vDB8a4MEsBF1TF8NePkAg.L.iSkoDS9QRxTjQ7F8dAgqKdNkt30d0GA-", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("PH", "l=en-US", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("Y", "v=1&n=2ofbjh0keh4m1&l=pvxtxkmdvhspmad48f2du1gbun344m8wcgh1nun0/o&p=02ivvvv00000000&r=19q&intl=us", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("ucs", "tr=1696470332000", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("gpp", "DBAA", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("gpp_sid", "-1", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("gam_id", "y-IsFaU2lG2uIjybI4.7p6cYm6pVFv4SurNGzsbJ.sMgtNI0CKwQ---A", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("axids", "gam=y-IsFaU2lG2uIjybI4.7p6cYm6pVFv4SurNGzsbJ.sMgtNI0CKwQ---A&dv360=eS1qWVJEeTVKRTJ1RU9pM0NiTmhCTldsWS5Yd1lxQW03YzNNMHdHMy43NThpWGllQjE1eU9UOTd6SUI5VnIwZmhQMHpfan5B", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("PRF", "t%3DMSFT%252BCCL%252B%255EGSPC%252BEPM%252BCBOE%252BOXLC%252BBF-B%252BBF-A%252BBFB231215C00065000%252BK%252BEFX%252BULTA%252BLHX%252BCB%252BMO%26newChartbetateaser%3D1", "/", ".finance.yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("__gpi", "UID=00000da7dc668670:T=1702144729:RT=1702145655:S=ALNI_MYDNwlRZvKzUDfZ7WlJ4R3xbQ59yA", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("cmp", "t=1702148452&j=0&u=1YNN", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("OTH", "v=2&s=2&d=eyJraWQiOiIwMTY0MGY5MDNhMjRlMWMxZjA5N2ViZGEyZDA5YjE5NmM5ZGUzZWQ5IiwiYWxnIjoiUlMyNTYifQ.eyJjdSI6eyJndWlkIjoiQk9XQ0paTFVXUlpORFY2MlNRWlpBQ1ZIMkUiLCJwZXJzaXN0ZW50Ijp0cnVlLCJzaWQiOiJ0cE5BVVhjeU5LUDgifX0.g_X5oc1QVZL-CFyPryE9hfNij3FVQtSB6VprR97M45AoI8WyYb4yySV90vy2_k5QX2yISzY4x8IBfdT1G8UFaukHt1rLp9bibG_GYp2cOWLP71YS1kFNuJhnv_1wtgrGT8BLHdeh9-eThFBFYASHL1k2VR_PEJAg0f_VGLnG8aQ", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("T", "af=JnRzPTE3MDIxNDg0OTEmcHM9MmdhQVdIY3JKZHgzSW9LMnBpX01VZy0t&d=bnMBeWFob28BZwFCT1dDSlpMVVdSWk5EVjYyU1FaWkFDVkgyRQFhYwFBQ0NHUEl1VAFhbAFid2hlZWxlckB3aGVlbGVydGVjaGluYy5jb20Bc2MBZGVza3RvcF93ZWIBZnMBTllXZUhpTmxCZ2NoAXp6AUxtTGRsQkE3RQFhAVFBRQFsYXQBTG1MZGxCAW51ATA-&kt=EAA8CrNNLriB6tr_4cB3RpKMQ--~I&ku=FAAKj8vg5Kb6Nd1OmHr9WL5sbuKvNg8tQTWukhu7P9JYZwlbid6aYr538ncMpswYIvDd_XrtI9kXOjxsMZeIChRzKBMe4G.TuDD_CQqTzohnIweCI0M6yMMv.T0NprQP6O6HvgOBELdlLtH5bkSx47Jn00dT8xsB25zTo6_MqeqRJA-~E", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("GUCS", "ARk655Iu", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("GUC", "AQEACAJldf1lnkIkOwTh&s=AQAAADrCtc7f&g=ZXS5lQ", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("A1", "d=AQABBAQHBmUCEItxSrFKci_451atinRw9asFEgEACAL9dWWeZdxS0iMA_eMBAAcIBAcGZXRw9asID95pvFB4xwOeLmnQqq8wVQkBBwoB1Q&S=AQAAAgrY3zAkh3ie85xbFRcS55M", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("A3", "d=AQABBAQHBmUCEItxSrFKci_451atinRw9asFEgEACAL9dWWeZdxS0iMA_eMBAAcIBAcGZXRw9asID95pvFB4xwOeLmnQqq8wVQkBBwoB1Q&S=AQAAAgrY3zAkh3ie85xbFRcS55M", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("A1S", "d=AQABBAQHBmUCEItxSrFKci_451atinRw9asFEgEACAL9dWWeZdxS0iMA_eMBAAcIBAcGZXRw9asID95pvFB4xwOeLmnQqq8wVQkBBwoB1Q&S=AQAAAgrY3zAkh3ie85xbFRcS55M", "/", ".yahoo.com")))


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