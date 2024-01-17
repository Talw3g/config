#! /usr/bin/env bash

cd /home/thibault
cp -ur .bashrc .gitconfig .config/pycodestyle config/
cd config/
git add . && git commit
