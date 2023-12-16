#!/bin/bash

# Convert cloudflared tunnel JWT token to credentials.json

# Check if a token is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <jwt-token>"
    exit 1
fi

TOKEN=$1

# Split the token into its components
HEADER=$(echo $TOKEN | awk -F"." '{print $1}')

# Base64 decode function that works with both GNU and BSD base64 variants
decode_base64() {
    echo "$1" | tr '_-' '/+' | tr -d '\n' | base64 -d 2>/dev/null || echo "$1" | tr '_-' '/+' | tr -d '\n' | base64 -di 2>/dev/null
}

# Decode header part, replace specific keys, and pretty print
DECODED_HEADER=$(decode_base64 $HEADER | jq .)
echo $DECODED_HEADER | jq 'with_entries(if .key == "a" then .key = "AccountTag" elif .key == "t" then .key = "TunnelID" elif .key == "s" then .key = "TunnelSecret" else . end)'
