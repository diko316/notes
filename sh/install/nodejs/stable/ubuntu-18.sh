#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive

NODE_VERSION=10

# install prerequisites
apt-get update -y

apt-get install -y \
  curl \
  software-properties-common

curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -

apt-get install -y nodejs
