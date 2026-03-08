# OMV Server Manuals
Server that will store the backups and make backups to offsite locations

## Installing BorgBackup

> [!NOTE]
> __Requirements:__
> - ...

# Container Host Manuals
Hosts that run containers that need to backup data to a central server

> [!NOTE]
> These manuals are written for Debian

## Installing BorgBackup

1. Install BorgBackup
   ```
   apt update && apt upgrade && apt install borgbackup -y
   ```

## Configuring BorgBackup

> [!NOTE]
> __Requirements:__
> - Repository on a central server
> - SSH key and 'bkup' user

1. 
