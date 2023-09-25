Function Split-Stock
{
    [CmdletBinding()]
    param
    ( 
        [Parameter(Mandatory)][String]$Symbol,
        [Parameter()][String]$SplitRatio,
        [Parameter()][DateTime]$SplitDate
    )

    $vals = @($SplitRatio -split ":")
    $split = [int]$vals[0]/[int]$vals[1]
    
    
    # Apply to PRICE_HISTORY, SHORT_INTEREST, ??
    # Check on why Yahoo's math doesn't check out on splits. It's close, but not right.
    # On second thought, check if Yahoo's price history is intact post-split and remove-n-replace.
    $split
}