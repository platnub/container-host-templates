[n8n backup guide](https://docs.n8n.io/embed/deployment/#backups)

# Borgbackup parameters

## Recommended

- Run daily at 00:45
```
45 0 * * * /usr/local/bin/n8n.sh > /dev/null 2>&1
```

## Create
```
borg create -v --stats \
    $REPOSITORY::n8n_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/n8n_data/_data \
    --exclude /var/lib/docker/volumes/n8n_data/_data/^database.sqlite.+$ \
    --exclude /var/lib/docker/volumes/n8n_data/_data/crash.journal \
    --exclude /var/lib/docker/volumes/n8n_data/_data/^n8nEventLog.*.log$
```
