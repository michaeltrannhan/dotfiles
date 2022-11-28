# We wrap in a local function instead of exporting the variable directly in
# order to avoid interfering with manually-run git commands by the user.
function __git_prompt_git {
  git --no-optional-locks $args
}

# Outputs the name of the current branch
# Usage example: git pull origin $(git_current_branch)
# Using '--quiet' with 'symbolic-ref' will not cause a fatal error (128) if
# it's not a symbolic ref, but in a Git repo.
function git_current_branch {
  git branch --show-current
}

# Outputs the name of the current user
# Usage example: $(git_current_user_name)
function git_current_user_name {
  __git_prompt_git config user.name 2>$null
}

# Outputs the email of the current user
# Usage example: $(git_current_user_email)
function git_current_user_email {
  __git_prompt_git config user.email 2>$null
}

# Output the name of the root directory of the git repository
# Usage example: $(git_repo_name)
function git_repo_name {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectUsageOfRedirectionOperator', '')]
  param()
  if ($repo_path = $(__git_prompt_git rev-parse --show-toplevel 2>$null)) {
    Write-Output -InputObject $repo_path.Split('/')[-1]
  }
}

function current_branch {
  git_current_branch
}

# Pretty log messages
function _git_log_prettily {
  if ($args[0]) {
    git log --pretty=$args[0]
  }
}

# Warn if the current branch is a WIP
function work_in_progress {
  if (git -c log.showSignature=false log -n 1 | Select-String -Pattern '--wip--' -Quiet) { Write-Output -InputObject 'WIP!!' }
}

# Check if main exists and use instead of master
function git_main_branch {
  if (git rev-parse --git-dir 2>&1 | Out-Null) { return }

  Write-Output -InputObject (
    (git rev-parse --abbrev-ref 'origin/HEAD').Split('/')[1]
  )
}

# Check for develop and similarly named branches
function git_develop_branch {
  if (git rev-parse --git-dir 2>&1 | Out-Null) { return }

  ForEach ($branch in @('dev', 'devel', 'development')) {
    if (-not (git show-ref -q --verify "refs/heads/$branch")) {
      Write-Output -InputObject "$branch"
      return
    }
  }
  Write-Output -InputObject 'develop'
}

Set-Alias -Name 'g' -Value 'git'
Remove-Alias -Name 'gc' -Force
Remove-Alias -Name 'gcb' -Force
Remove-Alias -Name 'gcm' -Force
Remove-Alias -Name 'gcs' -Force
Remove-Alias -Name 'gl' -Force
Remove-Alias -Name 'gm' -Force
Remove-Alias -Name 'gp' -Force
Remove-Alias -Name 'gpv' -Force

${function:ga} = { git add $args }
${function:gaa} = { git add --all $args }
${function:gapa} = { git add --patch $args }
${function:gau} = { git add --update $args }
${function:gav} = { git add --verbose $args }
${function:gap} = { git apply $args }
${function:gapt} = { git apply --3way $args }

${function:gb} = { git branch $args }
${function:gba} = { git branch -a $args }
${function:gbd} = { git branch -d $args }
${function:gbda} = { git branch -d @(git branch --no-color --merged | Select-String -NotMatch -Pattern "$(git_main_branch)|$(git_develop_branch)" | ForEach-Object -Process { $_.Line.Trim() }) }
${function:gbD} = { git branch -D $args }
${function:gbl} = { git blame -b -w $args }
${function:gbnm} = { git branch --no-merged $args }
${function:gbr} = { git branch --remote $args }
${function:gbs} = { git bisect $args }
${function:gbsb} = { git bisect bad $args }
${function:gbsg} = { git bisect good $args }
${function:gbsr} = { git bisect reset $args }
${function:gbss} = { git bisect start $args }

${function:gc} = { git commit -v $args }
${function:gc!} = { git commit -v --amend $args }
${function:gcn} = { git commit -v --no-edit $args }
${function:gcn!} = { git commit -v --no-edit --amend $args }
${function:gca} = { git commit -v -a $args }
${function:gca!} = { git commit -v -a --amend $args }
${function:gcan!} = { git commit -v -a --no-edit --amend $args }
${function:gcans!} = { git commit -v -a -s --no-edit --amend $args }
${function:gcam} = { git commit -a -m $args }
${function:gcsm} = { git commit -s -m $args }
${function:gcas} = { git commit -a -s $args }
${function:gcasm} = { git commit -a -s -m $args }
${function:gcb} = { git checkout -b $args }
${function:gcf} = { git config --list $args }

function gccd {
  git clone --recurse-submodules $args
  if (Test-Path -Path $args) {
    Set-Location -Path $args
  }
  else {
    Set-Location -Path $args.Split('/')[-1]
  }
}

${function:gcl} = { git clone --recurse-submodules $args }
${function:gclean} = { git clean -id $args }
${function:gpristine} = { git reset --hard && git clean -dffx }
${function:gcm} = { git checkout $(git_main_branch) $args }
${function:gcd} = { git checkout $(git_develop_branch) $args }
${function:gcmsg} = { git commit -m $args }
${function:gco} = { git checkout $args }
${function:gcor} = { git checkout --recurse-submodules $args }
${function:gcount} = { git shortlog -sn $args }
${function:gcp} = { git cherry-pick $args }
${function:gcpa} = { git cherry-pick --abort }
${function:gcpc} = { git cherry-pick --continue }
${function:gcs} = { git commit -S $args }
${function:gcss} = { git commit -S -s $args }
${function:gcssm} = { git commit -S -s -m $args }

${function:gd} = { git diff $args }
${function:gdca} = { git diff --cached $args }
${function:gdcw} = { git diff --cached --word-diff $args }
${function:gdct} = { git describe --tags $(git rev-list --tags --max-count=1) $args }
${function:gds} = { git diff --staged $args }
${function:gdt} = { git diff-tree --no-commit-id --name-only -r $args }
${function:gdup} = { git diff '@{upstream}' $args }
${function:gdw} = { git diff --word-diff $args }

function gdnolock {
  git diff $args ':(exclude)package-lock.json' ':(exclude)*.lock'
}

function gdv { git diff -w $args | & $env:EDITOR -R - }

${function:gf} = { git fetch $args }
${function:gfa} = { git fetch --all --prune --jobs=10 $args }
${function:gfo} = { git fetch origin $args }

${function:gfg} = { git ls-files | Select-String -Pattern $args }

${function:gg} = { git gui citool $args }
${function:gga} = { git gui citool --amend $args }

function ggf {
  $b = if ($args.count -ne 1) { git_current_branch } else { $args[0] }
  git push --force origin "$b"
}

function ggfl {
  $b = if ($args.count -ne 1) { git_current_branch } else { $args[0] }
  git push --force-with-lease origin "$b"
}

function ggl {
  if (($args.count -ne 0) -and ($args.count -ne 1)) {
    git pull origin $args
  }
  else {
    $b = if ($args.count -eq 0) { git_current_branch } else { $args[0] }
    git pull origin "$b"
  }
}

function ggp {
  if (($args.count -ne 0) -and ($args.count -ne 1)) {
    git push origin $args
  }
  else {
    $b = if ($args.count -eq 0) { git_current_branch } else { $args[0] }
    git push origin "$b"
  }
}

function ggpnp {
  if ($args.count -eq 0) {
    ggl && ggp
  }
  else {
    ggl $args && ggp $args
  }
}

function ggu {
  $b = if ($args.count -ne 1) { git_current_branch } else { $args[0] }
  git pull --rebase origin "$b"
}

${function:ggpur} = { ggu $args }
${function:ggpull} = { git pull origin $(git_current_branch) $args }
${function:ggpush} = { git push origin $(git_current_branch) $args }

${function:ggsup} = { git branch --set-upstream-to="origin/$(git_current_branch)" $args }
${function:gpsup} = { git push --set-upstream origin $(git_current_branch) $args }

${function:ghh} = { git help $args }

${function:gignore} = { git update-index --assume-unchanged $args }
${function:gignored} = { git ls-files -v | Select-String -CaseSensitive -Pattern '^[a-z].*$' }
${function:gsdp} = { git svn dcommit && git push github "$(git_main_branch):svntrunk" }

${function:gk} = { gitk --all --branches $args }
${function:gke} = { gitk --all $(git log -g --pretty=%h) $args }

${function:gl} = { git pull $args }
${function:glg} = { git log --stat $args }
${function:glgp} = { git log --stat -p $args }
${function:glgg} = { git log --graph $args }
${function:glgga} = { git log --graph --decorate --all $args }
${function:glgm} = { git log --graph --max-count=10 $args }
${function:glo} = { git log --oneline --decorate $args }
${function:glol} = { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' $args }
${function:glols} = { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat $args }
${function:glod} = { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' $args }
${function:glods} = { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short $args }
${function:glola} = { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all $args }
${function:glog} = { git log --oneline --decorate --graph $args }
${function:gloga} = { git log --oneline --decorate --graph --all $args }
${function:glp} = { _git_log_prettily $args }

${function:gm} = { git merge $args }
${function:gmom} = { git merge "origin/$(git_main_branch)" $args }
${function:gmtl} = { git mergetool --no-prompt $args }
${function:gmtlvim} = { git mergetool --no-prompt --tool='nvim -d' $args }
${function:gmum} = { git merge "upstream/$(git_main_branch)" $args }
${function:gma} = { git merge --abort }

${function:gp} = { git push $args }
${function:gpd} = { git push --dry-run $args }
${function:gpf} = { git push --force-with-lease $args }
${function:gpf!} = { git push --force $args }
${function:gpoat} = { git push origin --all && git push origin --tags }
${function:gpr} = { git pull --rebase $args }
${function:gpu} = { git push upstream $args }
${function:gpv} = { git push -v $args }

${function:gr} = { git remote $args }
${function:gra} = { git remote add $args }
${function:grb} = { git rebase $args }
${function:grba} = { git rebase --abort }
${function:grbc} = { git rebase --continue }
${function:grbd} = { git rebase $(git_develop_branch) $args }
${function:grbi} = { git rebase -i $args }
${function:grbm} = { git rebase $(git_main_branch) $args }
${function:grbom} = { git rebase "origin/$(git_main_branch)" $args }
${function:grbo} = { git rebase --onto $args }
${function:grbs} = { git rebase --skip }
${function:grev} = { git revert $args }
${function:grh} = { git reset $args }
${function:grhh} = { git reset --hard $args }
${function:groh} = { git reset "origin/$(git_current_branch)" --hard $args }
${function:grm} = { git rm $args }
${function:grmc} = { git rm --cached $args }
${function:grmv} = { git remote rename $args }
${function:grrm} = { git remote remove $args }
${function:grs} = { git restore $args }
${function:grset} = { git remote set-url $args }
${function:grss} = { git restore --source $args }
${function:grst} = { git restore --staged $args }
${function:grt} = { Set-Location $(git rev-parse --show-toplevel) }
${function:gru} = { git reset -- $args }
${function:grup} = { git remote update $args }
${function:grv} = { git remote -v $args }

${function:gsb} = { git status -sb $args }
${function:gsd} = { git svn dcommit $args }
${function:gsh} = { git show $args }
${function:gsi} = { git submodule init $args }
${function:gsps} = { git show --pretty=short --show-signature $args }
${function:gsr} = { git svn rebase $args }
${function:gss} = { git status -s $args }
${function:gst} = { git status $args }

${function:gsta} = { git stash push $args }
${function:gstaa} = { git stash apply $args }
${function:gstc} = { git stash clear $args }
${function:gstd} = { git stash drop $args }
${function:gstl} = { git stash list $args }
${function:gstp} = { git stash pop $args }
${function:gsts} = { git stash show --text $args }
${function:gstu} = { git stash push --include-untracked $args }
${function:gstall} = { git stash --all $args }
${function:gsu} = { git submodule update $args }
${function:gsw} = { git switch $args }
${function:gswc} = { git switch -c $args }
${function:gswm} = { git switch $(git_main_branch) $args }
${function:gswd} = { git switch $(git_develop_branch) $args }

${function:gts} = { git tag -s $args }
${function:gtv} = { git tag | Sort-Object }
${function:gtl} = { git tag --sort=-v:refname -n -l $args }

${function:gunignore} = { git update-index --no-assume-unchanged $args }
${function:gunwip} = { if (git log -n 1 | Select-String -Pattern '--wip--') { git reset '@~' } }
${function:gup} = { git pull --rebase $args }
${function:gupv} = { git pull --rebase -v $args }
${function:gupa} = { git pull --rebase --autostash $args }
${function:gupav} = { git pull --rebase --autostash -v $args }
${function:gupom} = { git pull --rebase origin $(git_main_branch) $args }
${function:gupomi} = { git pull --rebase=interactive origin $(git_main_branch) $args }
${function:glum} = { git pull upstream $(git_main_branch) $args }
${function:gluc} = { git pull upstream $(git_current_branch) $args }

${function:gwch} = { git whatchanged -p --abbrev-commit --pretty=medium $args }
${function:gwip} = { git add -A; git rm $(git ls-files --deleted) 2>&1 | Out-Null; git commit --no-verify --no-gpg-sign -m '--wip-- [skip ci]' }

${function:gwt} = { git worktree $args }
${function:gwta} = { git worktree add $args }
${function:gwtls} = { git worktree list $args }
${function:gwtmv} = { git worktree move $args }
${function:gwtrm} = { git worktree remove $args }

${function:gam} = { git am $args }
${function:gamc} = { git am --continue }
${function:gams} = { git am --skip }
${function:gama} = { git am --abort }
${function:gamscp} = { git am --show-current-patch $args }

function grename {
  if (-not ([bool]$args[0] && [bool]$args[1])) {
    Write-Output -InputObject "Usage: $((Get-PSCallStack).FunctionName[0]) old_branch new_branch"
    return 1
  }

  # Rename branch locally
  git branch -m $args[0] $args[1]
  # Rename branch in origin remote
  if (git push origin :$args[1]) {
    git push --set-upstream origin $args[1]
  }
}
