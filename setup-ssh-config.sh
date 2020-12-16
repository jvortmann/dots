if [ $# -ne 1 ]
then
  echo 'Usage: ./setup-ssh-config.sh "Computer Name"'
  exit 1
fi

computer_name="$1"

echo; echo ">> Setting ssh config"
cat > "$HOME/.ssh/config" <<EOF
# vim: ft=sshconfig

# If you have customizations, put them in ~/.ssh/config.d/
Include config.d/*
EOF

echo; echo ">> Setting ssh '$computer_name' config file"
cat > "$HOME/.ssh/config.d/$computer_name" <<EOF
# vim: ft=sshconfig

Host *
  ServerAliveInterval 120

Host heroku
  HostName heroku.com
  User git
  IdentityFile ~/.ssh/$computer_name
  IdentitiesOnly yes

Host github
  HostName github.com
  User git
  IdentityFile ~/.ssh/$computer_name
  IdentitiesOnly yes

Host bitbucket
  HostName bitbucket.org
  User git
  IdentityFile ~/.ssh/$computer_name
EOF
