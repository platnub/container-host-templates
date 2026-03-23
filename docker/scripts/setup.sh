#!/usr/bin/env bash

# Ask for SSH port

# Generate a random port in 10000-65535
generate_port() {
  shuf -i 10000-65535 -n 1
}

while true; do
  default_port=$(generate_port)
  read -p "Enter the SSH port you want to use (press Enter for default ${default_port}, or type 'r' to regenerate): " ssh_port

  # If user asked for a new random port, loop and prompt again
  if [[ "$ssh_port" == "r" ]]; then
    continue
  fi

  # Use default if empty
  if [[ -z "$ssh_port" ]]; then
    ssh_port=$default_port
    break
  fi

  # Validate numeric
  if ! [[ "$ssh_port" =~ ^[0-9]+$ ]]; then
    echo "Invalid port: not a number. Please enter a numeric port between 1024 and 65535, or 'r' to regenerate."
    continue
  fi

  # Validate range 1024-65535
  if (( ssh_port < 1024 || ssh_port > 65535 )); then
    echo "Invalid port: must be between 1024 and 65535."
    continue
  fi
  break
done
echo "Using SSH port: $ssh_port"

# Ask for Komodo allowed IPs
read -p "Enter the allowed IPs for Komodo (comma separated, example: \"1.2.3.0/24\",\"1.2.3.4\"): " allowed_ips

# Ask for Komodo passkey
read -p "Enter the Komodo core passkey: " passkey

# Install SSH and UFW
apt-get update -y && apt-get upgrade -y
apt-get install ssh -y
apt-get install fail2ban -y
apt-get install ufw -y
apt-get install wget -y

# Change SSH port, disable IPv6, Setup UFW firewall
sed -i "s/\#Port 22/Port $ssh_port /" /etc/ssh/sshd_config
sed -i "s/\#MaxAuthTries 6/MaxAuthTries 20 /" /etc/ssh/sshd_config
sed -i "s/\#MaxSessions 10/MaxSessions 2 /" /etc/ssh/sshd_config
systemctl daemon-reload
systemctl restart sshd
echo -e "\n# Disabling the IPv6\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
sysctl -p
sed -i 's|IPV6=yes|IPV6=no|g' /etc/default/ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow $ssh_port/tcp
ufw allow 8120/tcp
ufw --force enable

# Configure user user
groupadd -g 1000 user
adduser --gecos GECOS --disabled-password --system --uid 1000 --gid 1000 user
# Configure bkup user
groupadd -g 1001 bkup
adduser --gecos GECOS --disabled-password --uid 1001 --gid 1001 bkup
# Configure komodo user
groupadd -g 1337 komodo
adduser --gecos GECOS --disabled-password --uid 1337 --gid 1337
echo "-----------------------------------------------------------------------------"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/scripts/ssh.sh)" -- komodo

# Configure timezone
dpkg-reconfigure tzdata

# Install and configure Docker
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -y
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Create folders
mkdir /opt/docker
chown komodo:komodo /opt/docker
chmod 700 /opt/docker
usermod -aG docker komodo


# Download and create config file
mkdir -p /home/komodo/.config/komodo && cd /home/komodo/.config/komodo && curl -o ./periphery.config.toml https://raw.githubusercontent.com/moghtech/komodo/refs/heads/main/config/periphery.config.toml
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
