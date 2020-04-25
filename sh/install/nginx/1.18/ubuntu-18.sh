#!/bin/sh -e

# set to non-interactive
export DEBIAN_FRONTEND=noninteractive

# set os release
. /etc/os-release
export RELEASE_NAME=${UBUNTU_CODENAME}

# set release file
NGINX_LIST_FILE=/etc/apt/sources.list.d/nginx.list

# install prerequisites
apt-get update -y
apt-get install -y \
  apt-utils \
  gnupg-agent \
  curl

if ! which nginx > /dev/null 2>&1; then
  NGINX_LIST_FILE=/etc/apt/sources.list.d/nginx.list

  # update source list
  echo "deb https://nginx.org/packages/ubuntu/ ${RELEASE_NAME} nginx" >> ${NGINX_LIST_FILE}
  echo "deb-src https://nginx.org/packages/ubuntu/ ${RELEASE_NAME} nginx" >> ${NGINX_LIST_FILE}

  curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

  apt-get update -y

  # install 1.18 or the most stable version
  apt-get install -y nginx=1.18.0-1~bionic || apt-get install -y nginx/stable
fi
