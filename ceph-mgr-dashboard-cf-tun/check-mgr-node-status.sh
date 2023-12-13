#!/bin/bash

# Make the curl request and store the HTTP status code in a variable
status_code=$(curl -k -s -o /dev/null -w "%{http_code}" https://127.0.0.1:8443)

# Check if this node is the standby node by checking the http status code
if [ "$status_code" -eq 303 ]; then
    # Perform your tasks here
    echo "This node is the standby ceph manager node."
    echo "Stopping the access to this dashboard endpoint."
    sudo systemctl stop caddy-ceph-dashboard.service
else
    echo "This node is the active ceph manager node."
    # Check if the service is active
    if systemctl is-active --quiet caddy-ceph-dashboard.service; then
        echo "caddy-ceph-dashboard.service is already active"
    else
    # Start the service
        sudo systemctl start caddy-ceph-dashboard.service
        sleep 3
    fi
fi

sudo systemctl status caddy-ceph-dashboard.service | grep -A2 Loaded
