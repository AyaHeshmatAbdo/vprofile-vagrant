#!/usr/bin/env bash
set -e

# Install Nginx
apt update && apt upgrade -y
apt install -y nginx

# Configure reverse proxy
cat <<EOF > /etc/nginx/sites-available/vproapp
upstream vproapp {
    server app01.vprofile:8080;
}

server {
    listen 80;
    server_name web01.vprofile;

    location / {
        proxy_pass http://vproapp;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Enable site
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

nginx -t && systemctl enable --now nginx
