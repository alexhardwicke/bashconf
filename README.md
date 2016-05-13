# bashconf
Scripts and other files to configure my bash setup.
Needs to be compatible with Windows, so there's a few oddities coming...

## Windows:
**BEFORE CLONING THIS REPO:**
Make sure the Git for Windows SDK is installed, run it via "mingw64_shell", not msys2_shell.
Pin the icon and set the shortcut icon to your terminal icon in onedrive

Then run the following:

```
echo "C:/Users /home ntfs binary,noacl,auto 1 1" >> /etc/fstab
pacman -Syu
exit
```

After that, re-open, clone bashconf and run the setup.

## Ubuntu/Debian based:
Assumes the following are installed:
vim
git
