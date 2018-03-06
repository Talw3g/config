#! /usr/bin/env bash

cd /home/thibault
tar -czvf config/vim.tar.gz .vim/
cp -u .bashrc .gitconfig .vimrc config/
cd config/
git add . && git commit
