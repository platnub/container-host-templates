> [!IMPORTANT]  
> **Requirements:**
> - Jellyfin
> - [SABnzbd](https://github.com/platnub/container-host-templates/tree/main/docker/containers/sabnzbd)
> - qBittorrent

# Links
 - [Servarr Environment Variables](https://wiki.servarr.com/useful-tools#using-environment-variables-for-config)

# Manuals
## Installing
1. Create stack in Komodo using [compose.yml](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/sonarr/compose.yml) and [.env](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/sonarr/.env)
2. Edit .env and generate a unique secret for each Sonarr instance using `openssl rand -hex 32`
3. Deploy the stack using Komodo
4. Create the media folders in the terminal through Komodo
     - A placeholder is necessary otherwise Sonarr will not recognize an empty media folder.
       ```
       mkdir -p /media/series_en
       mkdir -p /media/series_anime
       mkdir -p /media/series_de
       touch /media/series_en/placeholder
       touch /media/series_anime/placeholder
       touch /media/series_de/placeholder
       ```
5. Open each Sonarr and create a Forms login
6. Set the media folder for each Sonarr instance.
     - Make sure to set the correct folder for each instance
7. Delete all preset Profiles. Only keep the following:
     - EN: `WEB-1080p`
     - Anime: `Remux-1080p - Anime` & `WEB-1080p`
     - DE: `HD Bluray + WEB (GER)`

# Pangolin Resource configuration
## Series EN Sonarr
- Proxy
  - Target
    - Method: 'http'
    - IP / Hostname: `series_en-sonarr`
    - Port: `8989`
- Authentication
  - Use Platform SSO: Enabled
- Rules
  - Priority: `1`
    - Action: 'Always Allow'
    - Match Type: 'Path'
    - Value: `/api/v3/indexer/*`
## Series Anime Sonarr
- Proxy
  - Target
    - Method: 'http'
    - IP / Hostname: `series_en-sonarr`
    - Port: `8990`
- Authentication
  - Use Platform SSO: Enabled
- Rules
  - Priority: `1`
    - Action: 'Always Allow'
    - Match Type: 'Path'
    - Value: `/api/v3/indexer/*`
## Series DE Sonarr
- Proxy
  - Target
    - Method: 'http'
    - IP / Hostname: `series_en-sonarr`
    - Port: `8991`
- Authentication
  - Use Platform SSO: Enabled
- Rules
  - Priority: `1`
    - Action: 'Always Allow'
    - Match Type: 'Path'
    - Value: `/api/v3/indexer/*`
