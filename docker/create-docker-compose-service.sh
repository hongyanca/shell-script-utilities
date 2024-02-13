#!/bin/bash
# Create a systemd service that autostarts & manages a docker-compose instance in the current directory
# by Uli Köhler - https://techoverflow.net
# https://techoverflow.net/2020/10/24/create-a-systemd-service-for-your-docker-compose-project-in-10-seconds/
# Licensed as CC0 1.0 Universal
SERVICENAME=$(basename $(pwd))

echo "Creating systemd service... /etc/systemd/system/${SERVICENAME}.service"
# Create systemd service file
cat >/tmp/$SERVICENAME.service <<EOF
[Unit]
Description=$SERVICENAME
Requires=docker.service
After=docker.service
[Service]
Restart=always
User=root
Group=docker
WorkingDirectory=$(pwd)
# Shutdown container (if running) when unit is started
ExecStartPre=$(which docker-compose) -f docker-compose.yml down
# Start container when unit is started
ExecStart=$(which docker-compose) -f docker-compose.yml up
# Stop container when unit is stopped
ExecStop=$(which docker-compose) -f docker-compose.yml down
[Install]
WantedBy=multi-user.target
EOF

sudo cp /tmp/$SERVICENAME.service /etc/systemd/system/$SERVICENAME.service
sudo rm -f /tmp/$SERVICENAME.service

echo "Enabling & starting $SERVICENAME"
# Autostart systemd service
sudo systemctl enable $SERVICENAME.service
# Start systemd service now
sudo systemctl start $SERVICENAME.service
