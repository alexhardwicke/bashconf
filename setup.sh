#!/bin/bash

# If windows, make sure everything's ready to go
if [[ $(uname) == MSYS* ]] ;
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
    pacman -S --noconfirm vim git tmux openssh procps ssh-pageant-git mingw-w64-x86_64-tk mingw-w64-x86_64-ag screenfetch make mingw-w64-x86_64-jq mingw-w64-x86_64-oniguruma
# If mac os, install brew
elif [[ $(uname) == Darwin ]] ;
then
    xcode-select --install
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install coreutils vim —with-override-system-vi macvim grep openssh the_silver_searcher git tree tmux cowsay fortune htop openssh fish diff-so-fancy
    pip install --upgrade pip setuptools
    ## TODO: Base utils for linux in else (ag, vim, etc. etc.)
fi

# Save current path
cwd=$(pwd)

# Clone git repos
fnCloneOrPull()
{
    if [ -d "$1" ]; then
        cpwd=$(pwd)
        cd $1
        git pull
        cd $cpwd
    else
        git clone $2
    fi
}

cd ~/

# Clone the repos
fnCloneOrPull ".dotfiles/" "git@github.com:alexhardwicke/.dotfiles.git"
fnCloneOrPull ".vim/" "git@github.com:alexhardwicke/.vim.git"
fnCloneOrPull "autojump/" "git@github.com:alexhardwicke/autojump.git"
fnCloneOrPull ".tmux-gitbar/" "https://github.com/aurelien-rainone/tmux-gitbar.git"

cd ~/
if [ ! -d undodir ];
then
    mkdir undodir
fi

# Set hard-links to dotfiles
rm ~/.bashrc

if [ ! -d ~/.tmux/ ];
then
    mkdir ~/.tmux/
fi

if [ ! -d ~/.tmux/plugins/ ];
then
    mkdir ~/.tmux/plugins/
fi

cd ~/.tmux/plugins/

fnCloneOrPull "tpm" "https://github.com/tmux-plugins/tpm"

if [[ $(uname) == MSYS* ]] ;
then
    ln ~/.dotfiles/.bashrc_client ~/.bashrc
    ln ~/.dotfiles/.gvimrc ~/.gvimrc
    ln ~/.dotfiles/.minttyrc ~/.minttyrc
    ln ~/.dotfiles/.vimrc ~/.vimrc
    ln ~/.dotfiles/.bash_profile ~/.bash_profile
    ln ~/.dotfiles/.gitconfig ~/.gitconfig
    ln ~/.dotfiles/.tmux.conf ~/.tmux.conf
    rm ~/.tmux-gitbar.conf
    ln ~/.dotfiles/tmux-gitbar.conf ~/.tmux-gitbar.conf
else
    if [[ $(uname) == Darwin ]] ;
    then
        sudo ln ~/.dotfiles/.bashrc_client ~/.bashrc
        sudo ln ~/.dotfiles/.gvimrc ~/.gvimrc
        sudo ln ~/.dotfiles/.tmux.conf ~/.tmux.conf
        rm ~/.tmux-gitbar.conf
        sudo ln ~/.dotfiles/tmux-gitbar.conf ~/.tmux-gitbar.conf
    else
        sudo ln ~/.dotfiles/.bashrc_server ~/.bashrc
    fi

    sudo ln ~/.dotfiles/.vimrc ~/.vimrc
    sudo ln ~/.dotfiles/.bash_profile ~/.bash_profile
    sudo ln ~/.dotfiles/.gitconfig ~/.gitconfig
fi


cd ~/autojump
./install.py

if [[ $(uname) == MING* ]] ;
then
    if [ ! -d ~/bin/ ];
    then
        mkdir ~/bin/
    fi
    cd $cwd/bin/
    cp -r keychain/ ~/bin/keychain/
fi

# Set up cowsay
if [[ $(uname) == MSYS* ]] ;
then
    if [ ! -d ~/bin/cowsay/ ];
    then
        if [ ! -d ~/bin/ ];
        then
            mkdir ~/bin/
        fi
        cd ~/bin/
        git clone https://github.com/schacon/cowsay
        cd cowsay
        ./install.sh
    fi
fi

 # Set up fortune
if [[ $(uname) == MSYS* ]] ;
then
    cd $cwd
    cd bin
    pacman -U fortune-mod-9708-1-x86_64.pkg.tar.xz
fi

if [ ! -d ~/bin/ ];
then
    mkdir ~/bin/
fi

cd $cwd
cd bin

cp tmuxpwd.sh ~/bin/tmuxpwd.sh
chmod +x ~/bin/tmuxpwd.sh

cd $cwd
