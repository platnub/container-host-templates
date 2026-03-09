[Seerr backup and restore guide](https://docs.seerr.dev/using-seerr/backups)

# Borgbackup parameters

## Recommended

- Run daily at 00:45
```
45 0 * * * /usr/local/bin/seerr.sh > /dev/null 2>&1
```

## Extra variables

> [!NOTE]
> Can be pasted anywhere before the backup starts.

```
KOMODO_CLI_HOST='http://0.0.0.0:9120'
KOMODO_CLI_KEY=''
KOMODO_CLI_SECRET=''
```

## Pre-run script
```
su - komodo -c "export KOMODO_CLI_HOST='${KOMODO_CLI_HOST}' && \
    export KOMODO_CLI_KEY='${KOMODO_CLI_KEY}' && \
    export KOMODO_CLI_SECRET='${KOMODO_CLI_SECRET}'  && \
    km deploy -y destroy-stack jellyseerr"
```

## Create
```
borg create -v --stats \
    $REPOSITORY::seerr_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/jellyseerr_en-config/_data/db/db.sqlite3 \
    /var/lib/docker/volumes/jellyseerr_en-config/_data/settings.json \
    /var/lib/docker/volumes/jellyseerr_de-config/_data/db/db.sqlite3 \
    /var/lib/docker/volumes/jellyseerr_de-config/_data/settings.json
```

## Post-run script
```
su - komodo -c "export KOMODO_CLI_HOST='${KOMODO_CLI_HOST}' && \
    export KOMODO_CLI_KEY='${KOMODO_CLI_KEY}' && \
    export KOMODO_CLI_SECRET='${KOMODO_CLI_SECRET}'  && \
    km deploy -y stack jellyseerr"
```
