# bashconf
Scripts and other files to configure my bash setup.
Needs to be compatible with Windows, so there's a few oddities coming...

## Windows:
**BEFORE CLONING THIS REPO:**
Make sure Msys2 is installed
Open and run:

```
echo "C:/Users /home ntfs binary,noacl,auto 1 1" >> /etc/fstab
git config --global core.autocrlf input
exit
```

After that, re-open, clone bashconf and run the setup.

## Ubuntu/Debian based:
Assumes the following are installed:
vim
git
