#!/bin/sh -e

SSHD_CONFIG=/etc/ssh/sshd_config

apt-get update -y

dpkg-query -s openssh-server >/dev/null 2>&1 || \
  apt-get install -y openssh-server

dpkg-query -s openssh-sftp-server >/dev/null 2>&1 || \
  apt-get install -y openssh-sftp-server

echo "You can now update ${SSHD_CONFIG} file" >&2

cat <<CREATE_CONFIG >&2

######################################
# Example:
#             file: /etc/ssh/sshd_config
#             user: ubuntu
#            group: ubuntu
#   root directory: /home
######################################

Match group ubuntu
ChrootDirectory /home
X11Forwarding no
AllowTcpForwarding no
ForceCommand internal-sftp


CREATE_CONFIG


