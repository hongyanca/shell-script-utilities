#!/bin/bash

# Get the CPU architecture
ARCH=$(uname -m)

# Check if the architecture is aarch64
if [ "$ARCH" != "x86_64" ]; then
  echo "Warning: This script is designed for x86_64 architecture, but the current architecture is $ARCH."
  exit 1
fi

# GitHub API URL for Neovim releases
GITHUB_API_URL="https://api.github.com/repos/neovim/neovim/releases"

# Detect OS
OS=$(uname -s)

# Set variables based on OS
case "$OS" in
Darwin)
  INSTALL_DIR="$HOME/Applications/nvim-macos-x86_64"
  PACKAGE_NAME="nvim-macos-x86_64.tar.gz"
  ;;
Linux)
  INSTALL_DIR="$HOME/.local/nvim-linux64"
  PACKAGE_NAME="nvim-linux64.tar.gz"
  ;;
*)
  echo "Unsupported OS: $OS"
  exit 1
  ;;
esac

# Temporary file path for the downloaded package
PACKAGE_PATH="/tmp/$PACKAGE_NAME"

# Fetch the JSON response using curl
response=$(curl -s $GITHUB_API_URL)

# Extract the 'body' field of the latest prerelease and filter out the version string
latest_prerelease_version=$(echo "$response" | jq -r '.[] | select(.prerelease) | .body' | grep -Eo 'NVIM\s+\S+')

# Get installed Neovim version
if [ -x "$INSTALL_DIR"/bin/nvim ]; then
  installed_version=$(NVIM_APPNAME=nvim-dev "$INSTALL_DIR"/bin/nvim --version | head -n 1 | grep -Eo 'NVIM\s+\S+')
else
  installed_version=""
fi
# installed_version=$(nvim --version | head -n 1 | grep -Eo 'NVIM\s+\S+')

# Check if a version was found
if [ -n "$latest_prerelease_version" ]; then
  echo "The latest Neovim prerelease version is: $latest_prerelease_version"
  echo "Installed Neovim prerelease version is:  $installed_version"

  # Compare installed version with the latest prerelease version
  if [ "$latest_prerelease_version" != "$installed_version" ]; then
    echo "The installed version is outdated. Downloading the latest prerelease version..."

    # Extract the download URL for the correct package from the response
    download_url=$(echo "$response" | jq -r ".[] | select(.prerelease) | .assets[] | select(.name == \"$PACKAGE_NAME\") | .browser_download_url" | head -n 1)

    if [ -n "$download_url" ]; then
      echo "Downloading from $download_url..."

      # Download the tarball to /tmp/nvim-macos-x86_64.tar.gz
      curl -L -o "$PACKAGE_PATH" "$download_url"

      # Extract the tarball to the installation directory
      echo "Extracting Neovim to $INSTALL_DIR..."
      rm -rf "$INSTALL_DIR"
      if [ "$OS" = "Darwin" ]; then
        xattr -c "$PACKAGE_PATH"
      fi
      if [ "$OS" = "Darwin" ]; then
        tar -xzf "$PACKAGE_PATH" -C "$HOME/Applications/"
      elif [ "$OS" = "Linux" ]; then
        tar -xzf "$PACKAGE_PATH" -C "$HOME/.local/"
      fi

      # Clean up
      rm -rf "$PACKAGE_PATH"
      echo "Neovim updated successfully."
    else
      echo "Could not find the download URL for nvim-macos-x86_64.tar.gz."
    fi
  else
    echo "The installed version is up-to-date."
  fi
else
  echo "No prerelease version information found."
fi
