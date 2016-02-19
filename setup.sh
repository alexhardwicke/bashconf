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
    curl -O https://dist.keybase.io/linux/deb/keybase-latest-amd64.deb && sudo dpkg -i keybase-latest-amd64.deb
    sudo apt-add-repository -y ppa:cybre/elementaryplus
    sudo apt-add-repository -y ppa:hourglass-team/hourglass-daily
    sudo apt-add-repository -y ppa:justsomedood/justsomeelementary
    sudo apt-get update
    sudp apt-get upgrade -y
    sudo apt-get install -y vim vim-gnome git-gui hourglass elementaryplus ubuntu-restricted-extras elementary-tweaks plank-theme-darktheon
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
    gsettings set com.canonical.indicator.bluetooth visible false
    printf "\nMANUAL CONFIGURATION:\nInstall Chrome and set it as the default web browser\nSet Language to en-GB\nDownload language pack\nSet trackpad speed\nDisable Guest\nDisable second monitor\nUnpin calendar, music, video, photos\nPin terminal, Chrome\nOpen Software & Updates (search), choose Additional Drivers, choose the most recent TESTED NVIDIA driver\nChange plank theme to darktheon via Tweaks in System Settings\n\nSSD OPTIMIZATION:\nsudo vim /etc/default/grub\nChange \"quiet splash\" to \"quiet splash elevator=noop\"\nsudo update-grub\nsudo vim /etc/fstab\nadd noatime,discard, before errors=remount on main ext4\n\n"
else
    printf "\nMANUAL CONFIGURATION:\nAdd bashconf/keychain-2.8.1 to path\nInstall Consolas font\n\n"
fi
