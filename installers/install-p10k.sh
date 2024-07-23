#!/bin/bash

LINUX_DISTRO="unknown"
# Function to set the LINUX_DISTRO variable based on the ID_LIKE value
get_distro() {
  # Read the ID_LIKE value from /etc/os-release
  ID_LIKE=$(grep ^ID_LIKE= /etc/os-release | cut -d= -f2 | tr -d '"')

  # Check if ID_LIKE contains "rhel" or "debian"
  if [[ $ID_LIKE == *"rhel"* ]]; then
    LINUX_DISTRO="rhel"
  elif [[ $ID_LIKE == *"debian"* ]]; then
    LINUX_DISTRO="debian"
  else
    LINUX_DISTRO="unknown"
  fi
}
get_distro

# Install package that provides the chsh command
if [[ $LINUX_DISTRO == "rhel" ]]; then
  sudo dnf upgrade --refresh -y
  sudo dnf install -y util-linux-user
elif [[ $LINUX_DISTRO == "debian" ]]; then
  sudo apt-get update
  sudo apt-get install -y passwd
else
  echo "Unknown distro" >&2
  exit 1
fi

rm -rf ~/.p10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.p10k
echo 'source ~/.p10k/powerlevel10k.zsh-theme' >>~/.zshrc

sudo chsh -s $(which zsh) $USER

echo "Please logout and login again to apply powerlevel10k."
