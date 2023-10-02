<#
.SYNOPSIS
Creates a random set of user data to circumvent the SEC's block of automated tools.

.EXAMPLE
New-SECUserData

.NOTES
No inputs.  
#>
Function New-SECUserData
{
    [CmdletBinding()]
    param ( )

    BEGIN
    {
        $firstName = @(
            "Adam"
            "Amber"
            "Anne"
            "Anthony"
            "Ben"
            "Benjamin"
            "Bill"
            "Blake"
            "Charlie"
            "Chris"
            "Donald"
            "Eric"
            "Eugene"
            "Francis"
            "Jamal"
            "John"
            "Johnny"
            "Marcus"
            "Maria"
            "Mark"
            "Oscar"
            "Paul"
            "Paula"
            "Pedro"
            "Peter"
            "Rachel"
            "Raul"
            "Richard"
            "Samuel"
            "Sara"
            "Sarah"
            "Simon"
            "Thomas"
            "Timothy"
            "Zach"
        )

        $lastName = @(
            "Amos"
            "Anderson"
            "Braun"
            "Brown"
            "Carter"
            "Clark"
            "Davis"
            "Elliot"
            "Flint"
            "Garcia"
            "Green"
            "Heart"
            "Hernandez"
            "James"
            "Jones"
            "Lee"
            "Marshal"
            "Miller"
            "Paulson"
            "Ramirez"
            "Roberts"
            "Score"
            "Scott"
            "Small"
            "Taylor"
            "Thomason"
            "Thompson"
            "Trey"
            "Wagner"
            "Williamson"
            "Wilson"
            "Yawney"
        )

        $emailDomain = @(
            "aol.com"
            "att.net"
            "centurylink.net"
            "charter.net"
            "comcast.net"
            "cox.net"
            "gmail.com"
            "icloud.com"
            "mailchimp.com"
            "outlook.com"
            "spectrum.com"
            "verizon.net"
            "yahoo.com"
        )
    }

    PROCESS
    {
        $first = $firstName | Get-Random
        $last = $lastName | Get-Random
        $domain = $emailDomain | Get-Random

        $email = switch (Get-Random -Minimum 0 -Maximum 3)
        {
            0 { "$($first.ToLower())$(@(".","_") | Get-Random)$($last.ToLower())$(Get-Random -Minimum 191 -Maximum 8554)@$domain" }
            1 { "$($first[0])$(@(".","_") | Get-Random)$($last[0..$(Get-Random -Minimum 1 -Maximum( $last.Length - 1))] -join '')$(Get-Random -Minimum 191 -Maximum 8554)@$domain" }
            2 { "$($last.ToLower())$(Get-Random -Minimum 191 -Maximum 8554)_$($first.ToLower())@$domain" }
        }

        # return @{
        #     "User-Agent" = "$first $last ($email)"
        #     "Accept-Encoding" = "gzip, deflate"
        #     "Host" = "www.sec.gov"
        # }

        return @{
            "User-Agent" = "Mark Strong (mk.strongman332@gmail.com)"
            "Accept-Encoding" = "gzip, deflate"
            "Host" = "www.sec.gov"
        }
    }
}