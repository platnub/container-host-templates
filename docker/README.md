
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

# Configure Docker service to wait for NFS mount

1. Install NFS
   ```
   apt install nfs-common -y
   ```
2. Create NFS directory. Edit `<NFS MOUNT NAME>`
   ```bash
   mkdir -p /nfs/<NFS MOUNT NAME>
   ```
   
3. Create NFS mount
   - `<NFS server IP>`: IP address of NFS server
   - `<NFS mount>`: NFS /Mount on NFS server
   - `<NFS MOUNT NAME>`: Local NFS mount directory
   ```bash
   sudo tee /etc/systemd/system/nfs-<NFS MOUNT NAME>.mount > /dev/null <<'EOF'
   [Unit]
   Description=NFS mount for <NFS MOUNT NAME> (Docker)
   After=network-online.target
   Wants=network-online.target
   
   [Mount]
   What=<NFS server IP>:/<NFS mount>
   Where=/nfs/<NFS MOUNT NAME>
   Type=nfs
   Options=rw,soft,nfsvers=4,_netdev
   
   [Install]
   WantedBy=multi-user.target
   EOF
   ```

4. Reload daemon and enable script. Edit `<NFS MOUNT NAME>`
   ```
   systemctl daemon-reload
   systemctl enable --now nfs-<NFS MOUNT NAME>.mount
   ```

5. Create 'wait for mount' script
   ```
   sudo tee /usr/local/bin/wait-for-mount.sh > /dev/null <<'EOF'
   #!/bin/bash
   # Usage: wait-for-mount.sh <target-path> [timeout-seconds]
   TARGET="$1"
   TIMEOUT="${2:-60}"
   COUNT=0
   
   if [ -z "$TARGET" ]; then
     echo "ERROR: no target path given"
     exit 1
   fi
   
   while ! mountpoint -q "$TARGET" && [ "$COUNT" -lt "$TIMEOUT" ]; do
     echo "Waiting for $TARGET to be mounted... ($COUNT/$TIMEOUT)"
     sleep 1
     COUNT=$((COUNT+1))
   done
   
   if ! mountpoint -q "$TARGET"; then
     echo "ERROR: $TARGET not mounted after ${TIMEOUT}s"
     exit 1
   fi
   
   echo "$TARGET is mounted."
   exit 0
   EOF
   ```
6. Make script executable and make the Docker service wait for it.  Edit `<NFS MOUNT NAME>`
   ```
   chmod +x /usr/local/bin/wait-for-mount.sh
   machinectl shell dockerd@ /bin/bash -c '
   mkdir -p ~/.config/systemd/user/docker.service.d
   cat > ~/.config/systemd/user/docker.service.d/wait-for-nfs.conf <<EOF
   [Service]
   ExecStartPre=/usr/local/bin/wait-for-mount.sh /nfs/<NFS MOUNT NAME> 60
   EOF'
   systemctl --user -M dockerd@ daemon-reload
   systemctl --user -M dockerd@ restart docker
   ```
