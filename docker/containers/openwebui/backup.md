[OpenWebUI backup guide](https://docs.openwebui.com/tutorials/maintenance/backups/)

# Borgbackup parameters

## Recommended

- Run daily at 00:30
```
30 0 * * * /usr/local/bin/openwebui.sh > /dev/null 2>&1
```

## Create
```
borg create -v --stats \
    $REPOSITORY::openwebui_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/openwebui_openwebui/_data \
    --exclude /var/lib/docker/volumes/openwebui_openwebui/_data/cache \
    --exclude /var/lib/docker/volumes/openwebui_openwebui/_data/audit.log
```
