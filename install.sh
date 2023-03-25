#!/bin/bash

set -e

# Update
sudo dpkg --configure -a
sudo apt update -y
sudo apt upgrade -y

# Install unattended updates
sudo apt install unattended-upgrades -y
sudo unattended-upgrade

# Set up zsh
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install tailscale
curl -fsSL https://tailscale.com/install.sh | sh
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

# Enable tailscale
sudo tailscale up --advertise-exit-node

# Install caddy
wget 'https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fcaddy-dns%2Fcloudflare&p=github.com%2Fmholt%2Fcaddy-dynamicdns&idempotency=95124409357890'
mv download\?os=linux\&arch=amd64\&p=github.com%2Fcaddy-dns%2Fcloudflare\&p=github.com%2Fmholt%2Fcaddy-dynamicdns\&idempotency=95124409357890 caddy-exe
sudo chmod +x caddy-exe
sudo mv ./caddy-exe /usr/bin/caddy
mkdir /etc/caddy
sudo ln $PWD/caddy/Caddyfile /etc/caddy/Caddyfile
sed -i "s|&HOME&|$PWD|g" $PWD/caddy/caddy.service.d/override.conf
sudo cp -r $PWD/caddy/caddy.service.d /etc/systemd/system
sudo cp $PWD/caddy/caddy.service /etc/systemd/system
sudo groupadd --system caddy
sudo useradd --system --gid caddy --create-home --home-dir /var/lib/caddy --shell /usr/sbin/nologin --comment "Caddy web server" caddy


# Enable caddy
sudo systemctl enable --now caddy
