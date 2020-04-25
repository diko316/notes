#!/bin/sh -e

# install prerequisites
apt-get update -y

apt-get install -y \
  apt-utils \
  unzip \
  ca-certificates \
  curl

# Install from binary if not yet installed
if ! which aws > /dev/null 2>&1; then
  # download binary
  curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \

  unzip awscliv2.zip

  # install
  aws/install

  # remove/cleanup installer
  rm -Rf awscliv2.zip aws
fi

