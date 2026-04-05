**OMV Server Manuals**
- [Installing BorgBackup OMV](#Installing-BorgBackup-OMV)
- [Create Local repository for container backups](#Create-Local-repository-for-container-backups)
- [Create Remote repository for offsite backups](#Create-Remote-repository-for-offsite-backups)

**Container Host Manuals**
- [Installing BorgBackup Debian](#Installing-BorgBackup-Debian)
- [Configuring BorgBackup](#Configuring-BorgBackup)

# OMV Server Manuals
Server that will store the backups and make backups to offsite locations

## Installing BorgBackup OMV

1. Connect to OMV using SSH and install [OMV-Extras](https://wiki.omv-extras.org/doku.php?id=misc_docs:omv_extras)
   ```
   sudo wget -O - https://github.com/OpenMediaVault-Plugin-Developers/packages/raw/master/install | bash
   ```
2. Install [BorgBackup Plugin for OMV](https://wiki.omv-extras.org/doku.php?id=omv7:omv7_plugins:borgbackup) by going to 'System > Plugins' and searching for `openmediavault-borgbackup`
3. Navigate to 'Users > Groups' and import a group:
   ```
   bkup;1001;
   ```
4. Navigate to 'Users > Users' and import a user:
   ```
   bkup;1001;;;;;_ssh,bkup;1
   ```

## Create Local repository for container backups

1. Login to OpenMediaVault
2. Navigate to 'Storage > Shared Folders'
3. Create a shared folder called `bkup_<container name>`
   - Use permission 'Administrator: read/write, Users: no access, Others: no access'
4. Edit the folder ACL
   - Replace: enable
   - Recursive: enable
   - Owner: 'bkup [1001]'
      - 'Read/Write/Execute'
   - Group: 'bkup [1001]'
      - 'Read/Write/Execute'
   - Others: 'None'
   - File access control lists:
      - bkup (User): Read/Write
      - bkup (Group): Read/Write
5. Navigate to 'Services > BorgBackup > Repos' and create a new repository
   - Name: `<container name>`
   - Type: 'Local'
   - Shared folder: 'bkup_<container name>'
   - Passphrase: _generate a 64 character key using only letters and numbers.
   - Encryption: enable
   - Skip init: disable
6. Repo keyfile can be downloaded here

## Create Remote repository for offsite backups

1. ...

# Container Host Manuals
Hosts that run containers that need to backup data to a central server

> [!NOTE]
> These manuals are written for Debian

## Installing BorgBackup Debian

1. Install BorgBackup
   ```
   apt update -y && apt upgrade -y && apt install borgbackup -y
   ```

## Configuring BorgBackup

> [!NOTE]
> __Requirements:__
> - Repository on a central server
> - SSH private key for 'bkup' user saved as `/home/<hostname>/.ssh/bkup` using `chmod 600`

1. Create a new script file. Make sure to name the script after the container.
   ```
   sudo mkdir -p /var/log/borg && \
   sudo nano /usr/local/bin/<container>.sh && \
   sudo chmod 700 /usr/local/bin/<container>.sh
   ```
2. Fill in the '[borgbackup_template.sh](borgbackup_template.sh)' and paste it into the file.
   - BACKUP_PATH is the full path of the remote folder on the remote machine (Shared folder in OMV)
3. Save the repo keyfile under '/root/.config/borg/keys'
   - Edit permissions `chmod 400 /root/.config/borg/keys/...`
   - If .config folder is missing
     ```
     sudo mkdir -p /root/.config/borg/keys && \
     sudo mkdir -p /root/.config/borg/security && \
     chmod 700 /root/.config -R
     ```
5. Create a run schedule using CRON. Install CRON if necessary `apt update -y && apt upgrade -y && apt install cron -y`
   ```
   sudo crontab -e
   ```
   - Append (example!!) `0 0 * * * /usr/local/bin/<container>.sh > /dev/null 2>&1`
