# Install

## Docker

> [!NOTE]
> Tested with Proxmox 8.x.x - 9.1.x
> - Default port 22
> - Root user disabled
> - Sudo user username = hostname

1. Run this from Proxmox node shell
   ```
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/platnub/titan-server/refs/heads/main/proxmox/scripts/docker.sh)"
   ```
   1. ...option 1

### Post-install

 - [Docker configuration](https://github.com/platnub/container-host-templates/blob/main/docker/README.md)
