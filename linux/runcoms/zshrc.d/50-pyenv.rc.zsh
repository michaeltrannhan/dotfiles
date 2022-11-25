alias vx='deactivate'

function va {
  local venv_path=${1:-'.venv'}
  # [[ -n "$*" ]] && venv_path="${*: -1:1}" || venv_path=".venv"
  # [[ -n "$*" ]] && venv_path="$1" || venv_path=".venv"

  if [[ -d "$venv_path" ]]; then
    . ./"$venv_path"/bin/activate
  else
    python -m venv --upgrade-deps "$venv_path"
    . ./"$venv_path"/bin/activate
    # --upgrade-deps already includes pip and setuptools
    "$venv_path/bin/pip" install wheel

    requirements_file='requirements.txt'
    if [[ -f "$requirements_file" ]]; then
      "$venv_path/bin/pip" install -r "$requirements_file"
    else
      touch "$requirements_file"
    fi
  fi
}
