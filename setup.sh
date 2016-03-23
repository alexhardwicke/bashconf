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
    chmod +x ~/bin/ack
fi

# Copy diff-so-fancy
if [ ! -f ~/bin/diff-so-fancy ];
then
    cd $cwd
    cd bin
    cp diff-so-fancy ~/bin/
    cp -r third_party ~/bin/
    cp -r libs ~/bin/
    chmod +x ~/bin/diff-so-fancy
    chmod +x ~/bin/libs/header_clean/header_clean.pl
    chmod +x ~/bin/third_party/diff-highlight/diff-highlight
fi

# Set up keybase
if [[ $(uname) == Linux* ]] ;
then
    curl -O https://dist.keybase.io/linux/deb/keybase-latest-amd64.deb && sudo dpkg -i keybase-latest-amd64.deb
else
    cd $cwd
    cd bin
    cp keybase.exe ~/bin/
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
    sudo apt-add-repository -y ppa:ubuntu-desktop/ubuntu-make
    sudo echo "deb http://repo.sinew.in/ stable main" > /etc/apt/sources.list.d/enpass.list
    wget -O - http://repo.sinew.in/keys/enpass-linux.key | apt-key add -
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y vim vim-gnome git-gui ubuntu-restricted-extras libcurses-perl ubuntu-make enpass
    printf "Configuring VS Code"
    umake ide visual-studio-code
    printf "Configuring Term::Animation"
    cd /tmp
    wget http://search.cpan.org/CPAN/authors/id/K/KB/KBAUCOM/Term-Animation-2.4.tar.gz
    tar -zxvf Term-Animation-2.4.tar.gz
    cd Term-Animation-2.4/
    perl Makefile.PL && make && make test
    sudo make install
    cd ~/bashconf/
    sudo cp asciiquarium /usr/local/bin
    sudo chmod 0755 /usr/local/bin/asciiquarium

    if [[ $(lsb_release -a) == *elementary* ]] ;
    then
        printf "Configuring Elementary OS"
        sudo apt-add-repository -y ppa:cybre/elementaryplus
        sudo apt-add-repository -y ppa:hourglass-team/hourglass-daily
        sudo apt-add-repository -y ppa:justsomedood/justsomeelementary
        sudo apt-get update
        sudo apt-get install -y hourglass elementaryplus elementary-tweaks plank-theme-darktheon 
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
        printf "\nMANUAL CONFIGURATION:\nUnpin calendar, music, video, photos\nChange plank theme to darktheon via Tweaks in System Settings"
    else
        uuid=$(gsettings get org.gnome.Terminal.ProfilesList default)
        uuid=`eval echo $uuid`
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$uuid/ background-color "rgb(0,43,54)"
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$uuid/ cursor-shape "ibeam"
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$uuid/ font 'Powerline Consolas 14'
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$uuid/ foreground-color "rgb(131,148,150)"
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$uuid/ palette "['rgb(7,54,66)', 'rgb(220,50,47)', 'rgb(133,153,0)', 'rgb(181,137,0)', 'rgb(38,139,210)', 'rgb(211,54,130)', 'rgb(42,161,152)', 'rgb(238,232,213)', 'rgb(0,43,54)', 'rgb(203,75,22)', 'rgb(88,110,117)', 'rgb(101,123,131)', 'rgb(131,148,150)', 'rgb(108,113,196)', 'rgb(147,161,161)', 'rgb(253,246,227)']"
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$uuid/ use-system-font false
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$uuid/ use-theme-colors false
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$uuid/ use-theme-transparency false
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$uuid/ visible-name 'Default'
        printf "\nMANUAL CONFIGURATION:\nConfigure terminal, disable bluetooth icon, register powerline linux font, configure date time format to 12 hour"
    fi
    printf "\nInstall Chrome and set it as the default web browser\nSet Language to en-GB\nDownload language pack\nSet trackpad speed\nDisable Guest\nDisable second monitor\nPin terminal, Chrome\nOpen Software & Updates (search), choose Additional Drivers, choose the most recent TESTED NVIDIA driver\n\nSSD OPTIMIZATION:\nsudo vim /etc/default/grub\nChange \"quiet splash\" to \"quiet splash elevator=noop\"\nsudo update-grub\nsudo vim /etc/fstab\nadd noatime,discard, before errors=remount on main ext4\nDownload Messenger for Desktop from http://github.com/Sytten/Facebook-Messenger-Desktop/releases\nInstall VeraCrypt\n\n"
else
    cd ~/
    git clone https://github.com/alexhardwicke/.ahk
    printf "\nMANUAL CONFIGURATION:\nInstall VeraCrypt\nAdd bashconf/keychain-2.8.1 to path\nInstall Consolas font\nAdd a shortcut to ~/.ahk/TerminalHotKey.exe to ~/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup\n\n"
fi
