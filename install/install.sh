#!/bin/bash

set -xe

# run in main archlinux iso installed shell

if [ ! -f install/config ]; then
    echo "Please copy one sample file from config/* to install/config"
    exit 1
fi

set -o allexport; source install/config; set +o allexport

#######################################
# Partition
#######################################

# part1 EFI boot
# part2 LUKS
parted -s $DISK \
mklabel gpt \
mkpart ESP fat32 1MiB 513MiB \
mkpart LUKS ext4 513MiB 100% \
set 1 esp on \
set 1 boot on \
align-check optimal 1

#######################################
# Disk Encryption
#######################################
LUKS_SSD_OPTION=""
if [ "$DISK_TYPE" = "ssd" ]; then
    LUKS_SSD_OPTION="--align-payload 8192"
fi

echo -n "${LUKS_PASSWORD}" | cryptsetup ${LUKS_SSD_OPTION} --type luks1 --cipher aes-xts-plain64 --hash sha256 luksFormat ${LUKS_PARTITION} -
echo -n "${LUKS_PASSWORD}" | cryptsetup luksOpen ${LUKS_PARTITION} ${LUKS_NAME} -

#######################################
# Filesystem
#######################################

# Format disk
mkfs.vfat -F32 -n BOOT $BOOT_PARTITION
mkfs.ext4 /dev/mapper/$LUKS_NAME

# Mount BTRFS partition
# opts_btrfs="${BTRFS_OPTIONS}defaults,noatime,nodiratime"
# mount -o $opts_btrfs /dev/mapper/$LUKS_NAME /mnt

# Create BTRFS partitions
# cd /mnt

# Create subvol
# btrfs subvolume create @
# btrfs subvolume create @/home
# btrfs subvolume create @/var
# btrfs subvolume create @/var/log

# Disable copy-on-write for var
# chattr +C /mnt/@/var

# umount all paritions
# cd $OLDPWD
# umount -R /mnt

# Mount vols
mount /dev/mapper/$LUKS_NAME /mnt
mkdir -p /mnt//boot/efi
mount $BOOT_PARTITION /mnt/boot/efi

#######################################
# System installation
#######################################

# Minimal installation
pacstrap /mnt base base-devel git lvm2 efibootmgr grub net-tools wireless_tools dialog wpa_supplicant

# Generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

# Mount in memory for sensitive datas (from config)
mkdir -p /root/tmp
mount ramfs /root/tmp -t ramfs

mv install /root/tmp/

mkdir -p /mnt/root/tmp
mount --bind /root/tmp /mnt/root/tmp

#######################################
# System installation
#######################################

arch-chroot /mnt /root/tmp/install/configure-user.sh
arch-chroot /mnt /root/tmp/install/prepare-boot.sh

# Execute post-install script from ${CONFDIR} folder
POSTINSTALL="root/tmp/install/post-installation.sh"
test -f "/mnt/${POSTINSTALL}" && chmod +x "/mnt/${POSTINSTALL}" && arch-chroot /mnt "/${POSTINSTALL}"