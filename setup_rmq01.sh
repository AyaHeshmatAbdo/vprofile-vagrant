#!/usr/bin/env bash
set -e

# Install RabbitMQ
yum update -y
dnf -y install epel-release
dnf -y install centos-release-rabbitmq-38
dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server

# Enable and start service
systemctl enable --now rabbitmq-server

# Configure remote access
echo '[{rabbit, [{loopback_users, []}]}].' > /etc/rabbitmq/rabbitmq.config

# Add user
RABBIT_USER="test"
RABBIT_PASS="test@1234567"
rabbitmqctl add_user $RABBIT_USER $RABBIT_PASS || true
rabbitmqctl set_user_tags $RABBIT_USER administrator
rabbitmq-plugins enable rabbitmq_management || true

systemctl restart rabbitmq-server
