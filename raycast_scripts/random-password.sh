#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Generate Random Password
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔑

# Documentation:
# @raycast.description Generate Random Password Using pwgen
# @raycast.author Hong

export RANDOM_PWD=$(openssl rand -base64 40 | sed 's/[a-m]/-/2; s/[N-Z]/$/2; s/\//!/g; s/[|O]/@/g; s/[Il]/*/g' | head -c 20)
echo "$RANDOM_PWD has been copied to clipboard"
echo -n $RANDOM_PWD | pbcopy
export RANDOM_PWD=''