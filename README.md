# Dotfiles

[![Linux](https://github.com/hoang-himself/dotfiles/actions/workflows/linux.yml/badge.svg)](https://github.com/hoang-himself/dotfiles/actions/workflows/linux.yml)
[![Windows](https://github.com/hoang-himself/dotfiles/actions/workflows/windows.yml/badge.svg)](https://github.com/hoang-himself/dotfiles/actions/workflows/windows.yml)

## Disclaimer

You should not clone this repo and use directly, instead create a fork or use this repo as a template to create a new one.
Review the code and remove things you don't want or need.

Use at your own risk!

## Feedback

Suggestions/improvements are [welcome and encouraged](https://github.com/hoang-himself/dotfiles/issues)!

<!--
## FAQ/Notes to self

### `git commit --gpg-sign` raises `gpg: No secret key` on Windows

Git for Windows comes with its own `gpg`, meaning that it does not use Gpg4win by default.

You can:

- Import your keys from within `git bash`
- Set `gpg.program` to the one used by Gpg4win

This repo requires Gpg4win because it is required to sign commits in remote containers.

### SSH keys are not working properly

A typical SSH certificate setup has a private key and a public key.
The private key **must** have Unix line-endings.

In order to achieve this, it is best to use `dos2unix`.
You can find this package on most Linux distros, or use [Dos2Unix for Windows](https://waterlan.home.xs4all.nl/dos2unix.html).

### Forward SSH ports while connected

[Stack Overflow Question](https://stackoverflow.com/questions/5211561/can-i-do-ssh-port-forwarding-after-ive-already-logged-in-with-ssh)

If you set your escape character with EscapeChar option in ~/.ssh/config or with the -e option, you can.

Assume that the escape character is `~`: `~C-L 8000:localhost:9000`.

### Windows special folders

- [System special folders](https://docs.microsoft.com/en-us/dotnet/api/system.environment.specialfolder)
- `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\`

### ssh_config global settings vs `Host *`

[Unix & Linux Stack Exchange Question](https://unix.stackexchange.com/q/606832)

Settings in the "top" level can’t be overridden, whereas settings in `Host *` will be overridden by any setting defined before that section (in the "top" level, or in a section matching the target host).

The "top" level should be used for settings which shouldn’t be overridden, and the `Host *` section, which should come last, should be used for default settings.
-->
