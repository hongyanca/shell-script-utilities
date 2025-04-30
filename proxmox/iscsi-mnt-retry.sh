#!/usr/bin/env bash

MOUNT_POINT="/mnt/pve/iscsi"
DEVICE="/dev/iscsi-vg/iscsi-lv"
MAX_RETRIES=20
RETRY_DELAY=15

# Function to check iSCSI sessions
check_iscsi_sessions() {
  echo "Checking for active iSCSI sessions..."
  sudo iscsiadm -m session >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

# Function to attempt mounting
attempt_mount() {
  echo "Attempting to mount $DEVICE to $MOUNT_POINT..."
  sudo mount "$DEVICE" "$MOUNT_POINT"
  if [ $? -eq 0 ]; then
    echo "Mount successful!"
    return 0
  else
    echo "Mount failed."
    return 1
  fi
}

# Main logic
for ((i = 1; i <= MAX_RETRIES; i++)); do
  echo "Attempt #$i of $MAX_RETRIES..."

  # Check for active iSCSI sessions
  check_iscsi_sessions
  if [ $? -eq 0 ]; then
    # If sessions are active, attempt to mount
    attempt_mount
    if [ $? -eq 0 ]; then
      exit 0 # Exit successfully if mount succeeds
    else
      echo "Mount failed despite active iSCSI sessions."
      exit 1
    fi
  fi

  # If no sessions are found, wait and retry
  if [ $i -lt $MAX_RETRIES ]; then
    echo "Retrying in $RETRY_DELAY seconds..."
    sleep $RETRY_DELAY
  fi
done

# If all attempts fail
echo "All $MAX_RETRIES attempts to mount $DEVICE to $MOUNT_POINT have failed."
exit 1
