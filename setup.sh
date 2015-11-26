#!/bin/bash

# Save current path
cwd=$(pwd)

# Clone git repos
fnCloneOrPull()
{
    cd ~/
    if [ -d "$1" ]; then
        cd $1
        git pull
    else
        git clone $2
    fi
}

fnCloneOrPull ".dotfiles/" "git@github.com:alexhardwicke/.dotfiles.git"
fnCloneOrPull "bash-git-prompt/" "https://github.com/magicmonty/bash-git-prompt.git"
fnCloneOrPull ".vim/" "git@github.com:alexhardwicke/.vim.git"

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

# Copy ack bin file
cd ~/
mkdir bin
cd $cwd
cd bin
copy ack ~/bin/

# Manual Configuration
printf "\nMANUAL CONFIGURATION:\nAdd bashconf/keychain-2.8.1 to path\nInstall Consolas font\n\n"
