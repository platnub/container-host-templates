[Seerr backup and restore guide](https://docs.seerr.dev/using-seerr/backups)

# Borgbackup parameters

## Recommended

- Run daily at 00:45
```
45 0 * * * /usr/local/bin/seerr.sh > /dev/null 2>&1
```

> [!WARNING]
> Unifinished!

## Pre-run script
```
su - komodo -c "export KOMODO_CLI_HOST='${KOMODO_CLI_HOST}' && \
    export KOMODO_CLI_KEY='${KOMODO_CLI_KEY}' && \
    export KOMODO_CLI_SECRET='${KOMODO_CLI_SECRET}'  && \
    km deploy -y destroy-stack jellyfin"
```

## Create
```
borg create -v --stats \
    $REPOSITORY::jellyfin_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/jellyfin_config/_data
```

## Post-run script
```
su - komodo -c "export KOMODO_CLI_HOST='${KOMODO_CLI_HOST}' && \
    export KOMODO_CLI_KEY='${KOMODO_CLI_KEY}' && \
    export KOMODO_CLI_SECRET='${KOMODO_CLI_SECRET}'  && \
    km deploy -y stack jellyfin"
```
