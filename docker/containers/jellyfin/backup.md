[Authentik backup and restore guide](https://docs.goauthentik.io/sys-mgmt/ops/backup-restore/)

# Borgbackup parameters

> [!WARNING]
> Requires [Komodo CLI](https://komo.do/docs/ecosystem/cli)
>    - [Setup](https://github.com/platnub/container-host-templates/blob/main/docker/containers/komodo/README.md#installing-komodo-cli-on-a-priphery-client)

## Recommended

- Run daily at 00:45
```
45 0 * * * /usr/local/bin/jellyfin.sh > /dev/null 2>&1
```

## Pre-run script
```
su - komodo -c 'export KOMODO_CLI_HOST='http://0.0.0.0:9120' && \
    export KOMODO_CLI_KEY='' && \
    export KOMODO_CLI_SECRET=''  && \
    km deploy -y destroy-stack jellyfin'
```

## Create
```
borg create -v --stats \
    $REPOSITORY::authentik_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/authentik_database/_data/bkup_postgresql.out \
    /var/lib/docker/volumes/authentik_data/_data \
    /var/lib/docker/volumes/authentik_certs/_data \
    /var/lib/docker/volumes/authentik_custom-templates/_data \
    /var/lib/docker/volumes/authentik_blueprints/_data
```

## Post-run script
```
su - komodo -c 'export KOMODO_CLI_HOST='http://0.0.0.0:9120' && \
    export KOMODO_CLI_KEY='' && \
    export KOMODO_CLI_SECRET=''  && \
    km deploy -y stack jellyfin'
```
