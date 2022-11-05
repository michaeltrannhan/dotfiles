# Easier Navigation: .., ..., ...., ....., and ~
${function:~} = { Set-Location -Path "$HOME" }
# Pwsh won't allow ${function:..} because of an invalid path error, so...
${function:Set-ParentLocation} = { Set-Location -Path '..' }; Set-Alias -Name '..' -Value 'Set-ParentLocation'
${function:...} = { Set-Location -Path '..\..' }
${function:....} = { Set-Location -Path '..\..\..' }
${function:.....} = { Set-Location -Path '..\..\..\..' }
${function:......} = { Set-Location -Path '..\..\..\..\..' }

Set-Alias -Name 'time' -Value 'Measure-Command'
