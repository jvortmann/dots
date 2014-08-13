function _git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function _git_is_dirty
  echo (command git status -s --ignore-submodules=dirty ^/dev/null)
end

function fish_prompt
  set -l cyan (set_color cyan)
  set -l yellow (set_color yellow)
  set -l red (set_color red)
  set -l blue (set_color blue)
  set -l green (set_color green)
  set -l normal (set_color normal)

  # Print user
  echo -n -s $blue (whoami)@(hostname|cut -d . -f 1) ' ' $normal

  # Print pwd or full path
  set -l cwd $green(basename (prompt_pwd))
  echo -n -s $cwd $normal

  # Show git branch and status
  if [ (_git_branch_name) ]
    set -l git_branch (_git_branch_name)

    if [ (_git_is_dirty) ]
      set git_info $yellow " ($git_branch±)" $normal
    else
      set git_info $green " ($git_branch)" $normal
    end
    echo -n -s $git_info $normal
  end

  # Terminate with a nice prompt char
  echo -e -s $red ' ∴ ' $normal
end
