# archlinux-auto-install
Automatic installation of Archlinux for vagrants and physical hosts.

This project install minimal Archlinux from scratch, other packages and configuration are done with **ansible**



Image contains :
- Archlinux 2021.04.01
- Encrypted LUKS disk (for vagrant, the password is `vagrant`)
- btrfs partitions with sub volumes
- `grub` and `grub-theme`
- `networkmanager`
- `yay` package (for installaling AUR packages)
- `git` for clonning some project (ex: [ansible-archlinux](https://github.com/badele/ansible-archlinux))
- `ansible` (for customize automatically your installation)

## Vagrant
```
# From vagrant cloud
vagrant init badele/ansiblearch && vagrant up

# From github
packer build -var-file config.pkrvars.hcl packer.pkr.hcl
vagrant box add --force ansiblearch file://./box/ansiblearch-virtualbox.box
vagrant up

# Push to vagrant cloud
#vagrant cloud auth login
ARCHVERSION=$(pcregrep -o1 'arch_version.*"(.*)"' config.pkrvars.hcl)
vagrant cloud publish badele/ansiblearch ${ARCHVERSION} virtualbox box/ansiblearch-virtualbox.box
# -d "A LUKS+BTRFS archlinux installation with ansible support"
```

## Host
From booted archlinux live cd ([use ventoy](https://github.com/ventoy/Ventoy))

```
# configure wireless
iwctl device list
iwctl station <device> scan
iwctl station <device> get-networks
iwctl station <device> connect <SSID>

# Clone
pacman -Sy git
git clone https://github.com/badele/archlinux-auto-install.git
cd archlinux-auto-install

# Set installation configuration
cp config/xxx > install/config
vim install/config
./install/install.sh
```

## Use case
Install 99% of Achlinux automatically, it installs it in less than two minutes.
After installed the minimal arch, you can customized with `ansible` and `dotfiles`

- [ansible-archlinux](https://github.com/badele/ansible-archlinux)
- [dotfiles](https://github.com/badele/dotfiles)


## Thanks
Thanks to zenithar for his documentation https://blog.zenithar.org/post/2020/04/01/archlinux-efi-ssd-luks2-lvm2-btrfs/

**Information for vagrant cloud project page**
- [github archlinux-auto-install project](https://github.com/badele/archlinux-auto-install)
