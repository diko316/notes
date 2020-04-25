#!/bin/sh -e

SSHD_CONFIG=/etc/ssh/sshd_config
VERSION_PREFIX=1:7

apt-get update -y

OPEN_SSH_VERSION=$(apt-cache policy openssh | grep -oP '[^ ]+ 500$' | awk '{print $1}' | grep ${VERSION_PREFIX} | head -n 1 || echo "")
PACKAGE_SUFFIX=

[ "[${OPEN_SSH_VERSION}]" = "[]" ] || PACKAGE_SUFFIX="=${OPEN_SSH_VERSION}"

dpkg-query -s openssh-server >/dev/null 2>&1 || \
  apt-get install -y "openssh-server${PACKAGE_SUFFIX}"

dpkg-query -s openssh-sftp-server >/dev/null 2>&1 || \
  apt-get install -y "openssh-sftp-server${PACKAGE_SUFFIX}"

echo "You can now update ${SSHD_CONFIG} file" >&2

cat << 'CREATE_CONFIG' >&2

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


