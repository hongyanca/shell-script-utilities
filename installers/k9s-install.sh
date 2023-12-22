#!/bin/bash

Get_Github_Latest_Release_Version () {
	REPO_NAME=$1
	SAVED_WEB_PAGE=$2
	LATEST_RELEASE_VER=`cat $SAVED_WEB_PAGE | grep -B5 'Latest' | grep -Eo 'tag/.*?\d.*?"' | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+'`
	echo "$LATEST_RELEASE_VER"
}

curl -s https://github.com/derailed/k9s/releases > /tmp/k9s_release_webpage
latest_k9s_ver=`Get_Github_Latest_Release_Version 'k9s' '/tmp/k9s_release_webpage'`
latest_deb_url='https://github.com/derailed/k9s/releases/download/'$latest_k9s_ver'/k9s_linux_amd64.deb'

wget $latest_deb_url
sudo apt install ./k9s_linux_amd64.deb -y

rm k9s_linux_amd64.deb
rm -f /tmp/k9s_release_webpage
