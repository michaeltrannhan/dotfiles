[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

$env:POSH_GIT_ENABLED = $true

$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:PAGER = 'less'
$env:VSCODE = 'code-insiders'

$PROFILE_HOME = Split-Path -Parent $Profile
$env:XDG_CONFIG_HOME = if ("$env:XDG_CONFIG_HOME") { "$env:XDG_CONFIG_HOME" } else { "$env:USERPROFILE\.config" }
$env:XDG_CACHE_HOME = if ("$env:XDG_CACHE_HOME") { "$env:XDG_CACHE_HOME" } else { "$env:USERPROFILE\.cache" }
$env:XDG_DATA_HOME = if ("$env:XDG_DATA_HOME") { "$env:XDG_DATA_HOME" } else { "$env:USERPROFILE\.local\share" }
$env:XDG_STATE_HOME = if ("$env:XDG_STATE_HOME") { "$env:XDG_STATE_HOME" } else { "$env:USERPROFILE\.local\state" }
$env:XDG_BIN_HOME = if ("$env:XDG_BIN_HOME") { "$env:XDG_BIN_HOME" } else { "$env:USERPROFILE\.local\bin" }

$MaximumHistoryCount = 1024
Set-PSReadLineOption -MaximumHistoryCount $MaximumHistoryCount
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -ShowToolTips

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables
$ErrorActionPreference = 'Continue'
