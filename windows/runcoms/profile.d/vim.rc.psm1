if ("$env:EDITOR" -and -not (Get-Command -Name "$env:EDITOR" -ErrorAction SilentlyContinue)) {
  Write-Output -InputObject "'$env:EDITOR' flavour of Vim not detected."
  Remove-Item -Path 'Env:\EDITOR'
}

if (-not "$env:EDITOR") {
  $ErrorActionPreference = 'SilentlyContinue'
  @(
    'vim',
    'nvim',
    'nvim-qt'
  ) | ForEach-Object -Process {
    if (Get-Command -Name "$_") {
      $env:EDITOR = "$_"
      break
    }
  }
}

if (-not "$env:EDITOR") {
  return
}

Set-Alias -Name 'vim' -Value "$env:EDITOR"
