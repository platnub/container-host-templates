> [!IMPORTANT]  
> <ins>**Requirements**</ins>
> - [SABnzbd](https://github.com/platnub/container-host-templates/tree/main/docker/containers/sabnzbd)
> - qBittorrent
# Links
 - [Servarr Environment Variables](https://wiki.servarr.com/useful-tools#using-environment-variables-for-config)
# Manuals
## Installing
1. Create stack in Komodo using [compose.yml]() and [.env]()
2. Edit .env and generate a unique secret for each Radarr instance using `openssl rand -hex 32`
3. Deploy the stack using Komodo
4. Create the media folders in the terminal through Komodo
     - A placeholder is necessary otherwise Radarr will not recognize an empty media folder.
       ```
       mkdir -p /media/movies_en
       mkdir -p /media/movies_anime
       mkdir -p /media/movies_de
       touch /media/movies_en/placeholder
       touch /media/movies_anime/placeholder
       touch /media/movies_de/placeholder
       ```
5. Open each Radarr and create a Forms login
6. Set the media folder for each Radarr instance under 'Media Management'
     - Make sure to set the correct folder for each instance
7. Add the SABnzbd and qBittorrent download clients
8. Create Dual lanugage......
9. Delete all preset Profiles. Only keep the following:
     - EN: HD Bluray + WEB
     - Anime: Remux-1080p - Anime
     - DE: HD Bluray + WEB (GER)
