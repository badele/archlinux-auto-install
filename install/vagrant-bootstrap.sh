#!/bin/bash

# Enable SSH

cat <<EOF >> /etc/ssh/sshd_config
PermitRootLogin yes
PermitEmptyPasswords yes
EOF

# sshd may not even be started, but this will take care of that...
systemctl restart sshd.service
