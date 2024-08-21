#!/bin/bash

# ubuntu2404 setup
# Please have a look at https://github.com/antoniogrv/dotfiles for more information about what's included.

OWNER=$1
USERLAND="/home/$OWNER"

DOTFILES_DEST="$USERLAND/.dotfiles"
DOTFILES_ORIGIN="https://github.com/antoniogrv/dotfiles.git"

export DEBIAN_FRONTEND=noninteractive

echo "Dotfiles origin: $DOTFILES_ORIGIN"
echo "Dotfiles destination: $DOTFILES_DEST"
echo "Userland: $USERLAND"

systemctl daemon-reload

# update package repositories
apt update && apt -y upgrade

# install preliminary packages
apt install -y git

# clone the dotfiles repository
git clone --recursive $DOTFILES_ORIGIN $DOTFILES_DEST

# prevents prompt confirmation by the wireshark installer
echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections

# prevent dual booted systems from messing up the main system timezone
timedatectl set-local-rtc 1

# apt packages
# note: python is installed as python3
apt update
apt install -y \
	wireshark \
	neovim \
	xclip \
	feh \
	lxappearance \
	maim \
	copyq \
	compton \
	feh \
	pulseaudio-utils \
	i3 \
	software-properties-common \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	tree \
	htop \
	qdirstat \
	unzip \
	i3blocks \
	dconf-editor \
	python3-pip \
	dbus-x11

# snaps; sadly, installations that have a specific mode can't be grouped together
snap install kubectl	--classic
snap install helm		--classic
snap install terraform	--classic
snap install code		--classic
snap install aws-cli	--classic
snap install go			--classic
snap install k9s		--devmode
snap install \
	postman

ln -s /snap/k9s/current/bin/k9s /snap/bin

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# pip packages
pip install \
	i3-layouts \
	ranger-fm

# ansible
add-apt-repository --yes --update ppa:ansible/ansible
apt update
apt install -y ansible

# gns3
#add-apt-repository ppa:gns3/ppa
#apt update
#apt install -y gns3-gui gns3-server

# krew
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# minikube
curl -o $USERLAND/minikube.deb https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
dpkg -i $USERLAND/minikube.deb

# kind
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

# fonts
wget \
	https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip \
	-O /usr/share/fonts/truetype/JetBrainsMono.zip
# add more fonts here
unzip -o /usr/share/fonts/truetype/*.zip -d /usr/share/fonts/truetype/

# config; dont delete the following line!
										cp	  $DOTFILES_DEST/.gterminal.dconf	$USERLAND/.gterminal.dconf
										cp	  $DOTFILES_DEST/.bashrc			$USERLAND/.bashrc
mkdir -p $USERLAND/.config/nvim		&&	cp -a $DOTFILES_DEST/nvim/.				$USERLAND/.config/nvim/
mkdir -p $USERLAND/.config/i3		&&	cp -a $DOTFILES_DEST/i3/.				$USERLAND/.config/i3/

# docker-specific steps
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

apt install -y \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin

groupadd docker
usermod -aG docker $USER
newgrp docker
systemctl enable docker.service
systemctl enable containerd.service

# source terminal and shell profiles & updates fonts
fc-cache -f -v
source $USERLAND/.gterminal.dconf
dconf load /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ < $USERLAND/.gterminal.dconf
source $USERLAND/.bashrc

