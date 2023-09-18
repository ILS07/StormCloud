Function Add-SECFilingEntry
{
    [CmdletBinding()]
    param
    (
        [Parameter()][DateTime]$StartDate,
        [Parameter()][DateTime]$EndDate = [DateTime]::Today
    )

    PROCESS
    {
        $database = @{Database = "BULKDATA"}

        foreach ($x in (Get-SECFilingIndex -StartDate ([DateTime]((Invoke-Sqlcmd @database `
            -Query "SELECT MAX(DateFiled) FROM [dbo].[SEC_FILING_INDEX]").Column1)).AddDays(1)))
        {
            Invoke-Sqlcmd @database -Query  ("EXEC [dbo].[Add_SEC_Filing]
            @dateFiled = '$($x.DateFiled)',
            @cik = '$($x.CIK.PadLeft(10,'0'))',
            @formType = '$($x.FormType.Trim())',
            @fileName = '$($x.FileName)'")
        }

        # switch ($Database)
        # {
        #     "BULKDATA"
        #     {
        #         foreach ($x in (Get-SECFilingIndex -StartDate ([DateTime]((Invoke-Sqlcmd -Database $Database `
        #         -Query "SELECT MAX(DateFiled) FROM [dbo].[SEC_FILING_INDEX]").Column1)).AddDays(1)))
        #         {
        #             Invoke-Sqlcmd -Database $Database -Query  ("EXEC [dbo].[Add_SEC_Filing]
        #             @dateFiled = '$($x.DateFiled)',
        #             @cik = '$($x.CIK.PadLeft(10,'0'))',
        #             @formType = '$($x.FormType.Trim())',
        #             @fileName = '$($x.FileName)'")
        #         }
        #     }

        #     "FINDATA"
        #     {
                
        #     }
        # }
    }
}