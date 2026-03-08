#!/usr/bin/env bash

# Specify the path to the key
USERNAME="$(hostname)"  
export BORG_RSH="ssh -i /home/$USERNAME/.ssh/bkup"

## Borg passphrase
export BORG_PASSPHRASE=''

LOG='/var/log/borg/backup.log'

# Set backup location
BACKUP_USER='<user>'
BACKUP_HOST='<server>'
BACKUP_PORT='<ssh port>'
BACKUP_PATH='<repository path>'

export REPOSITORY="ssh://${BACKUP_USER}@${BACKUP_HOST}:${BACKUP_PORT}${BACKUP_PATH}"

# Output to a logfile
exec > >(tee -i ${LOG})
exec 2>&1

echo "###### Backup started: $(date) ######"

# Perform tasks that will run before the backup here, e.g.
# - Create a list of installed software
# - Create a database dump

# Run backup
echo "Transfer files ..."
borg create -v --stats \
    $REPOSITORY::example_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/example/_data \
    /var/lib/docker/volumes/example2/_data \
    --exclude /var/lib/docker/volumes/example/_data/exclude
    --exclude /var/lib/docker/volumes/example2/_data/exclude

echo "###### Backup ended: $(date) ######"

# Pruning backups
borg prune -v --list \
    $REPOSITORY \
    --keep-yearly 1 \
    --keep-monthly 3 \
    --keep-weekly 4 \
    --keep-daily 7

borg compact $REPOSITORY

# Perform tasks that will run after the backup here
