#! /usr/bin/env bash

mkdir -p ~/.config/nvim
cp -u .bashrc .gitconfig ~/
cp -u init.lua ~/.config/nvim/
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
