#!/usr/bin/env bash

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
  elif [[ $ID_LIKE == *"arch"* ]]; then
    LINUX_DISTRO="arch"
  else
    LINUX_DISTRO="unknown"
  fi
}
get_distro

bash -c "$(curl -fsSL https://raw.githubusercontent.com/hongyanca/shell-script-utilities/main/installers/install-neovim.sh)"

rm -rf ~/.local/share/nvim-lazyvim
rm -rf ~/.local/state/nvim-lazyvim
rm -rf ~/.cache/nvim-lazyvim
rm -rf ~/.config/nvim-lazyvim
git clone --depth 1 https://github.com/hongyanca/lazyvim_config ~/.config/nvim-lazyvim

# Install neovim configurations
NVIM_APPNAME=nvim-lazyvim nvim --headless -c 'quitall'

if [[ $LINUX_DISTRO == "rhel" ]]; then
  echo
  echo "Add the following alias to ~/.zshrc or ~/.bashrc"
  echo "alias nvim='NVIM_APPNAME=nvim-lazyvim nvim'"
elif [[ $LINUX_DISTRO == "debian" ]]; then
  echo
  echo "Add the following alias to ~/.zshrc or ~/.bashrc"
  echo "alias nvim='NVIM_APPNAME=nvim-lazyvim nvim'"
elif [[ $LINUX_DISTRO == "arch" ]]; then
  echo
  echo "Add the following alias to ~/.config/fish/config.fish"
  echo "set -x NVIM_APPNAME nvim-lazyvim"
  echo "set -x NPM_PACKAGES \"$HOME/.npm-packages\""
  echo "set -x PATH \$PATH \$NPM_PACKAGES/bin \$HOME/.local/bin"
fi
