#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install vim htop
sudo update-alternatives --set editor /usr/bin/vim.basic
sudo dpkg-reconfigure keyboard-configuration
sudo adduser thibault systemd-journal
bash deploy.sh
