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

if type -p gvim > /dev/null
  alias vim 'gvim'
end
if type -p mvim > /dev/null
  alias vim 'mvim'
end
if type -p hub > /dev/null
  alias git 'hub'
end

# shortcuts
alias v 'vim'
alias g 'git'

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

#rake db:migrate and db:seed alias
alias md 'rake db:migrate'
alias mt 'RAILS_ENV=test rake db:migrate'
alias m 'md; mt'
alias s 'rake db:seed'

# alias to projects folder
alias gp 'cd ~/prj'
alias gc 'cd ~/prj/current'

# alias to start/stop postgres
alias pg_start='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
alias pg_stop='pg_ctl -D /usr/local/var/postgres stop -s -m fast'

# alias for silver searcher
alias ss 'ag'

# make completion for aliases
make_completion l 'ls'
make_completion vi 'vim'
make_completion v 'vim'
make_completion g 'git'
make_completion b 'bundle'
make_completion ss 'ag'
