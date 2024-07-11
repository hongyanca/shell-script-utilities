#!/bin/bash
sudo apt-get clean
sudo cloud-init clean
sudo rm -rf /root/.bash_history
function erase_history { local HISTSIZE=0; }
erase_history && echo '' >~/.bash_history && erase_history
sudo shutdown -h now
