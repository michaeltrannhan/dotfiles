function sudo() {
  if ($args.count -eq 0) {
    Start-Process -FilePath 'pwsh' -Verb 'RunAs'
  }
  elseif ($args.count -eq 1) {
    Start-Process -FilePath $args[0] -Verb 'RunAs'
  }
  else {
    Start-Process -FilePath $args[0] -Verb 'RunAs' -ArgumentList $args[1..$args.count]
  }
}

function which($name) {
  Get-Command -Name $name -ErrorAction SilentlyContinue `
  | Select-Object -ExpandProperty Definition -ErrorAction SilentlyContinue
}

function touch($file) { '' | Out-File -FilePath $file -Encoding ASCII }

function mkcd($path) { New-Item -ItemType Directory -Path $path && Set-Location -Path $path }

function ssh-hostgen {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
  param()
  # Urban myth
  # Throw is used to terminate an inner block of code and return to the calling block
  if ($args.Length -ne 5) {
    Write-Output -InputObject 'ssh-hostgen <algorithm> <host> <hostname> <port> <user>'
    Write-Output -InputObject ''
    Write-Output -InputObject '    algorithm: ed25519, ecdsa, dsa, rsa'
    Write-Output -InputObject '    host:      alias that you use to access this host'
    Write-Output -InputObject '    hostname:  hostname of the host'
    Write-Output -InputObject '    port:      port of the host, usually 22'
    Write-Output -InputObject '    user:      user to login to the host'
    return
  }

  $keygen_param = @()
  switch ($args[0]) {
    'ed25519' { $keygen_param += @('-t', 'ed25519') }
    'ecdsa' { $keygen_param += @('-t', 'ecdsa', '-b', '521') }
    'dsa' { $keygen_param += @('-t', 'dsa') }
    'rsa' { $keygen_param += @('-t', 'rsa', '-b', '4096') }
    default {
      throw [System.ArgumentException] 'algorithm must be one of ed25519, ecdsa, dsa, rsa'
    }
  }
  $h = $args[1]
  $hostname = $args[2]
  $p = if ($args[3] -is [int]) {
    $args[3]
  }
  else {
    throw [System.ArgumentException] 'invalid port'
  }
  $u = $args[4]
  $keygen_param += @('-f', "$HOME/.ssh/id.d/$($args[0])_$h", '-C', "$u@$hostname")

  ssh-keygen @keygen_param

  Add-Content -Path "$HOME/.ssh/config.d/$hostname.conf" -Value @"
Host $h
  HostName $hostname
  Port $p
  User $u
  IdentityFile ~/.ssh/id.d/$($args[0])_$h
  IdentitiesOnly yes
  #AddKeysToAgent yes
  #ForwardAgent yes

"@

  Get-Acl -Path "$HOME/.ssh/id.d/$($args[0])_$h" `
  | Set-Acl -Path "$HOME/.ssh/config.d/$hostname.conf"
}

function Set-Formatting {
  [CmdletBinding(SupportsShouldProcess)]
  param()
  $editorconfig = @'
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.{bat,cmd}]
end_of_line = crlf

[*.json]
insert_final_newline = false

[*.py]
indent_size = 4

'@

  if (Test-Path -Path '.editorconfig') {
    Write-Output -InputObject $editorconfig
  }
  else {
    Set-Content -Path '.editorconfig' -Value $editorconfig
  }
}

function New-TemporaryFolder {
  [CmdletBinding(SupportsShouldProcess)]
  param()
  $TMPDIR = "$($env:TMP)\tmp$([Convert]::ToString((Get-Random 65535),16).padleft(4,'0')).tmp"
  New-Item -ItemType Directory -Path $TMPDIR
  Push-Location -Path $TMPDIR
}

function Remove-TemporaryFolder {
  [CmdletBinding(SupportsShouldProcess)]
  param()
  $TMPDIR = Get-Location
  Pop-Location
  Remove-Item -Path $TMPDIR -Recurse -Force
}

function Add-ToEnvironmentVariable {
  param(
    [string]$HKEY_Path,
    [string]$Path
  )
  $oldPath = (Get-Item -Path "$HKEY_Path").GetValue(
    'Path', # the registry-value name
    $null, # the default value to return if no such value exists.
    'DoNotExpandEnvironmentNames' # the option that suppresses expansion
  )

  if ($oldPath -ilike "*$Path*") { return }

  Set-ItemProperty -Path "$HKEY_Path" -Name 'Path' `
    -Value "$oldPath;$Path"

  #$tempPath = $Path.Split('%')
  #$pwshPath = '$env:' + -join $tempPath[1..$tempPath.count]
  #$env:Path = "$env:Path;$pwshPath"
}

function Add-ToSystemEnvironment {
  param(
    [string]$Path
  )
  Add-ToEnvironmentVariable -HKEY_Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Path $Path
}

function Add-ToUserEnvironment {
  param(
    [string]$Path
  )
  Add-ToEnvironmentVariable -HKEY_Path 'HKCU:\Environment' -Path $Path
}

function Clear-GlobalHistory {
  Clear-History
  Set-Content -Path $($(Get-PSReadLineOption).'HistorySavePath') -Value ''
  Set-Content -Path "$env:USERPROFILE\.bash_history" -Value ''
}
