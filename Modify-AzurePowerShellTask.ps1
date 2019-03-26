#Requires -Version 5
#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    # The base directory where your agents are installed
    [string]
    $AgentHomeDirectory = "D:\vsts-agents",

    [string]
    $HeaderTemplateFile = "$PSScriptRoot\AzurePowerShell-header.txt"
)

function GetAzurePowerShellDirectory($ParentDirectory, $MaxDepth=4) {
    $tasksSubDirectoryPattern = "*\_work\_tasks\AzurePowerShell_*"
    Write-Verbose "Looking for $tasksSubDirectoryPattern under $ParentDirectory with a max depth of $MaxDepth"
    $tasksSubDirectory = (Get-ChildItem -Depth $MaxDepth $ParentDirectory -ErrorAction SilentlyContinue| Where-Object { $_.FullName -like "$tasksSubDirectoryPattern" })
    if ($tasksSubDirectory) {
        return [string]"$($tasksSubDirectory[0].FullName.Trim())"
    } else {
        return $false
    }
}

function AddHeaderContent([string]$PluginDirectory, [string[]]$HeaderContent) {
    Write-Verbose "(Get-ChildItem $PluginDirectory -Recurse | Where-Object { `$_.Name -eq `"AzurePowerShell.ps1`" -or `$_.Name -eq `"InitializeAzureRMFunctions.ps1`" })"
    foreach ($pluginFile in (Get-ChildItem $PluginDirectory -Recurse | Where-Object { $_.Name -eq "AzurePowerShell.ps1" -or $_.Name -eq "InitializeAzureRMFunctions.ps1" })) {
        $fileContent = (Get-Content $pluginFile.FullName)
        if (($fileContent -join "`n") -notlike "*Enable-AzureRmAlias*") {
            Write-Verbose "Setting header content for $($pluginFile.FullName)"
            ($HeaderContent -join "`n") + "`n`n" + ($fileContent -join "`n") | Set-Content $pluginFile.FullName
        } else {
            Write-Verbose "Header content is already set for $($pluginFile.FullName)"
        }
    }
}

$foundTaskDirectory = $false
$headerTemplateContent = Get-Content $HeaderTemplateFile
foreach ($directory in (Get-ChildItem $AgentHomeDirectory)) {
    $taskDirectory = GetAzurePowerShellDirectory $directory.FullName
    if ($taskDirectory) {
        $foundTaskDirectory = $true
        Write-Verbose "Using task directory $taskDirectory"
        AddHeaderContent $taskDirectory $headerTemplateContent
    }
}
if (-not $foundTaskDirectory) {
    throw "Could not find AzurePowerShell task folder"
}