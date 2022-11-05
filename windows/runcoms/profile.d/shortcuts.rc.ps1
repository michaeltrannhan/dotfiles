[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

# Navigation Shortcuts
# https://docs.microsoft.com/en-us/dotnet/api/system.environment.specialfolder
$desktop = $([Environment]::GetFolderPath('Desktop'))
$documents = $([Environment]::GetFolderPath('MyDocuments'))
# $downloads = $(
#   Get-ItemPropertyValue `
#     -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' `
#     -Name '{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}'
# )

Set-Alias -Name 'la' -Value 'ls'
