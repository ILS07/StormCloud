<#
.SYNOPSIS
Gets the dates on which the U.S. stock markets are closed in observance of holidays for a given year.

.DESCRIPTION
This started as a technical exercise...at some point someone asks "Are the markets closed for <insert day>?"
So, I decided to write a function to answer that question.  Returns a set of holidays for which the market is
closed.  If a holiday falls on a weekend, it will give the date on which markets observe the holiday.

.PARAMETER Year
Specifies the year for which to determine market holidays.  Uses the current year if none specified.

.EXAMPLE
Get-MarketHoliday

.EXAMPLE
Get-MarketHoliday -Year 2029

#>
Function Get-MarketHoliday ([int]$Year = [System.Datetime]::Today.Year)
{
    [System.Collections.ArrayList]$holidayList = @()
    
    ### Handles all floating holidays.
    Function Get-FloatingHoliday ([string]$ID)
    {
        switch ($ID)
        {
            "MLK2" { $date = [System.DateTime]("01/15/$Year"); break }
            "Washington" { $date = [System.DateTime]("02/15/$Year"); break }
            "Memorial" { $date = [System.DateTime]("05/25/$Year"); break }
            "Labor" { $date = [System.DateTime]("09/01/$Year"); break }
            "Columbus" { $date = [System.DateTime]("10/08/$Year"); break }
            "Thanks" { $date = [System.DateTime]("11/22/$Year"); break }
        }
        
        $day = "Monday"
        if ($ID -eq "Thanks") { $day = "Thursday"}
        while ($date.DayOfWeek -ne $day)
        { $date = $date.AddDays(1) }
        return [DateTime]$date
    }

    ### Derived from "a New York correspondent's" anonymous 1876 submission to the 'Nature' journal for
    ### determining Gregorian Easter, and thus, Good Friday.  Includes 1961 updates from 'New Scientist'
    ### publication and further consolidation to reduce code length.
    Function Get-GoodFriday
    {
        $a = $Year % 19
        $b = [Math]::Floor($Year / 100)
        $c = (19 * $a + $b - ([Math]::Floor($b / 4)) - ([Math]::Floor(((8 * $b) + 13) / 25)) + 15) % 30
        $d = (32 + 2 * ($b % 4) + 2 * ([Math]::Floor(($Year % 100) / 4)) - $c - (($Year % 100) % 4)) % 7
        $e = [Math]::Floor(($a + 11 * $c + 19 * $d) / 433)
        $f = [Math]::Floor(($c + $d - 7 * $e + 90) / 25)
        return (Get-Date -Year $Year -Month $f -Day ((($c + $d - 7 * $e + 33 * $f + 19) % 32))).Date.AddDays(-2)
    }

    [void]$holidayList.Add([PSCustomObject]@{ "Holiday" = "New Year's Day"; "Date" = [DateTime]"01/01/$Year" })
    [void]$holidayList.Add([PSCustomObject]@{ "Holiday" = "MLK Jr.'s Birthday"; "Date" = Get-FloatingHoliday "MLK2" })
    [void]$holidayList.Add([PSCustomObject]@{ "Holiday" = "Presidents' Day"; "Date" = Get-FloatingHoliday "Washington" })
    [void]$holidayList.Add([PSCustomObject]@{ "Holiday" = "Good Friday"; "Date" = Get-GoodFriday })
    [void]$holidayList.Add([PSCustomObject]@{ "Holiday" = "Memorial Day"; "Date" = Get-FloatingHoliday "Memorial" })
    [void]$holidayList.Add([PSCustomObject]@{ "Holiday" = "Juneteenth"; "Date" = [DateTime]"06/19/$Year" })
    [void]$holidayList.Add([PSCustomObject]@{ "Holiday" = "Independence Day"; "Date" = [DateTime]"07/04/$Year" })
    [void]$holidayList.Add([PSCustomObject]@{ "Holiday" = "Labor Day"; "Date" = Get-FloatingHoliday "Labor" })
    [void]$holidayList.Add([PSCustomObject]@{ "Holiday" = "Thanksgiving Day"; "Date" = Get-FloatingHoliday "Thanks" })
    [void]$holidayList.Add([PSCustomObject]@{ "Holiday" = "Christmas Day"; "Date" = [DateTime]"12/25/$Year" })

    $holidayList | Add-Member -MemberType NoteProperty 'Observed Date' -Value ""

    foreach ($item in $holidayList)
    {
        ### Displays the Observed Date column only if one or more holidays for the given year fall on a weekend.
        if ((($item.Date).DayOfWeek -eq "Saturday") -OR (($item.Date).DayOfWeek -eq "Sunday"))
        {
            $item.'Observed Date' = $item.Date
            if ($item.'Observed Date'.DayOfWeek -eq "Saturday") { $item.'Observed Date' = ($item.'Observed Date').AddDays(-1) }
            if ($item.'Observed Date'.DayOfWeek -eq "Sunday") { $item.'Observed Date' = ($item.'Observed Date').AddDays(1) }
            $item.'Observed Date' = ($item.'Observed Date').ToLongDateString()
        }
        $item.Date = ($item.Date).ToLongDateString()
    }

    foreach ($x in $holidayList)
    {
        if ($x.'Observed Date' -ne "")
        {  return $holidayList; return }
    }
    return ($holidayList | Select-Object Holiday,Date)
}