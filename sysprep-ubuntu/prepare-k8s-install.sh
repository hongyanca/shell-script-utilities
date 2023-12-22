echo "Getting ready for k8s..."
# Forwarding IPv4 and letting iptables see bridged traffic
sudo rm -rf /etc/modules-load.d/k8s.conf
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
lsmod | grep overlay
lsmod | grep br_netfilter

sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup
sudo rm -rf /etc/sysctl.conf
cat <<EOF | sudo tee -a /etc/sysctl.conf
net.core.rmem_max=26214400
net.core.rmem_default=26214400
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.netfilter.nf_conntrack_max=524288
EOF
sudo sysctl -p
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# Configure containerd and start service
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Overwrite the sandbox(pause) image
sudo sed -i 's/sandbox_image = "registry.k8s.io\/pause:3.6"/sandbox_image = "registry.k8s.io\/pause:3.9"/' /etc/containerd/config.toml
# Use the SystemdCgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
# Discard the compressed layer data after unpacking
sudo sed -i 's/discard_unpacked_layers = false/discard_unpacked_layers = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

echo "---------------"
echo "pause container"
cat /etc/containerd/config.toml | grep pause:
echo "SystemdCgroup"
cat /etc/containerd/config.toml | grep SystemdCgroup