#!/bin/bash

# Check if we're running with sudo
if [ $(id -ur) -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Make sure ~/.ssh/id_rsa exists
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "~/.ssh/id_rsa not found"
    return
fi

# Check if we're running in WSL or real Linux
if grep -q Microsoft /proc/version; then
    WINDOWS=1
    read -n1 -p "Windows username?" WINDOWS_USERNAME
    LINUX="CLIENT"
else
    WINDOWS=0
    read -n1 -p "Client install? (tmux) [y,n]" isclient
    case $isclient in
        y|Y) LINUX="CLIENT" ;;
        n|N) LINUX="SERVER" ;;
        *) return ;;
    esac
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
    cpwd=$(pwd)
    cd $1

    if [ -d "$2" ]; then
        cd $2
        git pull
        cd $cpwd
    else
        git clone $2 $3
    fi
}

# Clone the repos
fnCloneOrPull "~/" ".dotfiles/" "git@github.com:alexhardwicke/.dotfiles.git"
fnCloneOrPull "~/" "autojump/" "git@github.com:alexhardwicke/autojump.git"
fnCloneOrPull "~/.tmux/plugins" "tpm" "https://github.com/tmux-plugins/tpm"

sudo ln ~/.dotfiles/.dir_colors ~/.dir_colors
sudo ln ~/.dotfiles/.vimrc ~/.vimrc
sudo ln ~/.dotfiles/.bash_profile ~/.bash_profile
sudo ln ~/.dotfiles/.gitconfig ~/.gitconfig

# Set hard-links to dotfiles
rm ~/.bashrc

if [ "$WINDOWS" -eq "1" ]; then
    WINDOWS_PATH="/mnt/c/Users/$WINDOWS_USERNAME"
    cp ~/.dotfiles/.gvimrc $WINDOWS_PATH/.gvimrc
    cp ~/.dotfiles/.minttyrc $WINDOWS_PATH/.minttyrc
    fnCloneOrPull $WINDOWS_PATH ".vim/" "git@github.com:alexhardwicke/.vim.git"
    if [ ! -d "~/.vim" ]; then
        sudo ln -s ~/.vim $WINDOWS_PATH/.vim
    fi
else
    fnCloneOrPull "~/" ".vim/" "git@github.com:alexhardwicke/.vim.git"
fi

if [ "$LINUX" -eq "CLIENT" ]; then
    sudo ln ~/.dotfiles/.bashrc_client ~/.bashrc
    sudo ln ~/.dotfiles/.tmux.conf ~/.tmux.conf
elif [ "$LINUX" -eq "SERVER" ]; then
    sudo ln ~/.dotfiles/.bashrc_session ~/.bashrc
else
    echo "Unrecognized system"
    return
fi

cd ~/autojump
./install.py

cd ~/
