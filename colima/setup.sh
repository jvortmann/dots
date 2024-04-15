echo; echo ">> Setting symlinks for colima"
mkdir -p ~/.colima/_templates/
ln -sfnv ~/.dots/colima/default.yaml ~/.colima/_templates/default.yaml
sudo ln -sfnv ~/.colima/docker.sock /var/run/docker.sock
