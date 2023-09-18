$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )

foreach($import in @($Private + $Public))
{
    try
    { . $import.fullname }
    catch
    { Write-Error -Message "Failed to import function $($import.fullname): $_" }
}

Export-ModuleMember -Function $Public.Basename
