#!/usr/bin/env bash

function install_base {
  sudo dnf install -y dnf-plugins-core util-linux-user
  sudo dnf upgrade -y
  sudo dnf install -y git git-lfs less neovim make curl wget rsync \
    openssl acl gnupg dos2unix crontabs ShellCheck \
    buildah podman skopeo openssh-clients #openssh-server
  sudo dnf autoremove -y
}

function install_prompt {
  mkdir -p "$XDG_CONFIG_HOME/zsh"
  export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

  sudo dnf install -y zsh

  # Use heredoc to automatically press enter on confirmation
  sudo lchsh "$USER" <<EOF
$(command -v zsh)
EOF
  curl -SL https://starship.rs/install.sh | sudo sh -s -- -f
}

function install_pyenv {
  sudo dnf install -y make gcc zlib-devel bzip2 bzip2-devel \
    readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel

  curl -SL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
}
