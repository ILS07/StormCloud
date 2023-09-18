<#
.DESCRIPTION
Retreives the Category tree for a given Series ID.

.PARAMETER SeriesID
Specifies a Series ID for which to pull the Category tree.

.EXAMPLE
Get-FREDCategoryTree -SeriesID UNRATE

.NOTES
Currently only works for Series that belong to a singe Category tree.
Series beloning to multiple trees will result in an error.
I really don't want to mess with looping here, so I'll let it ride for now.
#>
Function Get-FREDCategoryTree
{
    [CmdletBinding()]
    param ( [Parameter(Mandatory)][String]$SeriesID )

    BEGIN
    {
        $ProgressPreference = "SilentlyContinue"
        [System.Collections.ArrayList]$categories = @()
    }

    PROCESS
    {
        $node = `
            try { (Invoke-RestMethod -Method GET -Uri "$Script:urlFRED/series/categories?series_id=$SeriesID&api_key=$Script:apiFRED&file_type=json").categories }
            catch { $_.Exception.Message }

        if ($node -like "*(400) Bad Request*")
        { return $null }

        [void]$categories.Add([PSCUstomObject]@{"ParentID" = $node.parent_id; "ID" = $node.id; "Level" = $null; "Category" = $node.name})

        while ($node.parent_id -ne 0)
        {
            $tango = (Invoke-RestMethod -Method GET -Uri "$Script:urlFRED/category?category_id=$($node.parent_id)&api_key=$Script:apiFRED&file_type=json").categories
            [void]$categories.Add([PSCustomObject]@{"ParentID" = $tango.parent_id; "ID" = $tango.id; "Level" = $null; "Category" = $tango.name})
            $node = $tango
        }

        $categories.Reverse()
        for ($a = 1; $a -le $categories.Count; $a++) { $categories[$a - 1].Level = $a }

        return $categories
    }
}