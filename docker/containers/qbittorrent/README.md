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
1. Configure a new admin password through the web interface (Make sure to change the qBittorrent credentials in .env)<br>
   'Options > WebUI > Authentication'
2. Configure qBittorrent following the [TRaSH guide](https://trash-guides.info/Downloaders/qBittorrent/Basic-Setup/)
    - 'Options > Downloads'
        - Torrent content layout: 'Original'
        - Delete .torrent files afterwards: ✔️ Enabled
        - Pre-allocate disk space for all files: ✔️ Enabled (When not using unRaid)
        - Default Torrent Management Mode: 'Automatic'
        - When Torrent Category changed: 'Relocate torrent'
        - When Default Save Path changed: 'Relocate affected torrents'
        - When Category Save Path changed: 'Relocate affected torrents'
        - Default Save Path: `/media/downloads/qbittorrent/complete`
        - Keep incomplete torrents in: ✔️ Enabled `/media/downloads/qbittorrent/incomplete`
    - 'Options > Connection'
        - Peer connection protocol: 'TCP'
        - Use UPnP / NAT-PMP port forwarding from my router: ❌ Disabled
        - Connection Limits: _Modify to connectivity setup_
    - 'Options > Speed'
        - Global Rate Limits: _Modify to connectivity setup_
        - Alternative Rate Limits: _Modify to connectivity setup_
        - Schedule the use of alternative rate limits: _Modify to preference_
        - Apply rate limit to µTP protocol: ✔️ Enabled
        - Apply rate limit to transport overhead: ❌ Disabled
        - Apply rate limit to peers on LAN: ✔️ Enabled
    - 'Options > BitTorrent'
        - Enable DHT (decentralized network) to find more peers: ✔️ Enabled
        - Enable Peer Exchange (PeX) to find more peers: ✔️ Enabled
        - Enable Local Peer Discovery to find more peers: ✔️ Enabled
        - Encryption mode: 'Allow encryption'
        - Enable anonymous mode: ❌ Disabled
        - Torrent Queueing: ✔️ Enabled
            - _[Suggestion]_ Maximum active downloads: 10
            - _[Suggestion]_ Maximum active uploads: 25
            - _[Suggestion]_ Maximum active torrents: 25
        - Do not count slow torrents in these limits: ✔️ Enabled
            - [Recommeded] Keep defaults
        - Automatically append trackers from URL to new downloads: ❌ Disabled
    - 'Options > WebUI > Security'
        - Enable clickjacking protection: ❌ Disabled
