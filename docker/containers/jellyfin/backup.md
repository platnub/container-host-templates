[Authentik backup and restore guide](https://docs.goauthentik.io/sys-mgmt/ops/backup-restore/)

# Borgbackup parameters

> [!WARNING]
> Requires [Komodo CLI](https://komo.do/docs/ecosystem/cli)
>    - [Setup]()

## Recommended

- Run daily at 00:45
```
45 0 * * * /usr/local/bin/jellyfin.sh > /dev/null 2>&1
```

## Pre-run script
```
su - komodo -c 'km deploy destroy-stack jellyfin'
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
rm -rf /var/lib/docker/volumes/authentik_database/_data/bkup_postgresql.out
```
