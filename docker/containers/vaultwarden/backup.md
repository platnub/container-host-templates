[Vaultwarden backup guide](https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault)

# Borgbackup parameters

## Recommended

- Run every 15 minutes
```
*/15 * * * * /usr/local/bin/vaultwarden.sh > /dev/null 2>&1
```

## Pre-run script
```
docker exec vaultwarden /vaultwarden backup

DIR="/var/lib/docker/volumes/vaultwarden_data/_data"
cd "$DIR" || exit 1

file=$(ls db_*.sqlite3 2>/dev/null | head -n 1)

if [ -n "$file" ]; then
    mv "$file" db_backup.sqlite3
    echo "Renamed $file → db_backup.sqlite3"
else
    echo "No matching db_*.sqlite3 file found."
fiho "No matching db_*.sqlite3 file found."
fi
```

## Create
```
borg create -v --stats \
    $REPOSITORY::vaultwarden_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/vaultwarden_data/_data \
    --exclude '/var/lib/docker/volumes/vaultwarden_data/_data/db.*' \
    --exclude /var/lib/docker/volumes/vaultwarden_data/_data/sends \
    --exclude /var/lib/docker/volumes/vaultwarden_data/_data/tmp
```

## Post-run script
```
rm -rf /var/lib/docker/volumes/vaultwarden_data/_data/db_backup.sqlite3
```
