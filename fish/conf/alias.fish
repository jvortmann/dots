# vim: set ft=fish

alias l 'ls'

# make grep colorful
alias grep 'grep --color=auto -i'

# set localhost alias
alias here 'localhost'

# set move and copy to be verbose
alias mv 'mv -v'
alias cp 'cp -v'
alias vi 'vim'

if type -pq gvim
  alias vim 'gvim'
end
if type -pq mvim
  alias vim 'mvim'
end
if type -pq nvim
  alias vim 'nvim'
end

# shortcuts
alias v 'vim'
alias n 'nvim'
alias g 'git'
alias t 'tmux'

#bundle aliases
alias b 'bundle'
alias be 'bundle exec'
alias ber 'bundle exec rake'
alias beg 'bundle exec guard'

#rails alias
alias r 'rails'

#rake alias
alias rk 'rake'
alias rkt 'RAILS_ENV=test rake'
alias rks 'rake spec'

# alias to projects folder
alias gp 'cd ~/prj'
alias gc 'cd ~/prj/current'

# alias to start/stop postgres
alias pg_start='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
alias pg_stop='pg_ctl -D /usr/local/var/postgres stop -s -m fast'

# alias for silver searcher
alias ss 'ag'

# brew cask aliases
alias bco 'for c in (brew cask list); brew cask info $c | grep "Not Installed" -B3 | head -n1 ; end'
alias bcu 'for c in (bco | cut -f1 -d:); brew cask install -F $c; end'

# make completion for aliases
make_completion l 'ls'
make_completion vi 'nvim'
make_completion v 'nvim'
make_completion n 'nvim'
make_completion g 'git'
make_completion t 'tmux'
make_completion b 'bundle'
make_completion ss 'ag'
