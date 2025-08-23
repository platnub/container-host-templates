# Links
 - [Recyclarr Pre-Built Configuration Files](https://recyclarr.dev/wiki/guide-configs)
 - [Recyclarr templates](https://github.com/recyclarr/config-templates)
 - [TRaSH Guides Radarr Custom Formats](https://trash-guides.info/Radarr/Radarr-collection-of-custom-formats/)
 - [TRaSH Guides Sonarr Custom Formats](https://trash-guides.info/Sonarr/sonarr-collection-of-custom-formats)
# Manuals
## Installation
1. Create stack in Komodo using [compose.yml](https://github.com/platnub/container-host-templates/blob/main/docker/containers/recyclarr/compose.yml) and [.env](https://github.com/platnub/container-host-templates/blob/main/docker/containers/recyclarr/.env)
2. Deploy the stack using Komodo
3. Create the media folders
     - A placeholder is necessary otherwise Radarr will not recognize an empty media folder.
     - Paste [recyclarr.yml](https://github.com/platnub/container-host-templates/blob/main/docker/containers/recyclarr/recyclarr.yml)
       ```
       cd /var/lib/docker/volumes/recyclarr_config/_data
       nano recyclarr.yml
       chown 1000:1000 recyclarr.yml
       ```
5. Open the terminal through Komodo and run `recyclarr sync`
