#!/bin/bash

set -xe

# run in chrooted
set -o allexport; source /root/tmp/install/config; set +o allexport

# User
useradd $USER_NAME --create-home --user-group
echo "$USER_NAME:$USER_PASSWORD" | chpasswd

# Allow passwordless sudo (needed by this installer)
echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


# Configure ssh access for vagrant (see https://www.vagrantup.com/docs/boxes/base#vagrant-user)
if [ "$INSTALL_MODE" = "vagrant" ]; then
    mkdir /home/$USER_NAME/.ssh
    curl -s https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub > /home/$USER_NAME/.ssh/authorized_keys

    # Protect the homefolder and ssh keys
    chown -R $USER_NAME:$USER_NAME /home/vagrant
    chmod -R g-rwx,o-rwx /home/$USER_NAME/.ssh
fi
