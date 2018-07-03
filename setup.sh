#!/bin/bash

# If mac os, make sure everything's ready to go
if [[ $(uname) == Darwin ]] ;
then
    xcode-select --install 
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install coreutils vim —with-override-system-vi macvim grep openssh the_silver_searcher git tree tmux cowsay fortune htop openssh fish diff-so-fancy
    pip install --upgrade pip setuptools
fi

## TODO: Base utils for linux (ag, vim, etc. etc.)

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
        if [ $3 ]; then
            git clone $2 --config core.autocrlf=input
        else
            git clone $2
        fi
    fi
}

# Clone the repos
fnCloneOrPull ".dotfiles/" "git@github.com:alexhardwicke/.dotfiles.git" true
fnCloneOrPull ".vim/" "git@github.com:alexhardwicke/.vim.git" false
fnCloneOrPull "autojump/" "git@github.com:alexhardwicke/autojump.git" false
fnCloneOrPull "tmux-gitbar/" "https://github.com/aurelien-rainone/tmux-gitbar.git" true

# Set hard-links to dotfiles
cd ~/
rm ~/.bashrc
sudo ln ~/.dotfiles/.bashrc ~/.bashrc
sudo ln ~/.dotfiles/.gvimrc ~/.gvimrc
sudo ln ~/.dotfiles/.minttyrc ~/.minttyrc
sudo ln ~/.dotfiles/.vimrc ~/.vimrc
sudo ln ~/.dotfiles/.bash_profile ~/.bash_profile
sudo ln ~/.dotfiles/.gitconfig ~/.gitconfig
sudo ln ~/.dotfiles/.tmux.conf ~/.tmux.conf
rm ~/.tmux-gitbar.conf
sudo ln ~/.dotfiles/tmux-gitbar.conf ~/.tmux-gitbar.conf

# Set up AutoJump
cd ~/autojump
./install.py

# Copy jot and tmuxpwd
if [ ! -f ~/bin/diff-so-fancy ];
then
    if [ ! -d ~/bin/ ];
    then
        mkdir ~/bin/
    fi
    cd $cwd
    cd bin
    # Homebrew on mac
    
    cp tmuxpwd.sh ~/bin/tmuxpwd.sh
    chmod +x ~/bin/tmuxpwd.sh

    cp jot ~/bin/jot
    chmod +x ~/bin/jot
fi

cd ~/
printf "\nMANUAL CONFIGURATION:\nInstall Keybase\nInstall Consolas font (Linux variant)\n\n"
