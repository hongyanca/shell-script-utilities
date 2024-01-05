#!/bin/bash

DOCKER_LOC="/var/lib/docker"

sudo docker builder prune --all --force
sudo docker system prune --all --volumes --force

echo "Removing container logs..."
sudo find $DOCKER_LOC/containers/ -type f -name "*.log" -delete

# Check for dangling Docker volumes
dangling_volumes=$(docker volume ls -qf dangling=true)

# If there are dangling volumes, remove them
if [ ! -z "$dangling_volumes" ]; then
    echo "Removing dangling Docker volumes..."
    sudo docker volume rm $dangling_volumes
else
    echo "No dangling Docker volumes found."
fi
