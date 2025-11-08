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
       mkdir -p downloads/slskd/incomplete && mkdir -p downloads/slskd/complete
       ```
4. Deploy the stack
5. Make sure that qBittorrent is connected using the VPN connection. Check the logs for the external IP or:
    1. Enable 'View > Log'
    2. Top right 'Execution Log'
    3. Check for 'Detected external IP'
## Configuration
1. Install plguin `https://github.com/allquiet-hub/Lidarr.Plugin.Slskd`
2. Generate secret using `openssl rand -hex 32` in a terminal
