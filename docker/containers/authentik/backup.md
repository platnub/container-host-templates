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
    /var/lib/docker/volumes/vaultwarden_data/_data \
    --exclude /var/lib/docker/volumes/vaultwarden_data/_data/sends \
    --exclude /var/lib/docker/volumes/vaultwarden_data/_data/tmp
```
