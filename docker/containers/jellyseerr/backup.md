[Seerr backup and restore guide](https://docs.seerr.dev/using-seerr/backups/)

# Borgbackup parameters

## Recommended

- Run daily at 00:45
```
45 0 * * * /usr/local/bin/jellyfin.sh > /dev/null 2>&1
```

## Pre-run script
```
# Install sqlite3 CLI
apt update && apt install sqlite3 -y

#Creating database backup
sqlite3 /var/lib/docker/volumes/jellyseerr_en-config/_data/db/db.sqlite3 ".backup '/var/lib/docker/volumes/jellyseerr_en-config/_data/db/db.sqlite3.bak'"
chown user:user /var/lib/docker/volumes/jellyseerr_en-config/_data/db/db.sqlite3.bak

sqlite3 /var/lib/docker/volumes/jellyseerr_de-config/_data/db/db.sqlite3 ".backup '/var/lib/docker/volumes/jellyseerr_de-config/_data/db/db.sqlite3.bak'"
chown user:user /var/lib/docker/volumes/jellyseerr_de-config/_data/db/db.sqlite3.bak
```

## Create
```
borg create -v --stats \
    $REPOSITORY::seerr_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/jellyseerr_en-config/_data/db/db.sqlite3.bak \
    /var/lib/docker/volumes/jellyseerr_de-config/_data/db/db.sqlite3.bak \
    /var/lib/docker/volumes/jellyseerr_en-config/_data/settings.json \
    /var/lib/docker/volumes/jellyseerr_de-config/_data/settings.json \
```

## Post-run script
```
rm -rf /var/lib/docker/volumes/jellyseerr_en-config/_data/db/db.sqlite3.bak
rm -rf /var/lib/docker/volumes/jellyseerr_de-config/_data/db/db.sqlite3.bak
```
