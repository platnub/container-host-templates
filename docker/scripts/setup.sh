
# Change SSH port, disable IPv6, Setup UFW firewall
echo -e "\n# Disabling the IPv6\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
sysctl -p

# Configure user user
groupadd -g 1000 user
adduser --gecos GECOS --disabled-password --system --uid 1000 --gid 1000 user

bash -c "$(curl -fsSL https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/scripts/ssh.sh)" -- komodo

