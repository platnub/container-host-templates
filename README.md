# Info
- Full Proxmox VM-Debian OS installation and configuration scripts
  - Automatic update downloads at 1:00-1:30
  - Automatic upgrade at 1:45-2:15
  - Automatic reboot if upgrade requires it at 2:30
- Komodo Docker container management backend
- Containers running as unprivledged as possible
- Pangolin reverse proxy frontend
  - Geoblocking
  - CrowdSec + CrowdSec Firewall Bouncer
- Authentik SSO system-wide integration including for Pangolin resource authentication & management
- Fully automated media request, download, compression and management system
- Game server hosting using Pelican

# Install a VM
- [Docker](https://github.com/platnub/titan-server/tree/main/virtual-machines)

# Configure VM
- [Docker engine & Komodo mangement](https://github.com/platnub/container-host-templates/blob/main/docker/README.md)

# Containers
## Docker
- <ins>**Core**</ins>
  - [Socket Proxy - Proxy access to docker socket](https://github.com/platnub/titan-server/tree/main/docker/containers/socket-proxy)
  - [Pangolin - Reverse proxy host](https://github.com/platnub/titan-server/tree/main/docker/containers/pangolin)
    - [Pangolin Newt - Pangolin VPN tunnel](https://github.com/platnub/titan-server/tree/main/docker/containers/pangolin/newt)
    - Includes CrowdSec - Crowd powered security
- <ins>**Authentication**</ins>
  - [Authentik - Single sign on](https://github.com/platnub/titan-server/tree/main/docker/containers/authentik)
- <ins>**Information**</ins>
  - [Actual - Finance]
  - [Grocy - Recipe and food stock dashboard](https://github.com/platnub/container-host-templates/tree/main/docker/containers/grocy)
  - [Homepage - Service dashboard]
  - [Nextcloud - Cloud storage](https://github.com/platnub/container-host-templates/tree/main/docker/containers/nextcloud)
    - Integrated with Collabora - Cloud office suite
  - [Paperless NGX - Document management system]
  - [Vaultwarden - Password manager](https://github.com/platnub/titan-server/tree/main/docker/containers/vaultwarden)
- <ins>**Media**</ins>
  - [Jellyfin - Netflix-like media streaming](https://github.com/platnub/container-host-templates/tree/main/docker/containers/jellyfin)
  - [Jellyseerr - Media requests](https://github.com/platnub/container-host-templates/tree/main/docker/containers/jellyseerr)
  - [Tdarr - Media transcoding automation](https://github.com/platnub/container-host-templates/tree/main/docker/containers/tdarr)
    - Uses [Tdarr-one-flow](https://github.com/samssausages/Tdarr-One-Flow)
  - [Recyclarr - TRaSH guide sync](https://github.com/platnub/container-host-templates/tree/main/docker/containers/recyclarr)
  - [Radarr - Movie organization and management](https://github.com/platnub/container-host-templates/tree/main/docker/containers/radarr)
    - Unpackerr - Unpack compressed torrent downloads
  - [Sonarr - Series organization and management](https://github.com/platnub/container-host-templates/tree/main/docker/containers/sonarr)
    - Unpackerr - Unpack compressed torrent downloads
  - [Bazarr - Subtitle management]
  - [Lidarr - Music organization and management](https://github.com/platnub/container-host-templates/tree/main/docker/containers/lidarr)
    - Includes Soulseek - Music downloader
  - [Bookshelf - Book organization and management](https://github.com/platnub/container-host-templates/tree/main/docker/containers/bookshelf)
    - [rreading-glasses - Book metadata server]
  - [Kapowarr - Comics and managa organization and management]
  - [Jackett - Indexer proxy](https://github.com/platnub/container-host-templates/tree/main/docker/containers/jackett)
  - [SABnzbd - Usenet download client](https://github.com/platnub/container-host-templates/tree/main/docker/containers/sabnzbd)
  - [qBittorrent - Torrent download client](https://github.com/platnub/container-host-templates/tree/main/docker/containers/qbittorrent)
    - Includes Gluetun - VPN
  - [Cleanuparr - Download cleaner for torrents]
- <ins>**Gaming**</ins>
  - [Pelican Panel - Management Panel for game servers](https://github.com/platnub/container-host-templates/tree/main/docker/containers/pelican)
    - Pelican Node - Game server hosting node
- <ins>**Automation & AI**</ins>
  - [Archon - AI coding command center]
  - [Flowise - AI agent builder]
  - [n8n - Automation workflow platform](https://github.com/platnub/container-host-templates/tree/main/docker/containers/n8n)
  - [OpenWebUI - AI agent dashboard](https://github.com/platnub/container-host-templates/tree/main/docker/containers/openwebui)
  - [SearXNG - Metasearch engine](https://github.com/platnub/container-host-templates/tree/main/docker/containers/searxng)
