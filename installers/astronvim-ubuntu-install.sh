#!/bin/bash

sudo apt-get update
sudo apt-get install -y gcc make libbz2-dev python3-pip
bash -c "$(curl -fsSL https://raw.githubusercontent.com/hongyanca/shell-script-utilities/main/installers/install-modern-utils.sh)"

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs
# Install npm packages globally without sudo on Linux
mkdir -p "${HOME}/.npm-packages"
npm config set prefix "${HOME}/.npm-packages"
echo 'NPM_PACKAGES="${HOME}/.npm-packages"' >>~/.zshrc
echo 'export PATH="$PATH:$NPM_PACKAGES/bin"' >>~/.zshrc
echo 'export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"' >>~/.zshrc
echo 'NPM_PACKAGES="${HOME}/.npm-packages"' >>~/.bashrc
echo 'export PATH="$PATH:$NPM_PACKAGES/bin"' >>~/.bashrc
echo 'export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"' >>~/.bashrc
source ~/.bashrc
npm install tree-sitter-cli neovim pyright -g

python3 -m pip install --upgrade pip --break-system-packages
python3 -m pip install --user --upgrade pynvim --break-system-packages

rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
rm -rf ~/.config/nvim
git clone --depth 1 https://github.com/hongyanca/astronvim_config ~/.config/nvim
# Comment out python and rust community packages
sed -i 's/^\(\s*{\s*import\s*=\s*"astrocommunity\.pack\.rust"\s*}\)/  --\1/' ~/.config/nvim/lua/community.lua
sed -i 's/^\(\s*{\s*import\s*=\s*"astrocommunity\.pack\.python"\s*}\)/  --\1/' ~/.config/nvim/lua/community.lua
# Copy neovim runtime files
sudo rm -rf /tmp/neovim
git clone --depth 1 --branch v0.10.0 https://github.com/neovim/neovim /tmp/neovim
sudo rm -rf /usr/local/share/nvim
sudo cp -r /tmp/neovim/runtime /usr/local/share/nvim/
# Install neovim configurations
nvim --headless -c 'quitall'
sudo rm -rf /tmp/neovim

sudo rm -f /usr/bin/nvim
sudo ln -s /usr/local/bin/nvim /usr/bin/nvim
