#!/bin/bash

# This script sets up MariaDB as a slave server.

# Disable SELinux
sudo setenforce 0
echo "SELINUX=disabled
SELINUXTYPE=targeted" | sudo tee /etc/selinux/config > /dev/null

# Install MariaDB
sudo dnf install mariadb-server -y
sudo systemctl enable --now mariadb

# Create database and tables
echo "CREATE DATABASE IF NOT EXISTS meo;
USE meo;

CREATE TABLE meo
  (
     id    INT NOT NULL AUTO_INCREMENT,
     name  VARCHAR(255) NOT NULL,
     email VARCHAR(255) NOT NULL,
     PRIMARY KEY (id)
  );" > create_database.sql

sudo mysql -u root < /home/vagrant/create_database.sql

# Secure MariaDB installation
sudo mysql_secure_installation <<EOF
n
y
y
y
y
EOF

# Configure Slave MariaDB Server
sudo mysql -u root <<EOF
CHANGE MASTER TO
  MASTER_HOST=10.5.1.211,
  MASTER_USER='replication_user',
  MASTER_PASSWORD='replication_password',
START SLAVE;
EOF

echo "Slave configured."

# Restart MariaDB
sudo systemctl restart mariadb
sudo reboot
