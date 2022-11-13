[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

$env:POSH_GIT_ENABLED = $true

$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:PAGER = 'less'
$env:VSCODE = 'code-insiders'

$PROFILE_HOME = Split-Path -Parent $Profile
$env:XDG_CONFIG_HOME = "$env:USERPROFILE\.config"
$env:XDG_CACHE_HOME = "$env:USERPROFILE\.cache"
$env:XDG_DATA_HOME = "$env:USERPROFILE\.local\share"
$env:XDG_STATE_HOME = "$env:USERPROFILE\.local\state"
$env:XDG_BIN_HOME = "$env:USERPROFILE\.local\bin"

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables
$ErrorActionPreference = 'Continue'
