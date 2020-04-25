#!/bin/sh -e

# set to non-interactive
export DEBIAN_FRONTEND=noninteractive

MYSQL_ROOT_PASSWORD='root'
MYSQL_CONFIG="/etc/mysql/my.cnf"
MYSQL_PASSWORD="buang"
MYSQL_TABLE_DIR=/var/lib/mysql
MYSQL_PID_DIR=/var/run/mysqld

# install prerequisites
apt-get update

apt-get install -y \
  apt-utils \
  gnupg-agent

if ! which mysql > /dev/null 2>&1; then
  echo "mysql-server-5.7 mysql-server/root_password password root" | debconf-set-selections
  echo "mysql-server-5.7 mysql-server/root_password_again password root" | debconf-set-selections

  apt-get install -y \
    mysql-server-5.7 \
    mysql-client-5.7

  service mysql stop

  mkdir -p ${MYSQL_PID_DIR}
  mkdir -p ${MYSQL_TABLE_DIR}

  usermod -d ${MYSQL_TABLE_DIR}/ mysql
  # own
  chown -R 'mysql:mysql' ${MYSQL_TABLE_DIR} ${MYSQL_PID_DIR}

  service mysql start

  mysql -u root -proot <<QUERY
use mysql;
UPDATE user SET authentication_string=PASSWORD('${MYSQL_PASSWORD}') WHERE User='root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
FLUSH PRIVILEGES;
QUERY

  service mysql reload
fi

