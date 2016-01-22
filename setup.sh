#!/bin/bash

# If windows, make sure everything's ready to go
if [[ $(uname) == MING* ]] ;
then
    # If the file exists, delete it
    if [ -f "C:/Windows/bashadmin.ext" ]; then
        result=$(rm C:/Windows/bashadmin.ext 2>&1)
        # If we managed to delete it, we'll recreate it, because if we
        # created the file previously, we own it and have the right to
        # delete it
        if [ -z "$result" ] ;
        then
            result=$(touch C:/Windows/bashadmin.ext 2>&1)
        fi
    else
        # File doesn't exist, just create it
        result=$(touch C:/Windows/bashadmin.ext 2>&1)
    fi

    # If we've got no result, it all worked, we're admin
    if [ -z "$result" ] ;
    then
        echo "Exporting winsymlinks"
        export CYGWIN="winsymlinks:native"
    else
        echo "This needs to be run as admin on Windows. Exiting."
        exit 1
    fi
fi

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

# Clone the repos
fnCloneOrPull ".dotfiles/" "git@github.com:alexhardwicke/.dotfiles.git"
fnCloneOrPull "bash-git-prompt/" "https://github.com/magicmonty/bash-git-prompt.git"
fnCloneOrPull ".vim/" "git@github.com:alexhardwicke/.vim.git"
fnCloneOrPull "autojump" "git@github.com:alexhardwicke/autojump.git"

# Get vim submodules
cd ~/
cd .vim
git submodule update --init --recursive

if [ ! -d undodir ];
then
    mkdir undodir
fi

# Set hard-links to dotfiles
cd ~/
if [[ $(uname) == Linux* ]] ;
then
    rm ~/.bashrc
    sudo ln ~/.dotfiles/.ackrc ~/.ackrc
    sudo ln ~/.dotfiles/.bashrc ~/.bashrc
    sudo ln ~/.dotfiles/.gvimrc ~/.gvimrc
    sudo ln ~/.dotfiles/.minttyrc ~/.minttyrc
    sudo ln ~/.dotfiles/.vimrc ~/.vimrc
    sudo ln ~/.dotfiles/.bash_profile ~/.bash_profile
    sudo ln ~/.dotfiles/.git-prompt-colors.sh ~/.git-prompt-colors.sh
    sudo ln ~/.dotfiles/.gitconfig ~/.gitconfig
else
    ln ~/.dotfiles/.ackrc ~/.ackrc
    ln ~/.dotfiles/.bashrc ~/.bashrc
    ln ~/.dotfiles/.gvimrc ~/.gvimrc
    ln ~/.dotfiles/.minttyrc ~/.minttyrc
    ln ~/.dotfiles/.vimrc ~/.vimrc
    ln ~/.dotfiles/.bash_profile ~/.bash_profile
    ln ~/.dotfiles/.git-prompt-colors.sh ~/.git-prompt-colors.sh
    ln ~/.dotfiles/.gitconfig ~/.gitconfig
fi

# Set up AutoJump
cd ~/autojump
./install.py

# Copy ack bin file
if [ ! -f ~/bin/ack ];
then
    if [ ! -d ~/bin/ ];
    then
        mkdir ~/bin/
    fi
    cd $cwd
    cd bin
    cp ack ~/bin/
fi

# Set up pygment
cd $cwd
cd bin

if [[ $(uname) == Linux* ]] ;
then
    sudo -H python get-pip.py
    sudo -H pip install Pygments-2.0.2-py2-none-any.whl
else
    python get-pip.py
    pip.exe install Pygments-2.0.2-py2-none-any.whl
fi

if [[ $(uname) == Linux* ]] ;
then
    printf "Installing Software"
    sudo apt-get install vim
    sudo apt-get install vim-gnome
    sudo apt-get install git-gui
    printf "Configuring Elementary OS"
    mkdir -p ~/.local/share/fonts/
    cp ~/bashconf/fonts/PowerlineConsolasLinux.ttf ~/.local/share/fonts/
    gsettings set org.pantheon.terminal.settings cursor-shape 'I-Beam'
    gsettings set org.pantheon.terminal.settings background '#002B36'
    gsettings set org.pantheon.terminal.settings cursor-color '#DC322F'
    gsettings set org.pantheon.terminal.settings foreground '#839496'
    gsettings set org.pantheon.terminal.settings opacity '100'
    gsettings set org.gnome.desktop.interface monospace-font-name 'Powerline Consolas 15'
    gsettings set com.canonical.indicator.datetime time-format '12-hour'
    printf "\nMANUAL CONFIGURATION:\nSet default web browser to Firefox\nSet Language to en-GB\nDownload language pack\nSet trackpad speed\nDisable Guest\nDisable second monitor\nUnpin calendar, music, video, photos\nPin terminal, firefox\n\n"
else
    printf "\nMANUAL CONFIGURATION:\nAdd bashconf/keychain-2.8.1 to path\nInstall Consolas font\n\n"
fi
