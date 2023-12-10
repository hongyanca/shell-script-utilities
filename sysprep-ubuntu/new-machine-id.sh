#!/bin/bash

# Display the current machine IDs
echo 'Current machine-id'
echo -n '/etc/machine-id: ' && cat /etc/machine-id
echo -n '/var/lib/dbus/machine-id: ' && cat /var/lib/dbus/machine-id

# Remove the current machine IDs
sudo rm /etc/machine-id
sudo rm /var/lib/dbus/machine-id

# Regenerate the machine IDs
echo '-----'
sudo dbus-uuidgen --ensure
sudo systemd-machine-id-setup

# Display the new machine IDs
echo 'New machine-id'
echo -n '/etc/machine-id: ' && cat /etc/machine-id
echo -n '/var/lib/dbus/machine-id: ' && cat /var/lib/dbus/machine-id

echo '-----'
# Reminder for changing the hostname if needed
echo 'Change hostname: sudo hostnamectl set-hostname NEW_HOSTNAME'
echo 'Also update /etc/hosts'
