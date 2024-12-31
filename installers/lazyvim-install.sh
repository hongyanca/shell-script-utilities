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
  elif [[ $ID_LIKE == *"arch"* ]]; then
    LINUX_DISTRO="arch"
  else
    LINUX_DISTRO="unknown"
  fi
}
get_distro

# Install npm packages globally without sudo on Linux
mkdir -p "${HOME}/.npm-packages"
export NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$PATH:$NPM_PACKAGES/bin"
# Install packages based on the LINUX_DISTRO value
if [[ $LINUX_DISTRO == "rhel" ]]; then
  sudo dnf upgrade --refresh -y
  sudo dnf install -y yum-utils gcc make python3-pip
  python3 -m pip install --upgrade pip
  python3 -m pip install --user --upgrade pynvim
  # Install Node.js 22.x
  # Use `sudo dnf module list nodejs` to list available Node.js versions
  # Use `sudo dnf module reset nodejs:20/common` to reset the default version
  sudo dnf module install nodejs:22/common
elif [[ $LINUX_DISTRO == "debian" ]]; then
  sudo apt-get update
  sudo apt-get install -y gcc make libbz2-dev python3-pip
  python3 -m pip install --upgrade pip --break-system-packages
  python3 -m pip install --user --upgrade pynvim --break-system-packages
  # Install Node.js 22.x
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt-get install -y nodejs
elif [[ $LINUX_DISTRO == "arch" ]]; then
  sudo pacman -Syu
  sudo pacman -S --needed --noconfirm archlinux-keyring gcc make python python-pip lua nodejs npm
  python3 -m pip install --upgrade pip --break-system-packages
  python3 -m pip install --user --upgrade pynvim --break-system-packages
else
  echo "Unknown distro" >&2
  exit 1
fi
npm install tree-sitter-cli neovim pyright -g

if [[ $LINUX_DISTRO == "rhel" ]]; then
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/hongyanca/shell-script-utilities/main/installers/install-modern-utils.sh)"
elif [[ $LINUX_DISTRO == "debian" ]]; then
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/hongyanca/shell-script-utilities/main/installers/install-modern-utils.sh)"
elif [[ $LINUX_DISTRO == "arch" ]]; then
  sudo pacman -S --needed --noconfirm wget curl ca-certificates gnupg zsh tar make xclip \
    git unzip p7zip bzip2 jq bat btop fzf fd fastfetch gdu lsd ripgrep yazi zoxide neovim
fi

rm -rf ~/.local/share/nvim-lazyvim
rm -rf ~/.local/state/nvim-lazyvim
rm -rf ~/.cache/nvim-lazyvim
rm -rf ~/.config/nvim-lazyvim
git clone --depth 1 https://github.com/hongyanca/lazyvim_config ~/.config/nvim-lazyvim

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
