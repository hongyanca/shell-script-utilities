#!/bin/bash

INSTALLED_APPS=(`ls /apps`)

for i in ${INSTALLED_APPS[@]}
do
    echo 'Pulling latest images of '$i
    cd /apps/$i && docker-compose pull
    echo
done
