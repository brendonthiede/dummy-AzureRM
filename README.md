# Dummy AzureRM

The goal here is to get Az and it's aliases to AzureRM behaving in such a manner as to allow a gradual transition to using the Az modules instead of AzureRM, without breaking existing Azure Pipelines.

While this solution "works", it is by no means elegant. In order to make this method work, you need to copy some fake PowerShell modules and modify the Azure PowerShell task that your agents run. Here is the full process:

1. Disable the agents on the server
2. Uninstall AzureRM
    * all instances, personal or global
    * may need to manually delete AzureRM.* folders
3. Install Az module from an admin powershell instance: `Install-Module Az`
4. Copy the `AzureRM` and `AzureRM.profile` folders fromthis repo to `C:\Program Files\WindowsPowerShell\Modules\`
5. Modify the Azure PowerShell task code by running the `Modify-AzurePowerShellTask.ps1` script here from an admin PowerShell instance
6. Restart the agents

## Principles

The fake AzureRM modules allow version 3 of the Azure PowerShell task to run withouthaving errors trying to load AzureRM and AzureRM.Profile.

The Modification to the Azure PowerShell tasks allow both version 3 and version 4 to run with the AzureRM aliases enabled.

The end result is that AzureRM style cmdlet names and Az cmdlet names can be used on either version 3 or version 4 of the Azure PowerShell task.