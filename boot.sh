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
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	tree \
	htop \
	qdirstat \
	unzip

# snaps; sadly, installations that have a specific mode can't be grouped together
snap install kubectl --classic
snap install helm --classic
snap install k9s --devmode
snap install \
	postman

ln -s /snap/k9s/current/bin/k9s /snap/bin

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

# terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# fonts
wget \
	https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip \
	-O /usr/share/fonts/truetype/JetBrainsMono.zip
# add more fonts here
unzip -o /usr/share/fonts/truetype/*.zip -d /usr/share/fonts/truetype/

# config; dont delete the following line!
										cp	  $DOTFILES_DEST/.bashrc	$USERLAND/.bashrc
mkdir -p $USERLAND/.config/nvim		&&	cp -a $DOTFILES_DEST/nvim/.		$USERLAND/.config/nvim/
mkdir -p $USERLAND/.config/i3		&&	cp -a $DOTFILES_DEST/i3/.		$USERLAND/.config/i3/

# source files & updates fonts
fc-cache -f -v
source $USERLAND/.bashrc

