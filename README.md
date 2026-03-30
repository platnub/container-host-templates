> [!WARNING]
> WORK IN PROGRESS!

# Info
- Full Proxmox VM-Debian OS installation and configuration scripts
  - Automatic update downloads at 1:00-1:30
  - Automatic upgrade at 1:45-2:15
  - Automatic reboot if upgrade requires it at 2:30
- Komodo Docker container management backend
- Containers running as unprivledged as possible
- Full backups of containers using [BorgBackup](https://www.borgbackup.org/)
  - Optimized to only backup necessary folders and files instead of entire VM's
- Pangolin reverse proxy frontend
  - Geoblocking
  - CrowdSec + CrowdSec Firewall Bouncer
- Authentik SSO system-wide integration including for Pangolin resource authentication & management
- Fully automated media request, download, compression and management system
- Game server hosting using Pelican

# Get started

- [Install a Debian Docker container host VM in Proxmox](/virtual-machines)
- [Setup Docker engine & Komodo mangement](/docker/README.md)
- [Configure BorgBackups of each container](/tools/borgbackup/BorgBackup.md)

# Host overview

- DMZ vlan 90
   - dmz-authentik
   - dmz-automation
   - dmz-gaming
   - dmz-information
   - dmz-media
- Services vlan 20
   - media
   - information
   - komodo-core

# Containers
Install containers

## Docker
- <ins>**Core**</ins>
  - [Socket Proxy - Proxy access to docker socket](/docker/containers/socket-proxy)
  - [Pangolin - Reverse proxy host](/docker/containers/pangolin)
    - [Pangolin Newt - Pangolin VPN tunnel](/docker/containers/pangolin/newt)
    - Includes [CrowdSec](https://www.crowdsec.net/) - Crowd powered security
- <ins>**Authentication**</ins>
  - [Authentik - Single sign on](/docker/containers/authentik)
- <ins>**Information**</ins>
  - [Actual - Finance]
  - [Grocy - Recipe and food stock dashboard](/docker/containers/grocy)
  - [Homepage - Service dashboard]
  - [Nextcloud - Cloud storage](/docker/containers/nextcloud)
    - Integrated with Collabora - Cloud office suite
  - [Paperless NGX - Document management system]
  - [Vaultwarden - Password manager](/docker/containers/vaultwarden)
- <ins>**Media**</ins>
  - [Jellyfin - Netflix-like media streaming](/docker/containers/jellyfin)
  - [Jellyseerr - Media requests](/docker/containers/jellyseerr)
  - [Tdarr - Media transcoding automation](/docker/containers/tdarr)
    - Uses [Tdarr-one-flow](https://github.com/samssausages/Tdarr-One-Flow)
  - [Recyclarr - TRaSH guide sync](/docker/containers/recyclarr)
  - [Radarr - Movie organization and management](/docker/containers/radarr)
    - Unpackerr - Unpack compressed torrent downloads
  - [Sonarr - Series organization and management](/docker/containers/sonarr)
    - Unpackerr - Unpack compressed torrent downloads
  - [Bazarr - Subtitle management]
  - [Lidarr - Music organization and management](/docker/containers/lidarr)
    - Includes Soulseek - Music downloader
    - [Beets - Metadata]()
  - [Bookshelf - Book organization and management](/docker/containers/bookshelf)
  - [Kapowarr - Comics and managa organization and management]
  - [Jackett - Indexer proxy](/docker/containers/jackett)
  - [SABnzbd - Usenet download client](/docker/containers/sabnzbd)
  - [qBittorrent - Torrent download client](/docker/containers/qbittorrent)
    - Includes Gluetun - VPN
  - [Cleanuparr - Download cleaner for torrents]
- <ins>**Gaming**</ins>
  - [Pelican Panel - Management Panel for game servers](/docker/containers/pelican)
    - Pelican Node - Game server hosting node
- <ins>**Automation & AI**</ins>
  - [Archon - AI coding command center]
  - [Flowise - AI agent builder]
  - [n8n - Automation workflow platform](/docker/containers/n8n)
  - [OpenWebUI - AI agent dashboard](/docker/containers/openwebui)
  - [SearXNG - Metasearch engine](/docker/containers/searxng)

# Resource Requirements

Resource requirements are based mostly on testing. Many docker containers don't explicitly list the resource requirements. Some containers may require more testing. Everything is functional with the current documented settings.
