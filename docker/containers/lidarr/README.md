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
5. Deploy the stack
## Configuration
1. Create a login for the WebUI
2. Install plguin `https://github.com/TypNull/Tubifarry/tree/develop`
3. Destroy and deploy the stack again in Komodo
4. Add the following Indexers
    - Slskd
        - URL: `http://gluetun:5030`
        - API Key: _any_
        - Indexer Priority: `10`
    - YouTube
        - Cookie Path: ``
        - Indexer Priority: `20`
5. Add the following Download Clients
    - Skskd
    - URL: `http://gluetun:5030`
    - API Key: _any_
