# Install

## Docker

> [!NOTE]
> - Root user disabled
> - Sudo user username = hostname

1. Run this from Proxmox node shell
   ```
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/platnub/titan-server/refs/heads/main/proxmox/scripts/docker.sh)"
   ```
   1. Random SSH port between 10000 - 65535 by default. Can be modified

### Post-install

 - [Docker configuration](https://github.com/platnub/container-host-templates/blob/main/docker/README.md)
