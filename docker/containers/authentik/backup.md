[Authentik backup and restore guide]([https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault](https://docs.goauthentik.io/sys-mgmt/ops/backup-restore/))

# Borgbackup parameters

## Recommended

- Run daily at 00:30 `30 0 * * *`

## Pre-run script
```
docker exec -d authentik-postgresql-1 pg_dumpall --username=authentik -f /var/lib/postgresql/data/bkup_postgresql.out --exclude-database=template*
```

## Create
```
borg create -v --stats \
    $REPOSITORY::authentik_'{now:%Y-%m-%d_%H:%M}' \
    --pattern=+/var/lib/docker/volumes/authentik_database/_data/bkup_postgresql.out \
    --pattern=+/var/lib/docker/volumes/authentik_data/_data \
    --pattern=+/var/lib/docker/volumes/authentik_certs/_data \
    --pattern=+/var/lib/docker/volumes/authentik_custom-templates/_data \
    --pattern=+/var/lib/docker/volumes/authentik_blueprints/_data \
```

## Post-run script
```
rm -rf /var/lib/docker/volumes/authentik_database/_data/bkup_postgresql.out
```
