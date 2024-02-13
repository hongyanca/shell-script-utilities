#!/bin/bash
DC_LOCATION=$(which docker-compose)
if [ -z "$DC_LOCATION" ]; then
	DC_LOCATION='/usr/bin/docker-compose'
else
	echo docker-compose found at $DC_LOCATION
	echo 'Deleting docker-compose'
	sudo rm $DC_LOCATION
fi
DC_REPO=$(curl -s https://docs.docker.com/compose/install/linux/#install-using-the-repository | grep -A20 'Install the plugin manually' | grep -Eo 'https://github.com.*?compose-linux.x86_64')

echo 'Downloading latest docker-compose'
sudo curl -SL $DC_REPO -o $DC_LOCATION
sudo chmod +x $DC_LOCATION

$DC_LOCATION version
