#!/bin/bash

# If mac os, install brew
if [[ $(uname) == Darwin ]] ;
then
    xcode-select --install
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install coreutils vim —with-override-system-vi macvim grep openssh the_silver_searcher git tree tmux cowsay fortune htop openssh fish diff-so-fancy
    pip install --upgrade pip setuptools
else
    ## TODO: Base utils for linux (ag, vim, etc. etc.)
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

# Set hard-links to dotfiles
rm ~/.bashrc

# TODO: Input based instead of assuming not mac os == server?
if [[ $(uname) == Darwin ]] ;
then
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

cd ~/autojump
./install.py

if [ ! -d ~/bin/ ];
then
    mkdir ~/bin/
fi

cd $cwd
cd bin

cp tmuxpwd.sh ~/bin/tmuxpwd.sh
chmod +x ~/bin/tmuxpwd.sh

cd $cwd
