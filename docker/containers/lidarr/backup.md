[Lidarr backup and restore guide](https://wiki.servarr.com/lidarr/faq#how-do-i-backuprestore-my-lidarr)

# Borgbackup parameters

> [!WARNING]
> Requires [Komodo CLI](https://komo.do/docs/ecosystem/cli)
>    - [Setup](https://github.com/platnub/container-host-templates/blob/main/docker/containers/komodo/README.md#installing-komodo-cli-on-a-priphery-client)

## Recommended

- Run daily at 00:50
```
50 0 * * * /usr/local/bin/lidarr.sh > /dev/null 2>&1
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
    km deploy -y destroy-stack lidarr"
```

## Create
```
borg create -v --stats \
    $REPOSITORY::lidarr_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/lidarr_config/_data \
    --exclude '/var/lib/docker/volumes/lidarr_config/_data/Backups' \
    --exclude '/var/lib/docker/volumes/lidarr_config/_data/logs' \
    --exclude '/var/lib/docker/volumes/lidarr_config/_data/MediaCover' \
    --exclude '/var/lib/docker/volumes/lidarr_config/_data/Sentry'
```

## Post-run script
```
su - komodo -c "export KOMODO_CLI_HOST='${KOMODO_CLI_HOST}' && \
    export KOMODO_CLI_KEY='${KOMODO_CLI_KEY}' && \
    export KOMODO_CLI_SECRET='${KOMODO_CLI_SECRET}'  && \
    km deploy -y stack lidarr"
```
