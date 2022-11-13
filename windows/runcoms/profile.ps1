Import-Module -Name 'posh-git'
Import-Module -Name 'Terminal-Icons'

Invoke-Command -ScriptBlock $([ScriptBlock]::Create(
    $(starship init powershell)
  ))

$MaximumHistoryCount = 1024
Set-PSReadLineOption -MaximumHistoryCount $MaximumHistoryCount
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -ShowToolTips

function Invoke-Starship-PreCommand {
  $loc = $($executionContext.SessionState.Path.CurrentLocation);
  $prompt = "$([char]27)]9;12$([char]7)"
  if ($loc.Provider.Name -eq 'FileSystem') {
    $prompt += "$([char]27)]9;9;`"$($loc.Path)`"$([char]7)"
  }
  $host.ui.Write($prompt)
}

Push-Location (Split-Path -Parent $Profile)

@(
  'exports',
  'functions',
  'aliases',
  'bindings',
  'completions'
) | Where-Object { Test-Path "$_.ps1" } `
| ForEach-Object -Process { . ".\$_.ps1" }

Get-ChildItem -Path '.\profile.d\*' -Include '*.rc.psm1' -Exclude '.*' `
| ForEach-Object -Process { Import-Module -Name "$_" }

Get-ChildItem -Path '.\profile.d\*' -Include '*.rc.ps1' -Exclude '.*' `
| ForEach-Object -Process { . "$_" }

Pop-Location
