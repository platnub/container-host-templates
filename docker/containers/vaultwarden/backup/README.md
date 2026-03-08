[Vaultwarden backup guide](https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault)

# Borgbackup parameters
## Create
```
borg create -v --stats \
    $REPOSITORY::vaultwarden_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/vaultwarden_data/_data \
    --exclude /var/lib/docker/volumes/vaultwarden_data/_data/sends \
    --exclude /var/lib/docker/volumes/vaultwarden_data/_data/tmp
```
