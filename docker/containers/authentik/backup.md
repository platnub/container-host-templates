[Authentik backup and restore guide](https://docs.goauthentik.io/sys-mgmt/ops/backup-restore/)

# Borgbackup parameters

## Recommended

- Run daily at 00:30
```
30 0 * * * /usr/local/bin/authentik.sh > /dev/null 2>&1
```

## Pre-run script
```
docker exec authentik-postgresql-1 pg_dumpall --username=authentik -f /var/lib/postgresql/data/bkup_postgresql.out --exclude-database=template*
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
