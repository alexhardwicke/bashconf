#!/bin/bash
# Clone git repos
cd ~/
git clone git@github.com:alexhardwicke/.dotfiles.git
git clone git@github.com:alexhardwicke/.vim.git

# Get vim submodules
cd ~/
cd .vim
git submodule update --init --recursive
mkdir undodir

# Set hard-links to dotfiles
cd ~/
ln ~/.dotfiles/.ackrc ~/.ackrc
ln ~/.dotfiles/.bashrc ~/.bashrc
ln ~/.dotfiles/.gvimrc ~/.gvimrc
ln ~/.dotfiles/.minttyrc ~/.minttyrc
ln ~/.dotfiles/.vimrc ~/.vimrc

ln ~/.dotfiles/.bash_profile ~/.bash_profile
ln ~/.dotfiles/.git-prompt-colors.sh ~/.git-prompt-colors.sh

# Choose appropriate gitconfig
cd ~/
ln ~/.dotfiles/.gitconfig ~/.gitconfig

# Set up AutoJump
cd ~/
git clone git@github.com:alexhardwicke/autojump.git
cd autojump
./install.py

# Manual Configuration
printf "\nMANUAL CONFIGURATION:\nAdd bashconf/keychain-2.8.1 to path\nInstall Consolas font\n\n"
