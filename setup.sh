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
    if [ pgrep "pageant" == "" ] ;
    then
        Putty pageant must be running before continuing
    else
        eval $(/usr/bin/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME")
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
        if $3
            git clone $2 --config core.autocrlf=input
        else
            git clone $2
        fi
    fi
}

# Clone the repos
fnCloneOrPull ".dotfiles/" "git@github.com:alexhardwicke/.dotfiles.git" true
fnCloneOrPull ".vim/" "git@github.com:alexhardwicke/.vim.git" false
fnCloneOrPull "autojump" "git@github.com:alexhardwicke/autojump.git" false
fnCloneOrPull ".tmux-gitbar" "https://github.com/aurelien-rainone/tmux-gitbar.git" true

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
    sudo ln ~/.dotfiles/.bashrc ~/.bashrc
    sudo ln ~/.dotfiles/.gvimrc ~/.gvimrc
    sudo ln ~/.dotfiles/.minttyrc ~/.minttyrc
    sudo ln ~/.dotfiles/.vimrc ~/.vimrc
    sudo ln ~/.dotfiles/.bash_profile ~/.bash_profile
    sudo ln ~/.dotfiles/.gitconfig ~/.gitconfig
    sudo ln ~/.dotfiles/.tmux.conf ~/.tmux.conf
else
    ln ~/.dotfiles/.bashrc ~/.bashrc
    ln ~/.dotfiles/.gvimrc ~/.gvimrc
    ln ~/.dotfiles/.minttyrc ~/.minttyrc
    ln ~/.dotfiles/.vimrc ~/.vimrc
    ln ~/.dotfiles/.bash_profile ~/.bash_profile
    ln ~/.dotfiles/.gitconfig ~/.gitconfig
    ln ~/.dotfiles/.tmux.conf ~/.tmux.conf
fi

# Set up AutoJump
cd ~/autojump
./install.py

# Copy keychain bin file
if [[ $(uname) == MING* ]] ;
then
    if [ ! -d ~/bin/ ];
    then
        mkdir ~/bin/
    fi
    cd $cwd/bin/
    cp -r keychain/ ~/bin/keychain/
fi
# Copy ack bin file
#if [[ $(uname) == MING* ]] ;
#then
#    if [ ! -f ~/bin/ack ];
#    then
#        if [ ! -d ~/bin/ ];
#        then
#            mkdir ~/bin/
#        fi
#        cd $cwd
#        cd bin
#        cp ack ~/bin/
#        chmod +x ~/bin/ack
#    fi
#fi

# Copy diff-so-fancy and tmuxpwd
if [ ! -f ~/bin/diff-so-fancy ];
then
    if [ ! -d ~/bin/ ];
    then
        mkdir ~/bin/
    fi
    cd $cwd
    cd bin
    cp -r diff-so-fancy/ ~/bin/
    chmod +x ~/bin/diff-so-fancy/diff-so-fancy
    chmod +x ~/bin/diff-so-fancy/lib/diff-so-fancy.pl
    chmod +x ~/bin/diff-so-fancy/diff-highlight
    
    cp tmuxpwd.sh ~/bin/tmuxpwd.sh
    chmod +x ~/bin/tmuxpwd.sh
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

# Set up keybase
if [[ $(uname) == Linux* ]] ;
then
    sudo apt-get update
    sudo apt-get install -y curl
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
    sudo add-apt-repository -y ppa:n-muench/burg
    sudo apt-add-repository -y ppa:ubuntu-desktop/ubuntu-make
    sudo sh -c 'echo "deb http://repo.sinew.in/ stable main" >> /etc/apt/sources.list.d/enpass.list'
    wget -O - http://repo.sinew.in/keys/enpass-linux.key | sudo apt-key add -
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt-get update
    sudo apt-get upgrade -y
    printf "Add elevator=noop to quiet splash when asked by burg\nAnd select /dev/sda with spacebar when asked by grub\n"
    read -n1 -r -p "Press any key to continue..."
    sudo apt-get install -y vim vim-gnome git-gui ubuntu-restricted-extras libcurses-perl enpass ack-grep google-chrome-stable burg burg-themes cowsay fortune
    printf "Adding burg theme"
    cd $cwd
    cd burg-theme
    sudo cp -r Darkness_Blue/ /boot/burg/themes/
    sudo update-grub
    sudo burg-install
    sudo update-burg
    printf "Configuring Term::Animation"
    cd /tmp
    wget http://search.cpan.org/CPAN/authors/id/K/KB/KBAUCOM/Term-Animation-2.4.tar.gz
    tar -zxvf Term-Animation-2.4.tar.gz
    cd Term-Animation-2.4/
    perl Makefile.PL && make && make test
    sudo make install
    cd ~/bashconf/
    sudo cp bin/asciiquarium /usr/local/bin
    sudo chmod 0755 /usr/local/bin/asciiquarium
    mkdir -p ~/.local/share/fonts/
    cp ~/bashconf/fonts/PowerlineConsolasLinux.ttf ~/.local/share/fonts/

    if [[ $(lsb_release -a) == *elementary* ]] ;
    then
        printf "Configuring Elementary OS"
        sudo apt-add-repository -y ppa:cybre/elementaryplus
        sudo apt-add-repository -y ppa:hourglass-team/hourglass-daily
        sudo apt-add-repository -y ppa:justsomedood/justsomeelementary
        sudo apt-get update
        sudo apt-get install -y hourglass elementaryplus elementary-tweaks plank-theme-darktheon 
        gsettings set org.pantheon.terminal.settings cursor-shape 'I-Beam'
        gsettings set org.pantheon.terminal.settings background '#002B36'
        gsettings set org.pantheon.terminal.settings cursor-color '#DC322F'
        gsettings set org.pantheon.terminal.settings foreground '#839496'
        gsettings set org.pantheon.terminal.settings opacity '100'
        gsettings set org.gnome.desktop.interface monospace-font-name 'Powerline Consolas 15'
        gsettings set com.canonical.indicator.datetime time-format '12-hour'
        gsettings set com.canonical.indicator.bluetooth visible false
        printf "\nMANUAL CONFIGURATION:\nUnpin calendar, music, video, photos\nDownload language pack\nDisable Guest\nChange plank theme to darktheon via Tweaks in System Settings"
    else
        sudo apt-add-repository -y ppa:numix/ppa
        sudo apt-get update
        sudo apt-get install -y numix-icon-theme-circle
        sudo apt-get remove gnome-maps gnome-weather deja-dup gnome-mines gnome-sudoku gnome-mahjongg aisleriot libreoffice-draw gnome-photos firefox xul-ext-ubufox transmission-gtk empathy libreoffice-calc libreoffice-math libreoffice-writer cheese rhythmbox usb-creator-gtk gnome-orca geoclue-2.0
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
        printf "\nMANUAL CONFIGURATION:\nConfigure terminal, disable bluetooth icon, register powerline linux font, configure date time format to 12 hour\nSettings->Keyboard->Shortcuts->Launchers->Launch terminal, change to win+t\nTweaks:\nAppearance: GTK+ Numix Dark, Icons Numix Circle\nFonts: Monospace, Powerline Consolas Regular 14\nTop Bar: Show date, Show Week Numbers\nWindows: Enable Maximize and Minimize\nDownload numix dark from https://numixproject.org/, extract to /usr/share/themes/"
    fi
    printf "\nSet Chrome as Default Browser (Settings->Details->Default Applications)\nSet timezone to Stockholm\nSet trackpad speed\nDisable second monitor\nPin terminal, Chrome\nOpen Software & Updates (search), choose Additional Drivers, choose the most recent TESTED NVIDIA driver\n\nSSD OPTIMIZATION:\nsudo vim /etc/fstab\nadd noatime,discard, before errors=remount on main ext4\nDownload Messenger for Desktop from http://github.com/Sytten/Facebook-Messenger-Desktop/releases\nRun sudo burg-emu and select Darkness Blue\nRun sudo vim /etc/default/burg, set GRUB_GFXMODE=1366x768 and uncomment GRUB_DISABLE_LINUX_RECOVERY, then run sudo update-burg\n\n"
else
    cd ~/
    printf "\nMANUAL CONFIGURATION:\nInstall Consolas font\nReplace ssh and vim exes in git-for-windows with ones from cygwin\nDownload and install PSTrayFactory from PSSoftLab if you want to hide icons (e.g. pageant)\n\n"
fi
