#!/bin/bash

# Create a shell script to download this script and run it
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/hongyanca/shell-script-utilities/main/installers/install-modern-utils.sh)"

# This script automates the process of downloading, extracting, and installing
# the latest release of modern Linux utilities from GitHub.

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to install a required package based on the distribution
install_required_package() {
  package=$1

  # Get the ID_LIKE value from /etc/os-release
  id_like=$(grep "^ID_LIKE=" /etc/os-release | cut -d= -f2 | tr -d '"')

  # If ID_LIKE is empty, fall back to reading the ID value
  if [[ -z $id_like ]]; then
    id_like=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
  fi

  # Function to check if a package is installed
  is_installed() {
    if command -v "$package" &>/dev/null; then
      return 0
    else
      return 1
    fi
  }

  # Check if the package is already installed
  if is_installed; then
    echo -e "${GREEN}✔ ${BLUE}$package${NC}"
    return 0
  fi

  # Check if ID_LIKE contains 'rhel' or 'debian' and install the package
  if [[ "$id_like" == *"rhel"* ]]; then
    echo "Detected RHEL-based distribution. Using dnf to install $package."
    sudo dnf install -y "$package"
  elif [[ "$id_like" == *"debian"* ]]; then
    echo "Detected Debian-based distribution. Using apt-get to install $package."
    sudo apt-get update
    sudo apt-get install -y "$package"
  else
    echo "Unsupported distribution."
    return 1
  fi
}

echo "Installing required packages..."
REQUIRED_PKGS=("wget" "curl" "zsh" "tar" "jq" "unzip" "p7zip" "bzip2" "make" "git" "xclip" "zsh-syntax-highlighting")
# Install each package in the packages array
for package in "${REQUIRED_PKGS[@]}"; do
  install_required_package "$package"
done

# Function to install the latest release of a GitHub repository
# Usage: install_latest_release "repo" "asset_suffix" ["alt_util_name"] ["symlink_name"]
# Parameters:
# - repo: The GitHub repository in the format "owner/repo" (e.g., "junegunn/fzf").
# - asset_suffix: The suffix of the asset file to download (e.g., "linux_amd64.tar.gz").
# - alt_util_name (optional): An alternative name for the utility to use during installation.
# - symlink_name (optional): A name for creating a symbolic link to the installed utility.
# Example: install_latest_release "junegunn/fzf" "linux_amd64.tar.gz"
# Example: install_latest_release "BurntSushi/ripgrep" "x86_64-unknown-linux-musl.tar.gz" "rg"
# Example: install_latest_release "dundee/gdu" "linux_amd64_static.tgz" "gdu_linux_amd64_static" "gdu"
install_latest_release() {
  local repo=$1 asset_suffix=$2 alt_util_name=$3 symlink_name=$4
  local latest_release asset_filename asset_url decomp_dir
  local util_bin_fn util_name util_path

  util_name=$(echo "$repo" | awk -F'/' '{print $2}')
  latest_release=$(curl -s "https://api.github.com/repos/$repo/releases/latest")
  asset_filename=$(echo "$latest_release" | jq -r --arg suffix "$asset_suffix" '.assets[] | select(.name | endswith($suffix)) | .name')
  asset_url=$(echo "$latest_release" | jq -r --arg suffix "$asset_suffix" '.assets[] | select(.name | endswith($suffix)) | .browser_download_url')

  echo "Downloading $util_name from $asset_url"
  wget -q --show-progress -O "$asset_filename" "$asset_url"

  decomp_dir="tmp-$util_name-install"
  echo "Extracting $asset_filename to $decomp_dir"
  rm -rf "$decomp_dir"
  mkdir -p "$decomp_dir"

  if [[ "$asset_filename" == *.zip ]]; then
    unzip "$asset_filename" -d "$decomp_dir"
  else
    tar -xf "$asset_filename" -C "$decomp_dir"
  fi

  # Use the provided alternative utility name if given
  if [ -n "$alt_util_name" ]; then
    util_bin_fn=$alt_util_name
  else
    util_bin_fn=$util_name
  fi
  # Find the executable file
  util_path=$(find "$decomp_dir" -type f -name "$util_bin_fn" -executable 2>/dev/null)
  sudo install "$util_path" /usr/local/bin

  # Extract the last part of the path if util_bin_fn contains /
  util_bin_fn=$(basename "$util_bin_fn")

  # Check if the utility has been installed
  if [ -f "/usr/local/bin/$util_bin_fn" ]; then
    # Get the file creation time in seconds since epoch
    file_creation_time=$(stat -c %Y "/usr/local/bin/$util_bin_fn")
    current_time=$(date +%s)
    time_diff=$((current_time - file_creation_time))

    # Check if the file was created within the last minute (60 seconds)
    if [ $time_diff -le 60 ]; then
      echo -e "${GREEN}✔ ${BLUE}$util_name${NC} has been installed successfully."
    else
      echo "$util_name has already been installed previously."
    fi
  else
    echo -e "${RED}Failed to install $util_name.${NC}"
  fi

  # Create a symbolic link if the fourth argument is provided
  if [ -n "$symlink_name" ]; then
    sudo ln -sf "/usr/local/bin/$util_bin_fn" "/usr/local/bin/$symlink_name"
    ls -lh "/usr/local/bin/$symlink_name"
  fi
  ls -lh "/usr/local/bin/$util_bin_fn"
  "/usr/local/bin/$util_bin_fn" --version

  printf "Cleaning up...\n\n"
  rm -rf "$asset_filename" "$decomp_dir"
}

install_latest_release "ClementTsang/bottom" "x86_64-unknown-linux-gnu.tar.gz" "btm"
install_latest_release "aristocratos/btop" "x86_64-linux-musl.tbz"
install_latest_release "junegunn/fzf" "linux_amd64.tar.gz"
install_latest_release "sharkdp/fd" "x86_64-unknown-linux-gnu.tar.gz"
install_latest_release "sharkdp/bat" "x86_64-unknown-linux-gnu.tar.gz"
install_latest_release "jesseduffield/lazygit" "Linux_x86_64.tar.gz"
install_latest_release "lsd-rs/lsd" "x86_64-unknown-linux-gnu.tar.gz"
install_latest_release "BurntSushi/ripgrep" "x86_64-unknown-linux-musl.tar.gz" "rg"
install_latest_release "dundee/gdu" "linux_amd64_static.tgz" "gdu_linux_amd64_static" "gdu"
install_latest_release "ajeetdsouza/zoxide" "x86_64-unknown-linux-musl.tar.gz"
install_latest_release "sxyazi/yazi" "x86_64-unknown-linux-musl.zip"
# Install yazi cli tool ya for plugin/flavor management
install_latest_release "sxyazi/yazi" "x86_64-unknown-linux-musl.zip" "ya"

print_post_install_info() {
  # Display recommended post-installation instructions
  echo ""
  echo "Please add the following lines to your ~/.zshrc or ~/.bashrc:"
  echo -e "${BLUE}#################################${NC}"
  echo "alias ls='lsd'"
  echo "alias l='ls -l'"
  echo "alias la='ls -a'"
  echo "alias ll='ls -la'"
  echo "alias lla='ls -la'"
  echo "alias lt='ls --tree'"
  echo "alias vi='nvim'"
  echo "alias vim='nvim'"
  echo ""
  echo "# Set up fzf key bindings and fuzzy completion"
  echo "source <(fzf --zsh)"
  echo 'export FZF_DEFAULT_COMMAND="fd --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build} --type f"'
  echo ""
  echo "# https://unix.stackexchange.com/questions/273861/unlimited-history-in-zsh"
  echo "setopt APPEND_HISTORY"
  echo "setopt INC_APPEND_HISTORY"
  echo "setopt SHARE_HISTORY"
  echo "setopt HIST_EXPIRE_DUPS_FIRST"
  echo "setopt HIST_IGNORE_DUPS"
  echo "setopt HIST_IGNORE_ALL_DUPS"
  echo "setopt HIST_SAVE_NO_DUPS"
  echo "setopt HIST_IGNORE_SPACE"
  echo "HISTFILE=$HOME/.zsh_history"
  echo "SAVEHIST=1000000"
  echo "HISTSIZE=1000000"
  echo ""
  echo "eval \"\$(zoxide init zsh)\""
  echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  echo 'function y() {'
  echo '  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd'
  echo '  yazi "$@" --cwd-file="$tmp"'
  echo '  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then'
  echo '    builtin cd -- "$cwd"'
  echo '  fi'
  echo '  rm -f -- "$tmp"'
  echo '}'
  echo -e "${BLUE}#################################${NC}"
  echo ""
}

# Install Neovim
latest_neovim_release=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | jq -r '.tag_name')
install_latest_release "neovim/neovim" "linux64.tar.gz" "nvim"
sudo rm -rf /tmp/neovim
git clone --depth 1 --branch "$latest_neovim_release" https://github.com/neovim/neovim /tmp/neovim
sudo rm -rf /usr/local/share/nvim
sudo cp -r /tmp/neovim/runtime /usr/local/share/nvim/
sudo rm -rf /tmp/neovim

print_post_install_info
