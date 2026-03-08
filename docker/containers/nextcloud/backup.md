[Nextcloud backup guide](https://docs.nextcloud.com/server/stable/admin_manual/maintenance/backup.html)
[Nextcloud backup restore guide](https://docs.nextcloud.com/server/stable/admin_manual/maintenance/restore.html)

# Borgbackup parameters

## Recommended

- Run daily at 00:30 `30 0 * * *`

## Create
```
borg create -v --stats \
    $REPOSITORY::vaultwarden_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/vaultwarden_data/_data \
    --exclude /var/lib/docker/volumes/vaultwarden_data/_data/sends \
    --exclude /var/lib/docker/volumes/vaultwarden_data/_data/tmp
```
