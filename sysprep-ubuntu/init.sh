#!/bin/bash

sudo usermod -aG sudo ubuntu

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
# Add repos
sudo apt-get install -y apt-transport-https ca-certificates curl
# Add git-lfs repo
echo "Adding git-lfs repo..."
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
# Add Docker repo
echo "Adding Docker repo for containerd..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get install -y --install-recommends linux-generic-hwe-22.04 \
  bzip2 gcc make autojump p7zip p7zip-full p7zip-rar zsh \
  cifs-utils nfs-common git-lfs conntrackd containerd.io
sudo apt autoremove

################################################################################
echo "Getting ready for k8s..."
# Forwarding IPv4 and letting iptables see bridged traffic
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
lsmod | grep overlay
lsmod | grep br_netfilter

echo -e "net.core.rmem_max=26214400\nnet.core.rmem_default=26214400\n\nnet.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.conf.default.rp_filter=1\nnet.ipv4.conf.all.rp_filter=1\nnet.ipv4.ip_forward=1\nnet.ipv6.conf.all.forwarding=1\nnet.netfilter.nf_conntrack_max=524288" | sudo tee -a /etc/sysctl.conf

sudo sysctl -p
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# Configure containerd and start service
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

################################################################################
echo "Installing btop..."
cd ~
wget https://github.com/aristocratos/btop/releases/download/v1.2.13/btop-x86_64-linux-musl.tbz
tar -xjf  btop-x86_64-linux-musl.tbz
sudo mv btop/bin/btop /usr/local/bin
rm -rf btop*

################################################################################
echo "Installing lsd..."
cd ~
wget https://github.com/lsd-rs/lsd/releases/download/v1.0.0/lsd_1.0.0_amd64.deb
sudo apt install ./lsd_1.0.0_amd64.deb
sudo ln -sf /usr/bin/lsd /usr/local/bin/lsd
rm lsd*.deb

################################################################################
cat << EOF > ~/.nanorc
set softwrap
set tabsize 4
set tabstospaces
#set linenumbers
unset mouse
EOF

sudo cp ~/.nanorc /root/.nanorc

################################################################################
echo "" >> ~/.bashrc
echo "alias ls='lsd'" >> ~/.bashrc
echo "alias l='ls -l'" >> ~/.bashrc
echo "alias la='ls -a'" >> ~/.bashrc
echo "alias ll='ls -la'" >> ~/.bashrc
echo "alias lla='ls -la'" >> ~/.bashrc
echo "alias lt='ls --tree'" >> ~/.bashrc
echo "" >> ~/.bashrc
echo "alias k='kubectl'" >> ~/.bashrc
echo "" >> ~/.bashrc
source ~/.bashrc
