---
title: Home
description: 
published: true
date: 2026-04-05T21:19:25.212Z
tags: 
editor: markdown
dateCreated: 2026-04-05T21:01:51.322Z
---

> WORK IN PROGRESS!
{.is-warning}

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

1. [Install a Debian Docker container host VM in Proxmox](/virtual-machines)
2. [Setup Docker engine & Komodo mangement](/docker/README.md)
3. [Configure BorgBackups of each container](/tools/borgbackup/BorgBackup.md)

# Host overview

- External
   - pangolin-core
- DMZ vlan 90
   - dmz-public
   - dmz-gaming
   - dmz-media
   - dmz-frontend
   - dmz-information
   - dmz-authentik
- Services vlan 20
   - media
   - backend
   - komodo-core

# Containers
Install containers

## Docker
- <ins>**Core**</ins>
  - [Socket Proxy - Proxy access to docker socket](/docker/containers/socket-proxy/README.md)
  - [Pangolin - Reverse proxy host](/docker/containers/pangolin/README.md)
    - [Pangolin Newt - Pangolin VPN tunnel](/docker/containers/pangolin/newt/README.md)
    - Includes [CrowdSec](https://www.crowdsec.net/) - Crowd powered security
- <ins>**Authentication**</ins>
  - [Authentik - Single sign on](/docker/containers/authentik/README.md)
- <ins>**Information**</ins>
  - [Actual - Finance]
  - [Grocy - Recipe and food stock dashboard](/docker/containers/grocy/README.md)
  - [Homepage - Service dashboard]
  - [Nextcloud - Cloud storage](/docker/containers/nextcloud/README.md)
    - Integrated with Collabora - Cloud office suite
  - [Paperless NGX - Document management system]
  - [Vaultwarden - Password manager](/docker/containers/vaultwarden/README.md)
- <ins>**Media**</ins>
  - [Jellyfin - Netflix-like media streaming](/docker/containers/jellyfin/README.md)
  - [Seerr - Media requests](/docker/containers/seerr/README.md)
  - [Tdarr - Media transcoding automation](/docker/containers/tdarr/README.md)
    - Uses [Tdarr-one-flow](https://github.com/samssausages/Tdarr-One-Flow)
  - [Recyclarr - TRaSH guide sync](/docker/containers/recyclarr/README.md)
  - [Radarr - Movie organization and management](/docker/containers/radarr/README.md)
    - Unpackerr - Unpack compressed torrent downloads
  - [Sonarr - Series organization and management](/docker/containers/sonarr/README.md)
    - Unpackerr - Unpack compressed torrent downloads
  - [Bazarr - Subtitle management]
  - [Lidarr - Music organization and management](/docker/containers/lidarr/README.md)
    - Includes Soulseek - Music downloader
    - [Beets - Metadata]()
  - [Bookshelf - Book organization and management](/docker/containers/bookshelf/README.md)
  - [Kapowarr - Comics and managa organization and management]
  - [Jackett - Indexer proxy](/docker/containers/jackett/README.md)
  - [SABnzbd - Usenet download client](/docker/containers/sabnzbd/README.md)
  - [qBittorrent - Torrent download client](/docker/containers/qbittorrent/README.md)
    - Includes Gluetun - VPN
  - [Cleanuparr - Download cleaner for torrents]
- <ins>**Gaming**</ins>
  - [Pelican Panel - Management Panel for game servers](/docker/containers/pelican/README.md)
    - Pelican Node - Game server hosting node
- <ins>**Automation & AI**</ins>
  - [Archon - AI coding command center]
  - [Flowise - AI agent builder]
  - [n8n - Automation workflow platform](/docker/containers/n8n/README.md)
  - [OpenWebUI - AI agent dashboard](/docker/containers/openwebui/README.md)
  - [SearXNG - Metasearch engine](/docker/containers/searxng/README.md)

# Resource Requirements

Resource requirements are based mostly on testing. Many docker containers don't explicitly list the resource requirements. Some containers may require more testing. Everything is functional with the current documented settings.
