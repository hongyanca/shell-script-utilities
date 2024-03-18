#!/bin/bash

# Setup sudo without password
# Or run sudo visudo and add a line to the end of the file: ubuntu ALL=(ALL) NOPASSWD:ALL
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
sudo usermod -aG sudo ubuntu

sudo rm /etc/motd

################################################################################
# Disable swap
sudo swapoff -a
sudo sed -i '/swap/s/^/#/' /etc/fstab
echo "--- /etc/fstab ---"
sudo cat /etc/fstab
echo "------------------"

################################################################################
# Set timezone
sudo timedatectl set-timezone America/Edmonton

################################################################################
# Limit the syslog size
sudo sed -i 's/rotate 4/rotate 3/' /etc/logrotate.d/rsyslog
sudo sed -i '/weekly/a \\tmaxsize 100M' /etc/logrotate.d/rsyslog
# Limit the journal size
sudo sed -i '/\[Journal\]/a SystemMaxUse=100M' /etc/systemd/journald.conf

################################################################################
# Add repos to Apt sources
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
# Add git-lfs repo
echo "Adding git-lfs repo to apt sources..."
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
# Add Docker repo
echo "Adding Docker repo for to apt sources..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
	sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

sudo NEEDRESTART_MODE=a apt-get install -y --install-recommends \
	bzip2 gcc make autojump p7zip p7zip-full p7zip-rar zsh \
	cifs-utils nfs-common git-lfs conntrackd containerd.io \
	ubuntu-advantage-tools ntp iperf3 jq

################################################################################
echo "Installing btop..."
cd ~
wget https://github.com/aristocratos/btop/releases/download/v1.3.2/btop-x86_64-linux-musl.tbz
tar -xjf btop-x86_64-linux-musl.tbz
sudo mv btop/bin/btop /usr/local/bin
rm -rf btop*

################################################################################
echo "Installing lsd..."
cd ~
wget https://github.com/lsd-rs/lsd/releases/download/v1.0.0/lsd_1.0.0_amd64.deb
sudo NEEDRESTART_MODE=a apt-get install ./lsd_1.0.0_amd64.deb
sudo ln -sf /usr/bin/lsd /usr/local/bin/lsd
rm lsd*.deb

################################################################################
sudo apt-get update
# Disable default kernel update
sudo apt-mark hold linux-image-$(uname -r)
sudo NEEDRESTART_MODE=a apt-get -o APT::Get::Always-Include-Phased-Updates=true upgrade -y
sudo apt-get install -y --install-recommends linux-generic-hwe-22.04
sudo NEEDRESTART_MODE=a apt-get install linux-headers-generic linux-headers-virtual linux-image-virtual linux-virtual -y
sudo apt-get autoremove -y

################################################################################
cat <<EOF >~/.nanorc
set softwrap
set tabsize 4
set tabstospaces
#set linenumbers
unset mouse
EOF

sudo cp ~/.nanorc /root/.nanorc

################################################################################
echo "" >>~/.bashrc
echo "alias ls='lsd'" >>~/.bashrc
echo "alias l='ls -l'" >>~/.bashrc
echo "alias la='ls -a'" >>~/.bashrc
echo "alias ll='ls -la'" >>~/.bashrc
echo "alias lla='ls -la'" >>~/.bashrc
echo "alias lt='ls --tree'" >>~/.bashrc
echo "" >>~/.bashrc
echo "alias k='kubectl'" >>~/.bashrc

################################################################################
# Install pre-built NeoVim binaries for Linux systems.
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
sudo rm -rf /usr/bin/nvim
sudo ln -s /opt/nvim-linux64/bin/nvim /usr/bin/nvim
rm nvim-linux64.tar.gz
