#!/bin/bash

# Check if we're running with sudo
if [ $(id -ur) -eq 0 ]; then
    printf "Please don't run as root\n"
    exit
fi

# Make sure ~/.ssh/id_rsa exists
if [ ! -f ~/.ssh/id_rsa ]; then
    printf "~/.ssh/id_rsa not found\n"
    exit
fi

# Ensure prerequisites are installed
read -n1 -p "Have you installed all prerequisites? [y,n] " prerequisites
printf "\n"
case $prerequisites in
    n|N)
        printf "sudo apt install autojump tig vim mc silversearcher-ag tig tmux\n"
        exit ;;
esac

# Check if we're running in WSL or real Linux
if grep -q Microsoft /proc/version; then
    WINDOWS=1
    read -p "Windows username? " WINDOWS_USERNAME
fi

# Copy bin
cp -r bin/ ~/

# Create needed directories
mkdir -p ~/undodir
mkdir -p ~/.tmux/plugins

# Run keychain
eval `~/bin/keychain/keychain -q --eval --agents ssh id_rsa`

# Clone git repos
fnCloneOrPull()
{
    echo "Cloning $3"

    cpwd=$(pwd)
    cd $1

    if [ -d "$2" ]; then
        cd $2
        git pull
        cd $cpwd
    else
        git clone $3 $2
    fi
}

# Clone the repos
fnCloneOrPull "$HOME" ".dotfiles/" "git@github.com:alexhardwicke/.dotfiles.git"
fnCloneOrPull "$HOME/.tmux/plugins" "tpm" "https://github.com/tmux-plugins/tpm"
fnCloneOrPull "$HOME" ".vim/" "git@github.com:alexhardwicke/.vim.git"

# Set hard-links to dotfiles
rm -f ~/.bashrc

ln ~/.dotfiles/.bashrc ~/.bashrc
ln ~/.dotfiles/.vimrc ~/.vimrc
ln ~/.dotfiles/.bash_profile ~/.bash_profile
ln ~/.dotfiles/.gitconfig ~/.gitconfig

if [ "$WINDOWS" -eq "1" ]; then
    WINDOWS_PATH="/mnt/c/Users/$WINDOWS_USERNAME"
    mkdir -p $WINDOWS_PATH/.vim
    mkdir -p $WINDOWS_PATH/AppData/Roaming/wsltty

    cp ~/.dotfiles/.gvimrc $WINDOWS_PATH/.gvimrc
    cp ~/.dotfiles/.minttyrc $WINDOWS_PATH/AppData/Roaming/wsltty/config
    cp -r .vim/* $WINDOWS_PATH/.vim/

    rm -rf ~/Desktop
    rm -rf ~/Documents
    rm -rf ~/Downloads

    ln -s $WINDOWS_PATH/Desktop ~/Desktop
    ln -s $WINDOWS_PATH/Documents ~/Documents
    ln -s $WINDOWS_PATH/Downloads ~/Downloads

    ln ~/.dotfiles/.tmux.conf ~/.tmux.conf
fi

cd ~/
