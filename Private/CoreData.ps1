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

$Script:chromeVer = "116"
$Script:userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/$Script:chromeVer.0.0.0 Safari/537.36"


### Yahoo persistent cookies.  Used for pulling historical income statements, balance sheets, etc.
#############################################################################################################################
$Script:yahoo = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$Script:yahoo.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36 Edg/117.0.2045.31"
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("cmp", "t=1694893830&j=0&u=1YNN", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("gpp", "DBAA", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("gpp_sid", "-1", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("tbla_id", "9f80a4de-0d1a-4b97-b8cb-b3475516aae0-tuctbff8c86", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("gam_id", "y-KAUTtaVE2uJLGViifp79Sam62DDq3Rte~A", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("OTH", "v=2&s=2&d=eyJraWQiOiIwMTY0MGY5MDNhMjRlMWMxZjA5N2ViZGEyZDA5YjE5NmM5ZGUzZWQ5IiwiYWxnIjoiUlMyNTYifQ.eyJjdSI6eyJndWlkIjoiQk9XQ0paTFVXUlpORFY2MlNRWlpBQ1ZIMkUiLCJwZXJzaXN0ZW50Ijp0cnVlLCJzaWQiOiJWZEZ2ZXpib2kwUWYifX0.IEDBZe6Qm0Hn4Vn8OlaM57W1nfN-bUMI1qYo-9t3QGODPV4uR8T6XQLkWA9oxgDiJFN6aznQTB-G4M-3_Qa3dl6Q40IwZh2IzQ_Yzl8AzP-laWFBOQAz4CAXu3L5RDzxCIbXtPHvoSI8NlMakiwKF7eitXjztVE_IATaFO79tjI", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("T", "af=JnRzPTE2OTQ4OTM4NTcmcHM9MTVScnM4OEZESGdOcXJOMXlrQW9CUS0t&d=bnMBeWFob28BZwFCT1dDSlpMVVdSWk5EVjYyU1FaWkFDVkgyRQFhYwFBTVVjWllWTwFhbAFid2hlZWxlckB3aGVlbGVydGVjaGluYy5jb20Bc2MBZGVza3RvcF93ZWIBZnMBTllXZUhpTmxCZ2NoAXp6AWhjZ0JsQkE3RQFhAVFBRQFsYXQBaGNnQmxCAW51ATA-&kt=EAAiVZtArIfvSd4l_hbUB8nnw--~I&ku=FAAYIqud0Lf8_u.55XUOI.ZekbbpOkhWNVMML8p.zzPZnlWEjx2eaH1DA4.KSY8Z8wshTW8zTEMf1aeGemUeuYC0UxbwciEN9SLvrfnzxksuYjBVLAbXOIS3aJvrOOs8VnRlyUYSqwnm99zhoPAeCJJhW0jvql_HCT8Vm3BJgRiC1g-~E", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("F", "d=XoCClfE9vDB8a4MEsBF1TF8NePkAg.L.iSkoDS9QRxTjQ7F8dAgqKdNkt30d0GA-", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("PH", "l=en-US", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("Y", "v=1&n=2ofbjh0keh4m1&l=pvxtxkmdvhspmad48f2du1gbun344m8wcgh1nun0/o&p=02ivvvv00000000&r=19q&intl=us", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("GUCS", "AW_BHQIs", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("GUC", "AQEACAJlB1RlM0IkOwTh&s=AQAAACEJYcnE&g=ZQYHKw", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("A1", "d=AQABBAQHBmUCEItxSrFKci_451atinRw9asFEgEACAJUB2UzZdxS0iMA_eMBAAcIBAcGZXRw9asID_p-etaFzpKSL3u9MGXr9gkBBwoBGQ&S=AQAAAt6Z5jWg7gUuaaBTHhu6u4k", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("A3", "d=AQABBAQHBmUCEItxSrFKci_451atinRw9asFEgEACAJUB2UzZdxS0iMA_eMBAAcIBAcGZXRw9asID_p-etaFzpKSL3u9MGXr9gkBBwoBGQ&S=AQAAAt6Z5jWg7gUuaaBTHhu6u4k", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("A1S", "d=AQABBAQHBmUCEItxSrFKci_451atinRw9asFEgEACAJUB2UzZdxS0iMA_eMBAAcIBAcGZXRw9asID_p-etaFzpKSL3u9MGXr9gkBBwoBGQ&S=AQAAAt6Z5jWg7gUuaaBTHhu6u4k&j=US", "/", ".yahoo.com")))
$Script:yahoo.Cookies.Add((New-Object System.Net.Cookie("PRF", "t%3DMSFT%26newChartbetateaser%3D0%252C1696103469739", "/", ".finance.yahoo.com")))


### API Keys, Tokens, URLs, and other access stuff
#############################################################################################################################
$Script:apiFRED = "33acf6fe5fefac3a25b436c5ca0cdc67"
$Script:apiEOD = "64a48bc93a9988.68242263"
$Script:apiFINRA = "MQBiADIANQBkADcANQBjAGYAOABiAGEANABmADIAOQA5AGMAZgA1ADoAewA0ADkAKgBAAGEAYwBqADIAOAAwACMAUQB+ACEA"
$Script:apiStockAnalysis = "AAAAB3NzaC1yc2EAAAADAQABAAABAQDNK7jARJUOF5HofsvEkZi6T80FW4Shxx1k6tGnyw1bMyrGXOuMg7xx"


$Script:urlFRED = "https://api.stlouisfed.org/fred"
$Script:urlFINRA = "https://api.finra.org"