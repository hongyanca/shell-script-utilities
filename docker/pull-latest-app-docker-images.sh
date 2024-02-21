#!/bin/bash

INSTALLED_APPS=($(ls /apps))

for i in "${INSTALLED_APPS[@]}"; do
	if [ "$i" = "README" ]; then
		continue
	fi

	echo "Pulling latest images of $i"
	cd "/apps/$i" && docker-compose pull
	echo
done
