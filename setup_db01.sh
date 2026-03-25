#!/usr/bin/env bash
set -e

# Variables
ROOT_PASSWORD="admin123"
DB_NAME="accounts"
DB_USER="admin"
DB_PASS="admin123"

# Update system & install MariaDB
yum update -y
yum install -y git mariadb-server

# Start and enable MariaDB
systemctl enable --now mariadb

# Secure installation
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASSWORD';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

# Create database and user
mysql -u root -p"$ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
FLUSH PRIVILEGES;
EOF

# Import initial SQL (if exists)
if [ -f /vagrant/db_backup.sql ]; then
    mysql -u root -p"$ROOT_PASSWORD" $DB_NAME < /vagrant/db_backup.sql
fi

systemctl restart mariadb
