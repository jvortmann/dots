if [ $# -ne 1 ]
then
  echo 'Usage: ./setup-github-username.sh "GitHub username"'
  exit 1
fi

github_username="$1"

echo; echo ">> Setting Github username"
cat > "$HOME/.config/git/github" <<EOF
# vim: ft=gitconfig

[github]
  user = $github_username
EOF
