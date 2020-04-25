#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# install prerequisites
apt-get update -y

apt-get install -y \
  apt-utils \
  gnupg-agent

# install apt-repository if not yet installed
! which add-apt-repository > /dev/null 2>&2 && \
  apt-get install -y software-properties-common


# locale en_US.UTF-8 is required for ppa:ondrej/php installation
if ! locale -a | grep -q 'en_US.UTF-8'; then
  apt-get install -y language-pack-en-base
  locale-gen en_US.UTF-8
fi

# add repository
add-apt-repository -yu ppa:ondrej/php

# install what you need other than php7.3
apt-get install -y \
  php7.3 \
  php7.3-bcmath \
  php7.3-bz2 \
  php7.3-cgi \
  php7.3-cli \
  php7.3-common \
  php7.3-curl \
  php7.3-fpm \
  php7.3-gd \
  php7.3-gmp \
  php7.3-imap \
  php7.3-intl \
  php7.3-json \
  php7.3-ldap \
  php7.3-mbstring \
  php7.3-mysql \
  php7.3-opcache \
  php7.3-readline \
  php7.3-soap \
  php7.3-sqlite3 \
  php7.3-xml \
  php7.3-xmlrpc \
  php7.3-xsl

update-rc.d php7.3-fpm defaults

