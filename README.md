# bashconf
Scripts and other files to configure my bash setup.
Needs to be compatible with Windows, so there's a few oddities coming...

Assumes the following are installed for cygwin:
git (from git-for-windows - the one in cygwin is too slow)
tmux
silver searcher (ag)
vim
dos2unix
python (2)
procps

Also assumes a .gitconfig with autocrlf set to input (or false).

To get things to work properly, you need to copy cygwin's vim and less executables to %programfiles%/Git/usr/bin/

Without them, vim will fail when executed from git (e.g. commit, interactive rebase), and less won't page as it's not aware of the terminal size.

Assumes the following are installed for ubuntu-based:
vim
git
