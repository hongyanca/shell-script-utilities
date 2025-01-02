#!/usr/bin/env bash

bash -c "$(curl -fsSL https://raw.githubusercontent.com/hongyanca/shell-script-utilities/main/installers/install-neovim.sh)"

rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
rm -rf ~/.config/nvim
git clone --depth 1 https://github.com/hongyanca/kickstart.nvim.git ~/.config/nvim

# Install neovim configurations
nvim --headless -c 'quitall'