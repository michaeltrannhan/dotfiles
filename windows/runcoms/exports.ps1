[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

$env:POSH_GIT_ENABLED = $true
$env:VSCODE = 'code-insiders'

$MaximumHistoryCount = 1024
Set-PSReadLineOption -MaximumHistoryCount $MaximumHistoryCount
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -ShowToolTips

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables
$ErrorActionPreference = 'Continue'
