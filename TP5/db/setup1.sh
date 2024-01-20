#!/bin/bash

# This script sets up MariaDB as a master server.

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

# Configure Master MariaDB Server
sudo mysql -u root <<EOF
CREATE USER 'meo'@'%' IDENTIFIED BY 'meo';
GRANT ALL PRIVILEGES ON meo.* TO 'meo'@'%';
FLUSH PRIVILEGES;
CREATE USER 'replication_user'@'%' IDENTIFIED BY 'replication_password';
GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%';
FLUSH PRIVILEGES;
FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
EOF

echo "Master configured. File and Position for slave configuration:"
sudo mysql -u root -e "SHOW MASTER STATUS;"

# Restart MariaDB
sudo systemctl restart mariadb
sudo reboot


