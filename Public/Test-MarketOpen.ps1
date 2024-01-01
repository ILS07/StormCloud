Function Test-MarketOpen
{ return !((Get-MarketHoliday).Date -contains [System.DateTime]::Today.ToLongDateString()) }