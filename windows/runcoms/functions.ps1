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

function Add-ToPathVariable {
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

function Add-ToSystemPath {
  param(
    [string]$Path
  )
  Add-ToPathVariable -HKEY_Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Path $Path
}

function Add-ToUserPath {
  param(
    [string]$Path
  )
  Add-ToPathVariable -HKEY_Path 'HKCU:\Environment' -Path $Path
}
