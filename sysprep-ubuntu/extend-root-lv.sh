#!/bin/bash

# Please remember, modifying disk partitions can be risky and may result in data loss.
# Always ensure that you have a backup of your important data before proceeding with
# such operations. Additionally, ensure that /dev/sda is indeed the disk you want to
# modify, as this script will apply changes directly to it.

# Move secondary GPT header to end of disk
# https://superuser.com/questions/660309/live-resize-of-a-gpt-partition-on-linux/1156509#1156509
sudo sgdisk -e /dev/sda

# Find the last partition number of /dev/sda
last_part=$(sudo parted /dev/sda -ms unit MB print | tail -n +3 | cut -d':' -f1 | sort -nr | head -n1)

# Calculate the number for the new partition
new_part_num=$((last_part + 1))

# Get the end of the last partition in MB
end_of_last_part=$(sudo parted /dev/sda -ms unit MB print | grep "^${last_part}:" | cut -d':' -f3 | sed 's/MB//')
end_of_last_part=$((end_of_last_part + 1))

read -p "Are you sure you want to create a new partition (/dev/sda${new_part_num}) starting at ${end_of_last_part}MB? [y/N]: " confirmation
confirmation=${confirmation:-N} # Set default value to 'N'

if [[ $confirmation =~ ^[Yy]$ ]]; then
    # If confirmation is 'yes', proceed with creating the new partition
    echo "Creating a new partition (/dev/sda${new_part_num}) starting at ${end_of_last_part}MB"
    sudo parted /dev/sda --script mkpart primary ext4 "${end_of_last_part}MB" 100%
    echo "New partition (/dev/sda${new_part_num}) created successfully."
else
    # If confirmation is 'no', exit the script
    echo "Partition creation cancelled."
fi

# Create a physical volume
echo 'Create physical volume'
# Initializes a physical volume for use by LVM. Here, /dev/sda4 is the newly created partition.
sudo pvcreate /dev/sda${new_part_num}

# Extend the volume group
echo 'Extend volume group'
# Display information about all volume groups before extending.
sudo vgs
echo '-----'
# Adds the new physical volume to the volume group 'ubuntu-vg'.
sudo vgextend ubuntu-vg /dev/sda${new_part_num}
echo '-----'
# Display information about all volume groups after extending.
sudo vgs
echo '-----'
# Show detailed information about all volume groups.
sudo vgdisplay

echo 'Resize logical volume'
# Extends the logical volume 'ubuntu-lv' to use all free space in the volume group.
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
# Show updated detailed information about volume groups.
sudo vgdisplay

# Resize the filesystem
echo 'Resize the filesystem'
# Resize the file system on the logical volume to occupy all the available space in the logical volume.
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
# Display disk space usage to confirm the resize operation.
df -h