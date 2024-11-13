#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Ramdisk Folder
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📂

# Documentation:
# @raycast.description Open Ramdisk Folder
# @raycast.author Hong

# Check if /Volumes/RAM-Disk exists
if [ -d "/Volumes/RAM-Disk" ]; then
    # If the folder exists, do nothing
    :
else
    # If the folder is absent, create a new RAM disk
    /usr/local/user_scripts/ramdisk.sh
    # diskutil erasevolume HFS+ 'RAM-Disk' "$(hdiutil attach -nobrowse -nomount ram://50331648)"
fi

# open -a Finder "/Volumes/RAM-Disk"
osascript -e 'tell application "Finder" to make new Finder window to POSIX file "/Volumes/RAM-Disk"' >/dev/null 2>&1
osascript -e 'tell application "Finder" to set current view of Finder window 1 to list view' >/dev/null 2>&1
