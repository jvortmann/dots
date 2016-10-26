if [ $# -ne 2 ]
then
  echo 'Usage: ./setup-ssh-key.sh "Computer Name"  "Email"'
  exit 1
fi

computer_name="$1"
user_email="$2"

echo; echo ">> Setting ssh key"
ssh-keygen -t rsa -b 4096 -C "$user_email" -f "$HOME/.ssh/$computer_name"

echo; echo ">> Adding new key to ssh agent"
ssh-add "$HOME/.ssh/$computer_name"

echo; echo ">> Copying public key to clipboard"
cat "$HOME/.ssh/$computer_name.pub" | pbcopy
