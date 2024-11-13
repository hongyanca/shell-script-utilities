#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Download Folder
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📂

# Documentation:
# @raycast.description Open Download Folder
# @raycast.author Hong

# open "/Users/yanh/Downloads"
osascript -e 'tell application "Finder" to make new Finder window to POSIX file "/Users/yanh/Downloads"' > /dev/null 2>&1
