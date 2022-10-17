# archlinux-auto-install

**DO NOT EDIT DIRECTLY THIS README.MD (edit the README.tpl)** and execute `make doc-generate`

Automatic installation of Archlinux for vagrants and physical hosts.

This project install minimal Archlinux from scratch, other packages and configuration are done with **ansible**

Image contains :
- Archlinux 2021.04.01
- Encrypted LUKS disk (for vagrant, the password is `vagrant`)
- `grub` and `grub-theme`
- `networkmanager`
- `yay` package (for installaling AUR packages)
- `git` for clonning some project (ex: [ansible-archlinux](https://github.com/badele/ansible-archlinux))
- `ansible` (for customize automatically your installation)

## Vagrant box

<table>
    <tr>
        <th>Logo</th>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><img width="32" src="https://simpleicons.org/icons/archlinux.svg"></td>
        <td><a href="https://archlinux.org/">Archlinux</a></td>
        <td>Base Archlinux version</td>
    </tr>
    <tr>
        <td><img width="32" src="https://simpleicons.org/icons/ansible.svg"></td>
        <td><a href="https://www.ansible.com/">Ansible</a></td>
        <td>Archlinux + Ansible support</td>
    </tr>
    <tr>
        <td><img width="32" src="https://simpleicons.org/icons/nixos.svg"></td>
        <td><a href="https://nixos.org/">Nixos</a></td>
        <td>Archlinux + Nix support</td>
    </tr>
</table>

## Help(commands)

```
${COMMANDS}
```

## Build

```
make archlinux-versions
make NAME=base vagrant-build
make NAME=ansible vagrant-build
make NAME=nix vagrant-build

make NAME=base vagrant-up
make NAME=base vagrant-ssh
make NAME=base vagrant-destroy
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
rm -f /var/lib/pacman/sync/*.db
pacman -Sy git
git clone https://github.com/badele/archlinux-auto-install.git
cd archlinux-auto-install

# Set installation configuration
cp config/xxx > install/config
vim install/config
./install/install.sh
```

## Usage
```
# From vagrant cloud
vagrant init badele/ansiblearch && vagrant up
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

