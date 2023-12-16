#! /usr/bin/env bash

cd /home/thibault
cp -u .bashrc .gitconfig .config/nvim/init.lua config/
cd config/
git add . && git commit
