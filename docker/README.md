# ‼️ Requirements for **EVERY** docker container
 1. Configuration script below
     - The only 2 exceptions are Pangolin host and Komodo host
 2. A healthy mindset

---

# Host configuration script

‼️ Do not run if creating [Pangolin host](https://github.com/platnub/titan-server/blob/main/docker/containers/pangolin) or [Komodo host](https://github.com/platnub/container-host-templates/tree/main/docker/containers/komodo)

‼️ Allowed IPs **MUST** be surrounded by quotes: "1.1.1.1","2.2.2.2"

1. Connect to the VM through SSH port 22 using sudo user
2. ```
   sudo su
   ```
   ```
   sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/setup.sh)"
   ```
3. Connect to the VM through SSH using the komodo user
   ```
   # Install Periphery
   cd /home/komodo
   curl -sSL https://raw.githubusercontent.com/moghtech/komodo/main/scripts/setup-periphery.py | python3 - --user
   loginctl enable-linger $USER
   systemctl --user enable periphery
   systemctl --user status periphery
   
    ```
4. Connect to the VM through SSH using a sudo priveledged user
   Configure automatic upgrades - [Periodic Updates](https://wiki.debian.org/PeriodicUpdates)
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

# Update Komodo Periphery
```
cd /home/komodo
curl -sSL https://raw.githubusercontent.com/moghtech/komodo/main/scripts/setup-periphery.py | python3 - --user
systemctl --user status periphery
```
