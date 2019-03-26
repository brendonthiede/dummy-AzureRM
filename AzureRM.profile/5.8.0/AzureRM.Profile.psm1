if (-not (Get-Module Az.Accounts -ErrorAction SilentlyContinue)) {
    Import-Module Az -Global
}
if (-not (Get-Command Connect-AzureRmAccount -ErrorAction SilentlyContinue)) {
    Enable-AzureRmAlias
}