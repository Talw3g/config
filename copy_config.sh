#! /usr/bin/env bash

cd /home/thibault
cp -ur .bashrc .gitconfig .config/nvim/init.lua .config/nvim/ftplugin config/
cd config/
git add . && git commit
