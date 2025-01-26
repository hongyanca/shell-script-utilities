#!/usr/bin/env bash
sudo dnf remove "$(sudo dnf repoquery --installonly --latest-limit=-1)"

sudo grub2-mkconfig -o /boot/grub2/grub.cfg

echo "Remove the following boot loader entries:"
sudo ls /boot/loader/entries/ | grep -v "$(uname -r)"
