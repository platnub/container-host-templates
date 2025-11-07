# Manuals
## Installation

> [!IMPORTANT]
> If no static IP needs to be configured, step 2, 5 & 6 can be skipped and 'SERVER_NAMES' & 'OPENVPN_ENDPOINT_IP' can be removed from the .env file

1. Create stack in Komodo using compose.yml and .env
2. _(Static IP)_ [Generate a config file](https://www.privateinternetaccess.com/account/ovpn-config-generator) using port 1197 and select 'Fixed IP'.
    - Download and open the file
    - Copy the IP address near the top and use it in the .env for 'OPENVPN_ENDPOINT_IP'
3. In the .env file fill in:
    - SERVER_REGIONS
    - OPENVPN_USER
    - OPENVPN_PASSWORD
4. Deploy the stack
5. _(Static IP)_ Check the logs for the newest error for a mismatching certificate. In the example below it's `amsterdam412`.
   ```
   ERROR [vpn] starting port forwarding service: port forwarding for the first time: binding port: Get "https://10.27.128.1:19999/bindPort?payload=&signature=": tls: failed to verify certificate: x509: certificate is valid for amsterdam412, not amsterdam429
   ```
6. _(Static IP)_ Destroy the stack and fill in the environment variable 'SERVER_NAMES' with the server from the previous step.
7. Make sure that qBittorrent is connected using the VPN connection. Check the logs for the external IP or:
    1. Enable 'View > Log'
    2. Top right 'Execution Log'
    3. Check for 'Detected external IP'

## Configure qBittorrent
1. Configure a new admin password through the web interface (Make sure to change the qBittorrent credentials in .env)
   'Options > WebUI > Authentication'
2. Change 'Options > Downloads > Saving Management > Default Save Path' to `/media/downloads/qbittorrent/complete`
   and 'Keep incomplete torrents in' to `/media/downloads/qbittorrent/incomplete`
