#!/usr/bin/env bash
set -e

# Update system & install Memcached
yum update -y
yum install -y epel-release memcached

# Configure Memcached
sed -i 's/127.0.0.1/0.0.0.0/' /etc/sysconfig/memcached
systemctl enable --now memcached
