OMV Server Manuals
- [Installing BorgBackup](BorgBackup.md#Installing BorgBackup)

# OMV Server Manuals
Server that will store the backups and make backups to offsite locations

## Installing BorgBackup

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

#### Create Local repository for container backups

1. Navigate to 'Storage > Shared Folders'
2. Create a shared folder called `bk_<container name>`
   - Use permission 'Administrator: read/write, Users: no access, Others: no access'
3. Edit the folder ACL
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
4. Navigate to 'Services > BorgBackup > Repos' and create a new repository
   - Name: `<container name>`
   - Type: 'Local'
   - Shared folder: 'bk_<container name>'
   - Passphrase: _generate a 64 character key using only letters and numbers.
   - Encryption: enable
   - Skip init: disable

#### Create Remote repository for offsite backups

1. ...

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

1. Create a new script file. Make sure to name the script after the container.
   ```
   sudo mkdir -p /var/log/borg
   sudo nano /usr/local/bin/<container>.sh
   ```
2. Fill in the '[borgbackup_template.sh](borgbackup_template.sh)' and paste it into the file.
   - BACKUP_PATH is the full path of the remote folder on the remote machine (Shared folder in OMV)
