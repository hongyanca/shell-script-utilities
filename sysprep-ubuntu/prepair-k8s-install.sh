echo "Getting ready for k8s..."
# Forwarding IPv4 and letting iptables see bridged traffic
echo -e "overlay\nbr_netfilter" | sudo tee -a /etc/modules-load.d/k8s.conf
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

sudo sed -i 's/sandbox_image = "registry.k8s.io\/pause:3.6"/sandbox_image = "registry.k8s.io\/pause:3.9"/' /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Overwrite the sandbox(pause) image
sudo sed -i 's/sandbox_image = "registry.k8s.io\/pause:3.6"/sandbox_image = "registry.k8s.io\/pause:3.9"/' /etc/containerd/config.toml
# Use the SystemdCgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
