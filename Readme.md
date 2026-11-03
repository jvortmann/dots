# Dots

The configuration of a macOS machine for terminal-first development: zsh,
tmux, Ghostty, git and a coding agent. The Neovim configuration lives in a
separate repository, `vim-files`.

## Set up a new machine

```sh
git clone git@github.com:jvortmann/dots.git ~/prj/config/dots
cd ~/prj/config/dots
./setup.sh "computer_name" "User Name" "user@email.com"
```

One command does the whole job, in this order:

1. `symlink.sh` links `~/.dots` to this repository, then links the files that
   need no setup of their own.
2. `osx/install-apps.sh` installs Homebrew if it is missing, then everything
   in `osx/Brewfile`. `osx/download-apps.sh` fetches the apps that Homebrew
   does not carry.
3. `osx/configure-osx.sh` sets the computer name, the keyboard, the spaces and
   the shortcuts.
4. `setup_tools.sh` runs the `setup.sh` of each tool folder below.
5. `setup-git-user.sh`, `setup-ssh-key.sh` and `setup-ssh-config.sh` write
   the git identity and an SSH key named after the computer.

## Take one piece

Every script runs alone. To set up one tool, run its own script, such as
`./tmux/setup.sh`. Each one links its folder into `~/.config` or `~`, and does
nothing else, unless the table says so.

| Tool | Folder | What its setup does |
|---|---|---|
| bat | `bat/` | links the config, rebuilds the theme cache |
| ctags | `ctags/` | links the config |
| fd | `fd/` | links the ignore file |
| Ghostty | `ghostty/` | links the config and its themes |
| iex | `iex/` | links `.iex.exs` |
| Karabiner | `karabiner/` | links the key remaps |
| mise | `mise/` | links the global tool versions, as a file and not a folder |
| OrbStack | `orbstack/` | sets its CPU and memory, and links nothing |
| pi | `pi/` | links the whole folder to `~/.config/pi`, because pi writes its state there (auth, sessions, cache, extensions) and `git/ignore` keeps that state out |
| tmux | `tmux/` | links the config, clones the plugin manager (then `prefix + I` in tmux) |
| zsh | `zsh/` | links the shell config, sets zsh as the login shell |

`symlink.sh` covers git, ripgrep, readline, gem, irb, guard and eslint, which
need only a link.

`dev-docs/` and `raycast/` have no script. They hold exported preferences,
which you import by hand in DevDocs and Raycast.

## The coding agent

`zsh/conf/plugins/pi.zsh` points pi at `~/.config/pi` with
`PI_CODING_AGENT_DIR`. The `pi/` folder holds:

| Path | What it holds |
|---|---|
| `AGENTS.md` | the rules every agent session follows |
| `SYSTEM.md` | the system prompt |
| `skills/` | the skills that agents load for a kind of work, such as tdd, git-commit and create-pr |
| `agents/` | five subagents: dev implements one task under TDD, editor writes text that people read and runs `ste-lint` until it passes, review reads a diff and changes nothing, Explore and Plan search and plan and change nothing |
| `prompts/` | three commands: `/goal`, `/review-architecture` and `/watch-pr` |
| `pi-permissions.jsonc` | what an agent may run without asking, and what it may never run |
| `settings.json` | runs `greprip/greprip.sh` before each agent shell command, so `grep` and `find` there use ripgrep and fd and skip ignored files. The terminal keeps the real ones. mise installs greprip |
| `update-impeccable.sh` | updates the impeccable skill from upstream |

## Change it

The files are live, because `~/.dots` points at this checkout. An edit applies
at once for most tools, and at the next shell for zsh. `git/hooks/commit-msg` checks each
commit message. The tests are in `tests/`, in the same layout as the files
they test. Run `bashunit` from the root to run all of them.

This repository is public and shared. Keep secrets and machine-specific values
out of it.
