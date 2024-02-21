#!/bin/bash
sudo cloud-init clean
history -c && echo '' >~/.bash_history
sudo shutdown -h now
