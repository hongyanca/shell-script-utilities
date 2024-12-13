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
else
  echo "Unknown distro" >&2
  exit 1
fi

bash -c "$(curl -fsSL https://raw.githubusercontent.com/hongyanca/shell-script-utilities/main/installers/install-modern-utils.sh)"

# Install npm packages globally without sudo on Linux
mkdir -p "${HOME}/.npm-packages"
npm config set prefix "${HOME}/.npm-packages"
echo 'NPM_PACKAGES="${HOME}/.npm-packages"' >>~/.zshrc
echo 'export PATH="$PATH:$NPM_PACKAGES/bin"' >>~/.zshrc
echo 'export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"' >>~/.zshrc
echo 'NPM_PACKAGES="${HOME}/.npm-packages"' >>~/.bashrc
echo 'export PATH="$PATH:$NPM_PACKAGES/bin"' >>~/.bashrc
echo 'export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"' >>~/.bashrc
source $HOME/.bashrc
npm install tree-sitter-cli neovim pyright -g

rm -rf ~/.local/share/nvim-lazyvim
rm -rf ~/.local/state/nvim-lazyvim
rm -rf ~/.cache/nvim-lazyvim
rm -rf ~/.config/nvim-lazyvim
git clone --depth 1 https://github.com/hongyanca/lazyvim_config ~/.config/nvim-lazyvim

echo
echo "Add the following alias to ~/.zshrc or ~/.bashrc"
echo "alias nvim='NVIM_APPNAME=nvim-lazyvim nvim'"
