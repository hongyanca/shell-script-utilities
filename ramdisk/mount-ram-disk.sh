#!/usr/bin/env bash

MOUNT_POINT="/Volumes/RAM-Disk"

# Check if tmpfs is already mounted
if mount | grep "on $MOUNT_POINT type tmpfs" >/dev/null; then
  echo "RAM disk is already mounted at $MOUNT_POINT."
  exit 0
fi

# Remove existing directory and create a fresh mount point
sudo rm -rf "$MOUNT_POINT"
sudo mkdir -p "$MOUNT_POINT"

# Mount tmpfs with 4GB size
sudo mount -t tmpfs -o size=4G tmpfs "$MOUNT_POINT"

# Change ownership to the current user
USER_GRP="$(id -un):$(id -gn)"
sudo chown -R $USER_GRP "$MOUNT_POINT"

echo "RAM disk mounted successfully at $MOUNT_POINT"
