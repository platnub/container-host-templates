#!/usr/bin/env bash

# Ask for Komodo allowed IPs
read -p "Enter the allowed IPs for Komodo (comma separated, example: \"1.2.3.0/24\",\"1.2.3.4\"): " allowed_ips

# Ask for Komodo passkey
read -p "Enter the Komodo core passkey: " passkey

# Change SSH port, disable IPv6, Setup UFW firewall
echo -e "\n# Disabling the IPv6\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
sysctl -p

# Configure user user
groupadd -g 1000 user
adduser --gecos GECOS --disabled-password --system --uid 1000 --gid 1000 user

bash -c "$(curl -fsSL https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/scripts/ssh.sh)" -- komodo

# Configure timezone
dpkg-reconfigure tzdata

# Download and create config file
curl -o ./periphery.config.toml https://raw.githubusercontent.com/moghtech/komodo/refs/heads/main/config/periphery.config.toml
# Modify config options of Periphery
## root_directory = "/home/komodo/periphery"
sed -i 's|root_directory = "/etc/komodo"|root_directory = "/home/komodo/periphery"|g' ./periphery.config.toml
## allowed_ips = ["1.2.3.0/24","1.2.3.4"]
sed -i "s|allowed_ips = \[\]|allowed_ips = \[$allowed_ips\]|g" ./periphery.config.toml
## stack_dir = "/opt/docker"
sed -i 's|# stack_dir = "/etc/komodo/stacks"|stack_dir = "/opt/docker"|g' ./periphery.config.toml
## stats_polling_rate = "1-sec"
sed -i 's|stats_polling_rate = "5-sec"|stats_polling_rate = "1-sec"|g' ./periphery.config.toml
## container_stats_polling_rate = "1-sec"
sed -i 's|container_stats_polling_rate = "30-sec"|container_stats_polling_rate = "1-sec"|g' ./periphery.config.toml
## passkey = ["1234423h792387g4r"]
sed -i "s|passkeys = \[\]|passkeys = [\"$passkey\"]|g" /home/komodo/.config/komodo/periphery.config.toml
chown -R komodo:komodo /home/komodo
