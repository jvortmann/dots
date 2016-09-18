if [ $# -ne 2 ]
then
  echo 'Usage: ./setup-git-user.sh "User Name"  "user@email.com"'
  exit 1
fi

user_name="$1"
user_email="$2"

echo; echo ">> Setting git User and Email"
cat > "$HOME/.config/git/user" <<EOF
# vim: ft=gitconfig

[user]
  name = $user_name
  email = $user_email
EOF
