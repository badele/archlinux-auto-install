#!/bin/bash

# run in chrooted
set -o allexport; source /root/tmp/install/config; set +o allexport

# Install Yay
cd /tmp
su $USER_NAME -c "git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -sri --noconfirm"

# Install package
su $USER_NAME -c "yay --noconfirm -Sy ${CPU_TYPE}-ucode grub-theme-vimix linux-firmware linux mkinitcpio hdparm util-linux networkmanager openssh ansible"

# Ansible
su $USER_NAME -c "yay --noconfirm -Sy ansible python-resolvelib"

# Console
cat << EOF > /etc/vconsole.conf
KEYMAP=fr
FONT=Lat2-Terminus16
EOF

# Define locale
cat << EOF > /etc/locale.gen
en_US.UTF-8 UTF-8
fr_FR.UTF-8 UTF-8
EOF

# Generate and assign default locale
locale-gen
echo "LANG=fr_FR.UTF-8" > /etc/locale.conf

# Host
echo "$HOSTNAME" > /etc/hostname
cat << EOF > /etc/hosts
127.0.0.1 localhost
::1 localhost
127.0.1.1 ${HOSTNAME}.local ${HOSTNAME}
EOF

if [ "$DISK_TYPE" = "ssd" ]; then
    systemctl enable fstrim.timer
fi

systemctl enable NetworkManager.service
# systemctl enable systemd-networkd.service
# systemctl enable systemd-resolved.service
systemctl enable sshd.service


# For Grub LUKS parition, add LUKS key for evit enter twice passphrase
dd bs=512 count=8 if=/dev/urandom of=/crypto_keyfile.bin
echo -n "$LUKS_PASSWORD" | cryptsetup luksAddKey $LUKS_PARTITION /crypto_keyfile.bin -
chmod 000 /crypto_keyfile.bin

# Kernel
{
    echo "BINARIES=(btrfsck)"
    echo "HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck btrfs)"
    echo "FILES=(/crypto_keyfile.bin)"
} >> /etc/mkinitcpio.conf

mkinitcpio -p linux

LUKS_UUID=$(blkid $LUKS_PARTITION -o value | head -n1)
cat << EOF > /etc/default/grub
#GRUB_DEFAULT=saved
GRUB_TIMEOUT=3
GRUB_DISTRIBUTOR="${GRUB_BOOT_NAME}"
GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=UUID=${LUKS_UUID}:$LUKS_NAME"
GRUB_CMDLINE_LINUX=""
#GRUB_SAVEDEFAULT=true
GRUB_PRELOAD_MODULES="btrfs part_gpt part_msdos"
GRUB_TERMINAL_INPUT=at_keyboard
LANG=fr_FR
GRUB_GFXMODE=auto
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_DISABLE_RECOVERY=true
GRUB_COLOR_NORMAL="white/black"
GRUB_COLOR_HIGHLIGHT="white/dark-gray"
GRUB_BACKGROUND="/usr/share/grub/themes/Vimix/background.jpeg"
GRUB_THEME="usr/share/grub/themes/Vimix/theme.txt"
GRUB_ENABLE_CRYPTODISK=y
GRUB_DISABLE_OS_PROBER=false
EOF

# Install UEFI boot files
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck $GRUB_EFI_FALLBACK

# Configure Grub
grub-mkconfig -o /boot/grub/grub.cfg
#grub-mkconfig -o /boot/efi/EFI/grub/grub.cfg

# Clean unused files
pacman -Scc
