# Manuals
## Installation
1. ```
   mkdir -p /opt/docker/nextcloud/appdata && chown -R komodo:komodo /opt/docker/nextcloud && cd /opt/docker/nextcloud/appdata
   touch    remoteip.conf
   chown 1000:1000 remoteip.conf
   chmod 400 remoteip.conf
   ```
2. Deploy Nextcloud in Komodo using the [compose.yml](https://github.com/platnub/container-host-templates/blob/main/docker/containers/nextcloud/compose.yml) and [.env](https://github.com/platnub/container-host-templates/blob/main/docker/containers/nextcloud/.env) files.
3. Destroy them container using Komodo.

