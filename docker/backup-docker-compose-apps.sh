#!/bin/bash

INSTALLED_APPS=($(ls /apps))
BACKUP_LOC=REPALCE_WITH_YOUR_BACKUP_DIRECTORY

for i in ${INSTALLED_APPS[@]}; do
	if [[ $i == 'README' ]]; then
		echo 'Skip README folder backup' && echo
		continue
	fi
	echo 'Stopping service '$i
	sudo systemctl stop $i
	echo 'Backing up '$i
	sudo tar -zcf $BACKUP_LOC/$(hostname)-$(date "+%Y%m%d-%H%M")-$i.tar.gz /apps/$i
	echo 'Starting service '$i
	sudo systemctl start $i
	sleep 1
	echo 'Checking status of service '$i
	sudo systemctl status $i | grep -m1 -A2 $i
	echo
done

echo 'Deleting backup files older than 2 days'
sudo find $BACKUP_LOC -name $(hostname)'*.tar.gz' -type f -mtime +2 -delete
