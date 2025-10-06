# Info
- Komodo Docker container management backend
- Containers running as unprivledged as possible
- Pangolin reverse proxy frontend
  - Geoblocking
  - CrowdSec + CrowdSec Firewall Bouncer
- Full Proxmox VM-Debian OS installation and configuration scripts
- Authentik SSO system-wide integration including for Pangolin resource authentication & management

# Install a VM
- [Docker](https://github.com/platnub/titan-server/tree/main/virtual-machines)

# Configure VM
- [Docker engine & Komodo mangement](https://github.com/platnub/container-host-templates/blob/main/docker/README.md)

# Install containers
## Docker
- Core
  - [Socket Proxy - Proxy access to docker socket for added security](https://github.com/platnub/titan-server/tree/main/docker/containers/socket-proxy)
  - [Pangolin - Reverse proxy host](https://github.com/platnub/titan-server/tree/main/docker/containers/pangolin)
  - [Newt - Pangolin tunnel](https://github.com/platnub/titan-server/tree/main/docker/containers/pangolin/newt)
- Authentication and Information
  - [Authentik - SSO](https://github.com/platnub/titan-server/tree/main/docker/containers/authentik)
  - [Nextcloud - Cloud storage](https://github.com/platnub/container-host-templates/tree/main/docker/containers/nextcloud)
  - [Vaultwarden - Password manager](https://github.com/platnub/titan-server/tree/main/docker/containers/vaultwarden)
- Media
  - [Jellyfin - Netflix-like media streaming](https://github.com/platnub/container-host-templates/tree/main/docker/containers/jellyfin)
  - [Jellyseerr - Media requests](https://github.com/platnub/container-host-templates/tree/main/docker/containers/jellyseerr)
  - [Recyclarr - TRaSH guide sync](https://github.com/platnub/container-host-templates/tree/main/docker/containers/recyclarr)
  - [Radarr - Movie organization and management](https://github.com/platnub/container-host-templates/tree/main/docker/containers/radarr)
  - [Sonarr - Series organization and management](https://github.com/platnub/container-host-templates/tree/main/docker/containers/sonarr)
  - [Jackett - Indexer proxy]()
  - [qBittorrent - Torrent download client]()
  - [SABnzbd - Usenet download client]()
- Gaming
  - [Pelican - Game server hosting](https://github.com/platnub/container-host-templates/tree/main/docker/containers/pelican)
