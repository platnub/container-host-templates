# Requirements
 - Pangolin Reverse Proxy
# Links
 - [Pelican & Pterodactyl eggs](https://pelican-eggs.github.io)
# Manuals
## Install
1. Compose and .env called pelican-panel
     - Make sure to modify the subnet correctly!
2. Deploy the container
3. Go to '/opt/docker/pelican-panel', use `docker compose logs panel | grep 'Generated app key:'` and **save the key**!!
4. Navigate to the instance '1.2.3.4/installer' and finish the setup
     - Create admin username same as the Authentik admin username

## Install and connect a node

> [!NOTE]
> Either create a new Virtual Machine for the node, or do it on the same host.

1. Make sure the host is prepare as per [the usual configuration](https://github.com/platnub/container-host-templates/tree/main/virtual-machines) with a Pangolin Site Newt tunnel active
2. Open Pangolin admin panel
    1. Create a new resource
       - Resource Type: 'Raw TCP/UDP Resource'
       - Protocol: 'TCP'
       - Method: http
       - IP / Hostname: LAN IP
       - Port: 8080
       - After creation disable 'Use Platform SSO' under Authentication
3. Open the Pelican admin panel
    1. New Node
       - `pelican-node.example.com` This should be the URL set in the Pangolin resource
       - Communicate over SSL: 'HTTPS with (reverse) proxy'
       - Connection Port: 443
       - Listening Port: 8080
    2. Next Step
    3. Create Node
4. Install the Node on the host
    1. Follow instructions from the [Pelican docs](https://pelican.dev/docs/wings/install)
       ```
       sudo mkdir -p /etc/pelican /var/run/wings
       sudo curl -L -o /usr/local/bin/wings "https://github.com/pelican-dev/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
       sudo chmod u+x /usr/local/bin/wings
       sudo echo -e "[Unit]\nDescription=Wings Daemon\nAfter=docker.service\nRequires=docker.service\nPartOf=docker.service\n\n[Service]\nUser=root\nWorkingDirectory=/etc/pelican\nLimitNOFILE=4096\nPIDFile=/var/run/wings/daemon.pid\nExecStart=/usr/local/bin/wings\nRestart=on-failure\nStartLimitInterval=180\nStartLimitBurst=30\nRestartSec=5s\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/wings.service
       sudo systemctl enable --now wings
       ```
    2. Edit the config file
       ```
       sed -i 's|    IPv6: true|    IPv6: false|g' /etc/pelican/config.yml
       ```
    3. Edit the same config file and modify `remote` to the public URL of the PANEL!!
       ```
       nano /etc/pelican/config.yml
       ```

## Edit Settings

> [!CAUTION]
> As of writing (21-09-2025), 2FA and Captcha can NOT be used at the same time. Choose one.

1. General
     - 2FA Requirement: Required For Admins Only
     - Setup 2FA for admin account
2. Captcha
     - Setup with Cloudflare Turnstile

## Configure Authentik login
1. Create Authentik Application & Provider
    1. Name: `Pelican`
    2. UI Settings > Launch URL: `https://pelican.example.com`
    3. Next > Oauth
    4. Authorization flow: `...implicit-consent`
    5. Redirect URIs: `Strict: https://pelican.example.com/auth/oauth/callback/authentik`
3. Open the Pelican admin panel
    1. Settings > Oauth
    2. Authentik > Enable
         - Auto Create Missing Users?: Enable
         - Auto Link MIssing Users?: Enable
         - Base URL: `https://authentik.alion.host`

## Creating SFTP links

> [!INFORMATION]
> Configure a password in Pelican after signing in with Authentik to be to authenticate when using SFTP

1. Create a Pangolin 'RAW TCP/UDP Resource'
   1. TCP Resource
   2. Configure the public port, private port and IP / Hostname for the resource
   3. Update the Traefik installation on the Pangolin-core server with the given instructions (including the compose file specifying the port `2022:2022/tcp`
   4. Destroy and deploy the stack through Komodo
### **Bonus Step**: Configuring SFTP for the Pelican Node
1. When creating/editing the node go to tab 'Advanced Settings'
   1. Modify the 'SFTP Port' to the appropriate port
   2. Change 'SFTP Alias' to the base URL of the node without subdomain `example.com`
