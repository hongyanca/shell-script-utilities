#!/bin/bash

LINUX_DISTRO="unknown"
# Function to set the LINUX_DISTRO variable based on the ID_LIKE or ID value
get_distro() {
  # Attempt to read the ID_LIKE value from /etc/os-release
  ID_LIKE=$(grep ^ID_LIKE= /etc/os-release | cut -d= -f2 | tr -d '"')

  # If ID_LIKE is empty, fall back to reading the ID value
  if [[ -z $ID_LIKE ]]; then
    ID_LIKE=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
  fi

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
echo 'typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet' >>~/.zshrc

sudo chsh -s "$(which zsh)" "$USER"

echo "Please logout and login again to apply powerlevel10k."
