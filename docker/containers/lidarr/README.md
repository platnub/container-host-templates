# Manuals
## Installation
1. Create stack in Komodo using compose.yml and .env
2. In the .env file fill in:
    - SERVER_REGIONS
    - OPENVPN_USER
    - OPENVPN_PASSWORD
3. Create the media folders in the OMV media share `cd /srv/dev-disk-by-uuid-.../media`
     - A placeholder is necessary otherwise Slskd will not recognize an empty media folder.
       ```
       mkdir -p downloads/slskd/incomplete && mkdir -p downloads/slskd/complete && chown -R 1000:1000 downloads/slskd && chmod -R 770 downloads/slskd
       ```
4. Soulseek doesn't use accounts. Use a random username and password which are likely unused by others. Fill them in for the SLSKD_SLSK_USERNAME and SLSKD_SLSK_PASSWORD
5. If using YouTube download client use the [Firefox extension - Cookies](https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/) or [Chrome extension - Cookies](https://chrome.google.com/webstore/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc), export the cookies.txt file for Current Site. Put the file in '/opt/docker/lidarr/appdata/cookies.txt'. Use this command for the appdata folder permissions `chown komodo:komodo  /opt/docker/lidarr/appdata & chown 1000:1000 /opt/docker/lidarr/appdata/cookies.txt & chmod 770 -R /opt/docker/lidarr/appdata`
6. Deploy the stack
## Configuration
1. Create a login for the WebUI
2. Install plguin `https://github.com/TypNull/Tubifarry/tree/develop`
3. Destroy and deploy the stack again in Komodo
4. Add the following Indexers
    - Slskd
        - URL: `http://gluetun:5030`
        - API Key: _any_
        - Indexer Priority: `10`
    - Private Torrent rackers
        - Indexer Priority: `20`
    - YouTube
        - Cookie Path: `/cookies.txt`
        - Indexer Priority: `30`
        - Download Client: 'YouTube'
5. Add the following Download Clients
    - Skskd
        - URL: `http://gluetun:5030`
        - API Key: _any_
    - YouTube
        - Run command on OMV media share host and cd to media share `mkdir -p downloads/youtube && chown 1000:1000 -R downloads`
        - Download Path: `/media/downloads/youtube`
        - Cookie Path: `/cookies.txt`
        - Use LRCLIB Lyric Provider: ✔️ Enable
        - Save Synced Lyrics: ✔️ Enable
        - ReEncode: 'AAC'
        - FFmpeg Path: `/config/plugins/TypNull/Tubifarry`
        - Max Download Speed: _Configure for connection_
        - Tags: `youtube`
6. 'Settings > Media Management'
    - Root Folder: `/media/music`
    - Profile: 'Any'
    - Metadata Profile: 'Standard'
7. Configure Lidarr following a [basic community guide](https://wiki.servarr.com/lidarr/community-guide)
    1. Edit the naming scheme 'Settings > Media Management' _Show Advanced_
        - Rename Tracks: ✔️ Enable
        - Replace Illegal Characters: ✔️ Enable
        - Standard Track Format: `{Album Title} {(Album Disambiguation)}/{Artist Name}_{Album Title}_{track:00}_{Track Title}`
        - Multi Disc Track Format: `{Album Title} {(Album Disambiguation)}/{Artist Name}_{Album Title}_{medium:00}-{track:00}_{Track Title}`
        - Artist Folder Format: `{Artist Name}`
    2. Import Custom Formats 'Settings > Custom Formats' sourced from: https://wiki.servarr.com/lidarr/community-guide#custom-formats
    3. Edit the 'Any' Profile 'Settings > Profiles'
        - Upgrades Allowed: ✔️ Enable
        - Upgrade Until: Lossless
        - Preferred Groups: `10`
        - CD: `2`
        - Lossless: `1`
        - WEB: `1`
        - Vinyl: `-5`
    4. Edit the 'Standard' Metadata Profile 'Settings > Profiles'. Only enable the following:
        - Album: ✔️ Enable
        - EP: ✔️ Enable
        - Single: ✔️ Enable
        - Studio: ✔️ Enable
        - Soundtrack: ✔️ Enable
        - Remix: ✔️ Enable
        - DJ-mix: ✔️ Enable
        - Compilation: ✔️ Enable
        - Official: ✔️ Enable
    5. 'Settings > Metadata'
        - Tag Audio Files with Metadata: 'Never'
        - Scrub Existing Tags: ❌ Disabled
