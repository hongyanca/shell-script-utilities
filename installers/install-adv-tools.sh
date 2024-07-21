#!/bin/bash

# This script automates the process of downloading, extracting, and installing
# the latest release of a specified utility from GitHub.

# Function to install the latest release of a GitHub repository
# Usage: install_latest_release "repo" "asset_suffix" ["alt_util_name"]
# Example: install_latest_release "junegunn/fzf" "linux_amd64.tar.gz"
# Example: install_latest_release "BurntSushi/ripgrep" "x86_64-unknown-linux-musl.tar.gz" "rg"
install_latest_release() {
  local repo=$1 asset_suffix=$2 alt_util_name=$3
  local latest_release asset_filename asset_url decomp_dir
  local util_bin_fn util_name

  util_name=$(echo "$repo" | awk -F'/' '{print $2}')
  latest_release=$(curl -s "https://api.github.com/repos/$repo/releases/latest")
  asset_filename=$(echo "$latest_release" | jq -r --arg suffix "$asset_suffix" '.assets[] | select(.name | endswith($suffix)) | .name')
  asset_url=$(echo "$latest_release" | jq -r --arg suffix "$asset_suffix" '.assets[] | select(.name | endswith($suffix)) | .browser_download_url')

  echo "Downloading $util_name from $asset_url"
  wget -q --show-progress -O "$asset_filename" "$asset_url"

  decomp_dir="${asset_filename%.tar.gz}"
  echo "Extracting $asset_filename to $decomp_dir"
  # Check if the tarball contains a directory
  if tar -tzf "$asset_filename" | grep -q '/$'; then
    # The tarball contains a directory
    tar -xf "$asset_filename"
  else
    # The tarball does not contain a directory
    mkdir -p "$decomp_dir"
    tar -xf "$asset_filename" -C "$decomp_dir"
  fi

  # Use the provided alternative utility name if given
  if [ -n "$alt_util_name" ]; then
    util_bin_fn=$alt_util_name
  else
    util_bin_fn=$util_name
  fi
  sudo install "$decomp_dir/$util_bin_fn" /usr/local/bin

  # Check if the utility has been installed
  if [ -f "/usr/local/bin/$util_bin_fn" ]; then
    # Get the file creation time in seconds since epoch
    file_creation_time=$(stat -c %Y "/usr/local/bin/$util_bin_fn")
    current_time=$(date +%s)
    time_diff=$((current_time - file_creation_time))

    # Check if the file was created within the last minute (60 seconds)
    if [ $time_diff -le 60 ]; then
      echo "$util_name has been installed successfully."
    else
      echo "$util_name has already been installed previously."
    fi
  fi
  ls -l "/usr/local/bin/$util_bin_fn"

  printf "Cleaning up...\n\n"
  rm -rf "$asset_filename" "$decomp_dir"
}

install_latest_release "junegunn/fzf" "linux_amd64.tar.gz"
install_latest_release "sharkdp/fd" "x86_64-unknown-linux-gnu.tar.gz"
install_latest_release "sharkdp/bat" "x86_64-unknown-linux-gnu.tar.gz"
install_latest_release "jesseduffield/lazygit" "Linux_x86_64.tar.gz"
install_latest_release "lsd-rs/lsd" "x86_64-unknown-linux-gnu.tar.gz"
install_latest_release "BurntSushi/ripgrep" "x86_64-unknown-linux-musl.tar.gz" "rg"
