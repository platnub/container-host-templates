# Links
 - [Servarr Environment Variables](https://wiki.servarr.com/useful-tools#using-environment-variables-for-config)
# Manuals
## Installing
1. Create stack in Komodo using [compose.yml]() and [.env]()
2. Edit .env and generate a unique secret for each Sonarr instance using `openssl rand -hex 32`
3. Deploy the stack using Komodo
4. Create the media folders
     - A placeholder is necessary otherwise Sonarr will not recognize an empty media folder.
       ```
       mkdir -p /media/movies_en
       mkdir -p /media/movies_anime
       mkdir -p /media/movies_de
       touch /media/movies_en/placeholder
       touch /media/movies_anime/placeholder
       touch /media/movies_de/placeholder
       ```
5. Open each Sonarr and create a Forms login
6. Set the media folder for each Sonarr instance.
     - Make sure to set the correct folder for each instance
7. Delete all preset Profiles. Only keep the following:
     - EN: `WEB-1080p`
     - Anime: `Remux-1080p - Anime` & `WEB-1080p`
     - DE: `HD Bluray + WEB (GER)`
