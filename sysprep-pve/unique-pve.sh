#!/usr/bin/env bash

# This script makes a Proxmox unique by regenerating identifiers,
# changing the nodename/hostname and SSH host keys, and clearing logs.

set -e # Exit immediately if a command exits with a non-zero status.

# Function to prompt the user for input
prompt_input() {
  local prompt="$1"
  local input
  read -rp "$prompt: " input
  echo "$input"
}

backup_dir="$HOME/.sys_backup"
mkdir -p "$backup_dir"

# https://rogerswb.github.io/renaming-pve-nodes
echo "Stopping services: pve-cluster pvestatd"
sudo systemctl stop pve-cluster pvestatd
sudo cp -f /var/lib/pve-cluster/config.db "$backup_dir/config.db.backup"
echo "Starting services: pve-cluster pvestatd"
sudo systemctl start pve-cluster pvestatd
# Delete any directories in /etc/pve/nodes other than the one for the current hostname.
sudo find /etc/pve/nodes -mindepth 1 -maxdepth 1 -type d ! -name "$(hostname)" -exec rm -rf {} +
echo "Content of /etc/pve/nodes directory:"
ls -l /etc/pve/nodes
echo "Stopping services: pve-cluster pvestatd"
sudo systemctl stop pve-cluster pvestatd

# Change the hostname
echo "Step 1: Change nodename/hostname"
new_hostname=$(prompt_input "Enter the new hostname")
old_hostname=$(hostname)
sudo sed -i "s/\b$old_hostname\b/$new_hostname/g" /etc/hosts
sudo hostnamectl set-hostname "$new_hostname"
echo "Hostname changed from $old_hostname to $new_hostname"
echo "Updated /etc/hosts file:"
cat /etc/hosts
echo "Updated /etc/hostname file:"
cat /etc/hostname
# Update config.db
echo "Node name in /var/lib/pve-cluster/config.db before database update"
sudo sqlite3 /var/lib/pve-cluster/config.db "SELECT * FROM tree WHERE name = '$old_hostname';"
echo "Replacing node name in /var/lib/pve-cluster/config.db"
sudo sqlite3 /var/lib/pve-cluster/config.db "UPDATE tree SET name = '$new_hostname' WHERE name = '$old_hostname';"
echo "Node name in /var/lib/pve-cluster/config.db after database update"
sudo sqlite3 /var/lib/pve-cluster/config.db "SELECT * FROM tree WHERE name = '$new_hostname';"
# Handle Proxmox-specific configuration
echo "Handling Proxmox-specific configuration..."
rrd_node_old="/var/lib/rrdcached/db/pve2-node/$old_hostname"
rrd_node_new="/var/lib/rrdcached/db/pve2-node/$new_hostname"
rrd_storage_old="/var/lib/rrdcached/db/pve2-storage/$old_hostname"
rrd_storage_new="/var/lib/rrdcached/db/pve2-storage/$new_hostname"
sudo mv "$rrd_node_old" "$rrd_node_new"
sudo mv "$rrd_storage_old" "$rrd_storage_new"
echo "******************************************"
echo

# Change management interface IP
echo "Step 2: Update IP Address for Management Interface"
current_ip=$(ip -4 addr show dev Management | grep inet | awk '{print $2}' | cut -d/ -f1)
echo "Current IP address for iface Management is $current_ip"
new_ipv4=$(prompt_input "Enter the new IP address for iface Management (e.g., 192.168.1.100)")
# Create a backup of /etc/network/interfaces
echo "Backing up /etc/network/interfaces"
sudo cp /etc/network/interfaces "$backup_dir/interfaces.backup"
# Replace the IP address under `iface Management inet static`
echo "Updating /etc/network/interfaces with the new IP address"
sudo sed -i "s/$current_ip/$new_ipv4/g" /etc/network/interfaces
# Show the content of the new /etc/network/interfaces file
echo "The updated /etc/network/interfaces file:"
cat /etc/network/interfaces
echo "Updating /etc/hosts file"
sudo sed -i "s/$current_ip/$new_ipv4/g" /etc/hosts
echo "Updated /etc/hosts file:"
cat /etc/hosts
sudo /usr/bin/pvebanner
echo "Updated banner:"
sudo cat /etc/issue
echo "******************************************"
echo

# Regenerate machine-id
echo "Step 3: Regenerating machine-id"
sudo rm -f /etc/machine-id /var/lib/dbus/machine-id
sudo systemd-machine-id-setup
sudo ln -sf /etc/machine-id /var/lib/dbus/machine-id
echo "New machine-id: $(cat /etc/machine-id)"
echo "******************************************"
echo

# Regenerate SSH host keys
echo "Step 4: Regenerating SSH host keys"
sudo rm -f /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
echo "SSH host keys regenerated."
echo "******************************************"
echo

# Clear logs
echo "Step 5: Clearing logs"
sudo find /var/log -type f -exec truncate -s 0 {} \;
echo "Logs cleared."
echo "******************************************"
echo

# Final message
echo "New nodename/hostname: $new_hostname"
echo "New iface Management IPv4 address: $new_ipv4"
echo
echo "Reboot the server for the changes to take effect."
echo