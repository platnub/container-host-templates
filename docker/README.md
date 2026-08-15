
> [!IMPORTANT]
> Requirement: [Komodo host](https://github.com/platnub/container-host-templates/tree/main/docker/containers/komodo)\
> Do not use if creating [Pangolin host](https://github.com/platnub/titan-server/blob/main/docker/containers/pangolin) or [Komodo host](https://github.com/platnub/container-host-templates/tree/main/docker/containers/komodo)

---

# Host configuration script

4. Connect to the VM through SSH using a sudo priveledged user. Configure automatic upgrades - [Periodic Updates](https://wiki.debian.org/PeriodicUpdates)
   ```
   # Configure automatic upgrades
   cp /etc/apt/apt.conf.d/50unattended-upgrades /etc/apt/apt.conf.d/52unattended-upgrades-local
   sed -i 's|//Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";|Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";|g' /etc/apt/apt.conf.d/52unattended-upgrades-local
   sed -i 's|//Unattended-Upgrade::Remove-New-Unused-Dependencies "true";|Unattended-Upgrade::Remove-New-Unused-Dependencies "true";|g' /etc/apt/apt.conf.d/52unattended-upgrades-local
   sed -i 's|//Unattended-Upgrade::Remove-Unused-Dependencies "false";|Unattended-Upgrade::Remove-Unused-Dependencies "false";|g' /etc/apt/apt.conf.d/52unattended-upgrades-local
   sed -i 's|//Unattended-Upgrade::Automatic-Reboot "false";|Unattended-Upgrade::Automatic-Reboot "true";|g' /etc/apt/apt.conf.d/52unattended-upgrades-local
   sed -i 's|//Unattended-Upgrade::Automatic-Reboot-WithUsers "true";|Unattended-Upgrade::Automatic-Reboot-WithUsers "true";|g' /etc/apt/apt.conf.d/52unattended-upgrades-local
   sed -i 's|//Unattended-Upgrade::Automatic-Reboot-Time "02:30";|Unattended-Upgrade::Automatic-Reboot-Time "02:00";|g' /etc/apt/apt.conf.d/52unattended-upgrades-local
   dpkg-reconfigure unattended-upgrades
   ```
5. Change automatic update download timer using `systemctl edit apt-daily.timer` paste:
   ```
   [Timer]
   OnCalendar=01:00
   RandomizedDelaySec=30m
   ```
6. Change automatic update upgrade timer using `systemctl edit apt-daily-upgrade.timer` paste:
   ```
   [Timer]
   OnCalendar=01:45
   RandomizedDelaySec=30m
   ```
7. Disable sudo verification. Type `sudo visudo`.<br>
   Change `%sudo   ALL=(ALL:ALL) ALL` to `%sudo   ALL=(ALL:ALL) NOPASSWD: ALL`

# Update Komodo Periphery
```
cd /home/komodo
curl -sSL https://raw.githubusercontent.com/moghtech/komodo/main/scripts/setup-periphery.py | python3 - --user
systemctl --user status periphery
```

# Create Docker volume with NFS share on rootless host

1. Set environment variable for Docker socket location
   ```bash
   ls -l /run/user/$(id -u)/docker.sock # Check it exists
   export DOCKER_HOST=unix:///run/user/1337/docker.sock # Set Environment Variable
   echo 'export DOCKER_HOST=unix:///run/user/1337/docker.sock' >> ~/.bashrc # Make persistent across sessions
   ```
   
2. Create NFS Docker volume
   ```bash
   docker volume create --driver local \
     --opt type=nfs \
     --opt o=addr=10.0.20.200,soft,nfsvers=4,anongid=100,anonuid=100 \
     --opt device=:/Media \
     media # Volume name
   ```
