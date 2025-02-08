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
  wget curl bzip2 gcc make p7zip p7zip-full p7zip-rar unzip zsh fish \
  cifs-utils nfs-common git git-lfs conntrackd containerd.io \
  libbz2-dev python3-pip passwd zsh-syntax-highlighting stow \
  ubuntu-advantage-tools ntp iperf3 jq bat btop gdu

################################################################################
cat <<EOF >~/.nanorc
set softwrap
set tabsize 4
set tabstospaces
#set linenumbers
unset mouse
EOF

sudo cp ~/.nanorc /root/.nanorc
