#!/bin/bash

# Install pre-built neovim binaries for Linux systems.
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz

echo 'export PATH="/opt/nvim-linux64/bin:$PATH"' >>~/.bashrc

sudo apt-get install -y python3-pip python3.10-venv python3-neovim tar unzip gcc make autojump p7zip libbz2-dev wget ripgrep fzf

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit*

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&
	sudo apt-get install -y nodejs

sudo add-apt-repository ppa:daniel-milde/gdu -y
sudo apt-get update
sudo apt-get install gdu -y

# https://github.com/ClementTsang/bottom
curl -LO https://github.com/ClementTsang/bottom/releases/download/0.9.6/bottom_0.9.6_amd64.deb
sudo dpkg -i bottom_0.9.6_amd64.deb
rm bottom_0.9.6_amd64.deb

mkdir -p "${HOME}/.npm-packages"
npm config set prefix "${HOME}/.npm-packages"
echo 'NPM_PACKAGES="${HOME}/.npm-packages"' >>~/.bashrc
echo 'export PATH="$PATH:$NPM_PACKAGES/bin"' >>~/.bashrc
echo 'export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"' >>~/.bashrc

source ~/.bashrc
npm install tree-sitter-cli -g

pip3 install --user --upgrade neovim
npm install -g neovim

git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
git clone https://github.com/hongyanca/astronvim-user ~/.config/nvim/lua/user

sudo rm -f /usr/bin/nvim
sudo ln -s /opt/nvim-linux64/bin/nvim /usr/bin/nvim
