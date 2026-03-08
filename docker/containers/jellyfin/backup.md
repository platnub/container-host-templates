[Jellyfin backup and restore guide](https://jellyfin.org/docs/general/administration/backup-and-restore/)

# Borgbackup parameters

> [!WARNING]
> Requires [Komodo CLI](https://komo.do/docs/ecosystem/cli)
>    - [Setup](https://github.com/platnub/container-host-templates/blob/main/docker/containers/komodo/README.md#installing-komodo-cli-on-a-priphery-client)

## Recommended

- Run daily at 00:45
```
45 0 * * * /usr/local/bin/jellyfin.sh > /dev/null 2>&1
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
