#!/bin/bash

# Directory to search
NVIDIA_DIR="$HOME/nvidia"

# Find all matching .run files
mapfile -t RUN_FILES < <(find "$NVIDIA_DIR" -maxdepth 1 -type f -name "NVIDIA-Linux-x86_64-*.run" | sort)

# Check if any files were found
if [ ${#RUN_FILES[@]} -eq 0 ]; then
  echo "No NVIDIA .run files found in $NVIDIA_DIR"
  exit 1
fi

# Display menu
echo "Found the following NVIDIA .run files:"
for i in "${!RUN_FILES[@]}"; do
  printf "%d) %s\n" "$((i + 1))" "${RUN_FILES[$i]}"
done

# User selection
while true; do
  read -rp "Enter the number of the .run file to install (1-${#RUN_FILES[@]}): " PICK
  if [[ "$PICK" =~ ^[0-9]+$ ]] && [ "$PICK" -ge 1 ] && [ "$PICK" -le "${#RUN_FILES[@]}" ]; then
    FILE="${RUN_FILES[$((PICK - 1))]}"
    break
  else
    echo "Invalid selection. Please enter a number between 1 and ${#RUN_FILES[@]}."
  fi
done

echo "Selected: $FILE"
echo "Running: sudo bash \"$FILE\" -m=kernel-open"
sudo bash "$FILE" -m=kernel-open

if [ $? -ne 0 ]; then
  echo "NVIDIA installer failed."
  exit 2
fi

echo "Updating initramfs..."
sudo update-initramfs -u

if [ $? -ne 0 ]; then
  echo "update-initramfs failed."
  exit 3
fi

echo "Installation complete. Please reboot your system for changes to take effect."
read -rp "Reboot now? (y/n): " REBOOT
if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
  sudo reboot
else
  echo "Please remember to reboot your system later."
fi
