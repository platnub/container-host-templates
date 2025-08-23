# Manuals
## Jellyseerr Setup

‼️ English and German Jellyseer are seperated

1. Jellyfin Settings
     - Hostname: http://jellyfin:8096
     - External URL: https://jellyfin.example.com
2. Radarr setup
     - Movies EN Radarr
         - Hostname: `movies_en-radarr`
         - Quality Profile: `HD Bluray + WEB`
         - Root Folder: `/media/movies_en`
     - Movies DE Radarr
         - Hostname: `movies_de-radarr`
         - Quality Profile: `HD Bluray + WEB (GER)`
         - Root Folder: `/media/movies_de`
3. Sonarr setup
     - Series EN Sonarr
         - Hostname: `series_en-sonarr`
         - Quality Profile: `HD Bluray + WEB`
         - Root Folder: `/media/series_en`
         - Season Folders: Enabled
     - Series DE Sonarr
         - Hostname: `series_de-sonarr`
         - Quality Profile: `HD Bluray + WEB (GER)`
         - Root Folder: `/media/series_de`
         - Season Folders: Enabled
4. 
## OpenID Setup
1. Open Authentik "Admin Interface"
2. Applications > Applications > Create with Provider
     - Application
         - Name: `Jellyseerr`
         - Slug: `jellyseerr`
         - UI Settings
             - Launch URL: `https://jelly.example.com`
     - Provider
         - Authorization flow: `...implicit-consent`
         - Client type: `Confidential`
         - Redirect URI: `Strict: https://jelly.example.com/login?provider=authentik&callback=true`
3. Login to Jellyseer with admin user
     - Settings > Network
         - Enable Proxy Support
     - Settings > Users
         - Enable OpenID Connect Sign-In > Gear
         - Add OpenID Connect Provider
             - Provider Name: `Authentik`
             - Issuer URL: `https://authentik.example.com/application/o/jellyseerr/`
             - Client ID: From Authentik Provider
             - Client Secret: From Authentik Provider
             - Advanced Settings
                 - Enable Allow New Users
4. Disable Enable Local Sign-In and Enable Jellyfin Sign-In
5. Redeploy Jellyseerr through Komodo
