#Requires -PSEdition Core -RunAsAdministrator

function Add-ToPathVariable {
  param(
    [string]$RegistryPath,
    [string]$Path
  )
  $oldPath = (Get-Item -Path "$RegistryPath").GetValue(
    'Path', # the registry-value name
    $null, # the default value to return if no such value exists.
    'DoNotExpandEnvironmentNames' # the option that suppresses expansion
  )

  if ($oldPath -ilike "*$Path*") { return }

  Set-ItemProperty -Path "$RegistryPath" -Name 'Path' -Value "$oldPath;$Path"

  #$tempPath = $Path.Split('%')
  #$pwshPath = '$env:' + -join $tempPath[1..$tempPath.count]
  #$env:Path = "$env:Path;$pwshPath"
}

function Add-ToSystemPath {
  param(
    [string]$Path
  )
  Add-ToPathVariable -RegistryPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Path $Path
}

function Add-ToUserPath {
  param(
    [string]$Path
  )
  Add-ToPathVariable -RegistryPath 'HKCU:\Environment' -Path $Path
}

$ErrorActionPreference = 'SilentlyContinue'

@(
  'config',
  'cache',
  'local'
) | ForEach-Object -Process {
  New-Item -Path "$env:USERPROFILE\.$_" -ItemType Directory -Force
}
@(
  'share',
  'state',
  'bin'
) | ForEach-Object -Process {
  New-Item -Path "$env:USERPROFILE\.local\$_" -ItemType Directory -Force
}

$PROFILE_HOME = Split-Path -Parent $Profile
$env:XDG_CONFIG_HOME = if ("$env:XDG_CONFIG_HOME") { "$env:XDG_CONFIG_HOME" } else { "$env:USERPROFILE\.config" }
$env:XDG_CACHE_HOME = if ("$env:XDG_CACHE_HOME") { "$env:XDG_CACHE_HOME" } else { "$env:USERPROFILE\.cache" }
$env:XDG_DATA_HOME = if ("$env:XDG_DATA_HOME") { "$env:XDG_DATA_HOME" } else { "$env:USERPROFILE\.local\share" }
$env:XDG_STATE_HOME = if ("$env:XDG_STATE_HOME") { "$env:XDG_STATE_HOME" } else { "$env:USERPROFILE\.local\state" }
$env:XDG_BIN_HOME = if ("$env:XDG_BIN_HOME") { "$env:XDG_BIN_HOME" } else { "$env:USERPROFILE\.local\bin" }

New-Item -ItemType Directory -Path "$PROFILE_HOME" -Force
New-Item -ItemType Directory -Path "$PROFILE_HOME\profile.d" -Force

function Install-Base {
  #Add-AppxPackage -Path 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
  #Add-ToUserPath -Path '%LOCALAPPDATA%\Microsoft\WindowsApps'
  Get-PackageProvider | Where-Object -Property Name -EQ 'NuGet' | Install-PackageProvider -Force
  Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
  Update-Module -Force

  @(
    'PowerShellGet',
    'PSReadLine'
  ) | ForEach-Object -Process { Install-Module -Name $_ -Scope CurrentUser -Force }

  winget install --id 'GnuPG.Gpg4win' --override "/C=`"$PWD\configs\gpg4win.ini`" /S"
  @(
    'JohnTaylor.lesskey',
    'JohnTaylor.less',
    'Neovim.Neovim',
    'RedHat.Podman-Desktop'
  ) | ForEach-Object -Process { winget install --id "$_" }
}

function Install-Prompt {
  @(
    'posh-git',
    'Terminal-Icons'
  ) | ForEach-Object -Process { Install-Module -Name $_ -Scope CurrentUser -Force }

  @(
    'Microsoft.PowerShell',
    'Starship.Starship'
  ) | ForEach-Object -Process { winget install --id "$_" }
}

function Set-RunCom {
  [CmdletBinding(SupportsShouldProcess)]
  param()
  # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles
  @(
    @('', ''),
    @('Preview', '_preview')
  ) | ForEach-Object -Process {
    New-Item -ItemType SymbolicLink `
      -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal$($_[0])_8wekyb3d8bbwe\LocalState\settings.json" `
      -Target $(Resolve-Path -LiteralPath ".\configs\wt\settings$($_[1]).json") -Force
  }

  New-Item -ItemType SymbolicLink -Path "$env:XDG_CONFIG_HOME\starship.toml" `
    -Target $(Resolve-Path -LiteralPath '..\shared\runcoms\starship.toml') -Force

  Get-ChildItem -Path '.\runcoms\*' -Include '*.ps1' | ForEach-Object -Process {
    New-Item -ItemType SymbolicLink -Path "$PROFILE_HOME\$($_.Name)" `
      -Target $_.FullName -Force
  }
  Get-ChildItem -Path '.\runcoms\profile.d\*' -Include '*.rc.ps*' | ForEach-Object -Process {
    New-Item -ItemType SymbolicLink -Path "$PROFILE_HOME\profile.d\$($_.Name)" `
      -Target $_.FullName -Force
  }
}

function Install-Pyenv {
  git clone --depth 1 'https://github.com/pyenv-win/pyenv-win.git' "$env:USERPROFILE\.pyenv"

  Set-ItemProperty -Path 'HKCU:\Environment' -Name 'PYENV' `
    -Value '%USERPROFILE%\.pyenv\pyenv-win'
  Set-ItemProperty -Path 'HKCU:\Environment' -Name 'PYENV_ROOT' `
    -Value '%USERPROFILE%\.pyenv\pyenv-win'
  Set-ItemProperty -Path 'HKCU:\Environment' -Name 'PYENV_HOME' `
    -Value '%USERPROFILE%\.pyenv\pyenv-win'

  Add-ToUserPath -Path '%USERPROFILE%\.pyenv\pyenv-win\bin'
  Add-ToUserPath -Path '%USERPROFILE%\.pyenv\pyenv-win\shims'
}

function Set-Pyenv {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    $pythonTarget = '3.11.1'
  )
  $env:PYENV = "$env:USERPROFILE\.pyenv\pyenv-win"
  $env:PYENV_HOME = "$env:PYENV"
  $env:PYENV_ROOT = "$env:PYENV"
  Start-Process -FilePath "$env:PYENV\bin\pyenv" `
    -ArgumentList @('install', $pythonTarget, '-q') -Wait
  Start-Process -FilePath "$env:PYENV\bin\pyenv" `
    -ArgumentList @('global', $pythonTarget) -Wait
  Start-Process -FilePath "$env:PYENV\versions\$pythonTarget\python.exe" `
    -ArgumentList @('-m', 'pip', 'install', '--upgrade', 'pip', 'setuptools', 'wheel') -Wait
}

function Install-NVM {
  winget install --id 'CoreyButler.NVMforWindows'
}

function Set-NVM {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
  param()
  $env:NVM_HOME = "$env:APPDATA\nvm"
  $env:NVM_SYMLINK = "$env:ProgramFiles\nodejs"
  Start-Process -FilePath "$env:NVM_HOME\nvm.exe" `
    -ArgumentList @('install', 'latest') -Wait
  Start-Process -FilePath "$env:NVM_HOME\nvm.exe" `
    -ArgumentList @('use', 'latest') -Wait
  Start-Process -FilePath "$env:NVM_HOME\nvm.exe" `
    -ArgumentList 'on' -Wait
}

function Install-OpenSSH {
  Add-WindowsCapability -Online -Name OpenSSH.Client
  Get-Service -Name 'ssh-agent' | Set-Service -StartupType Automatic -PassThru | Start-Service

  #Add-WindowsCapability -Online -Name OpenSSH.Server
  #Get-Service -Name 'sshd' | Set-Service -StartupType Automatic -PassThru | Start-Service

  #Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' `
  #| Remove-NetFirewallRule
  #New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' `
  #  -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

function Set-OpenSSH {
  [CmdletBinding(SupportsShouldProcess)]
  param()
  New-Item -ItemType Directory -Path "$env:ProgramData\ssh\sshd_config.d" -Force
  New-Item -ItemType Directory -Path "$env:ProgramData\ssh\keys\$env:USERNAME" -Force

  @(
    'config.d',
    'id.d'
  ) | ForEach-Object -Process {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh\$_" -Force
  }

  New-Item -ItemType SymbolicLink `
    -Path "$env:ProgramData\ssh\sshd_config" `
    -Target $(Resolve-Path -LiteralPath '.\configs\sshd_config') -Force

  Get-ChildItem -Path '..\shared\configs\sshd_config.d' | ForEach-Object -Process {
    New-Item -ItemType SymbolicLink `
      -Path "$env:ProgramData\ssh\sshd_config.d\$($_.Name)" `
      -Target $_.FullName -Force
  }
  Get-ChildItem -Path '..\shared\configs\ssh_config.d' | ForEach-Object -Process {
    New-Item -ItemType SymbolicLink `
      -Path "$env:ProgramData\ssh\ssh_config.d\$($_.Name)" `
      -Target $_.FullName -Force
  }

  New-Item -ItemType SymbolicLink `
    -Path "$env:USERPROFILE\.ssh\config" `
    -Target $(Resolve-Path -LiteralPath '.\configs\ssh_config') -Force

  New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -PropertyType String `
    -Name 'DefaultShell' -Value 'C:\Program Files\PowerShell\7\pwsh.exe' -Force
}

function Install-WSL {
  # Get-WindowsOptionalFeature -Online
  Enable-WindowsOptionalFeature -Online -All -NoRestart `
    -FeatureName @('VirtualMachinePlatform', 'HypervisorPlatform', 'Microsoft-Windows-Subsystem-Linux') `
  | Out-Null
}

function Set-WSL {
  [CmdletBinding(SupportsShouldProcess)]
  param()
  New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.wslconfig" `
    -Target $(Resolve-Path -LiteralPath '.\configs\wslconfig') -Force
}

function Set-Git {
  [CmdletBinding(SupportsShouldProcess)]
  param()
  New-Item -ItemType SymbolicLink `
    -Path "$env:XDG_CONFIG_HOME\git" `
    -Target $(Resolve-Path -LiteralPath '..\shared\configs\git') -Force

  Get-ChildItem -Path '.\configs\git\bash' | ForEach-Object -Process {
    New-Item -ItemType SymbolicLink `
      -Path "$env:USERPROFILE\.$($_.Name)" `
      -Target $_.FullName -Force
  }
}

function Set-Neovim {
  [CmdletBinding(SupportsShouldProcess)]
  param()
  git clone --depth 1 'https://github.com/wbthomason/packer.nvim' `
    "$env:XDG_DATA_HOME\nvim-data\site\pack\packer\start\packer.nvim"
  New-Item -ItemType SymbolicLink `
    -Path "$env:XDG_CONFIG_HOME\nvim" `
    -Target $(Resolve-Path -LiteralPath '..\shared\runcoms\neovim') -Force
}

function main {
  Install-Base
  Install-OpenSSH
  Install-Prompt
  Install-Pyenv
  Install-WSL

  Set-RunCom
  Set-Pyenv 3.11.1
  Set-OpenSSH
  Set-WSL
  Set-Git
  Set-Neovim
}

$args | ForEach-Object -Process {
  switch ($_) {
    #'-i' { main }
    #'--install' { main }
    { $_ -in @('-i', '--install') } { main }
    default { Write-Output -InputObject "Unrecognized option `"$_`"" }
  }
}

$ErrorActionPreference = 'Continue'
