[04-09-2025]
## Requirements
 - Komodo core server
 - Domain managed through Cloudflare

## Info
 - Installs and fully configures
   - Fail2ban
   - UFW
   - Docker
   - Komodo Periphery
   - Pangolin
   - Crowdsec
   - Geoblock
 - Creates users
   - pangolin - sudo
   - dockerd - komodo engine user with docker group
 - Disables IPv6


> [!TIP]
> Incase anything goes wrong, example files are in the config folder.

> [!CAUTION]
> You will need to manually add the server to Komodo using the public IP + port after setup.

1. Run script from console/terminal. If using Hetzner some characters won't paste correctly in the console `$ : ( )`
   ```
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/pangolin/install.sh)"
   ```
   
2. Connect to the server through an SSH connection and finish the setup:
   ```
   # Create SSH key
   mkdir -p /home/pangolin/.ssh
   ssh-keygen -t ed25519 -N "" -f /home/pangolin/.ssh/id_ed25519
   cat /home/pangolin/.ssh/id_ed25519.pub >> /home/pangolin/.ssh/authorized_keys
   chown -R pangolin:pangolin /home/pangolin/.ssh
   chmod 700 /home/pangolin/.ssh
   chmod 600 /home/pangolin/.ssh/authorized_keys
   cat /home/pangolin/.ssh/id_ed25519 && rm /home/pangolin/.ssh/id_ed25519 && rm /home/pangolin/.ssh/id_ed25519.pub

   # Edit SSH settings
   sed -i 's/^#*\s*PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
   sed -i 's/^#*\s*UsePAM .*/UsePAM no/' /etc/ssh/sshd_config
   echo '\nChallengeResponseAuthentication no' >> /etc/ssh/sshd_config
   systemctl restart ssh
   ```

3. Run the Pangolin install using instructions from [Pangolin docs](https://docs.digpangolin.com/self-host/quick-install)
   ```
   mkdir /opt/docker/pangolin && cd /opt/docker/pangolin
   curl -fsSL https://static.pangolin.net/get-installer.sh | bash
   sudo ./installer --crowdsec
   ```

   - Installation directory: `/opt/docker/pangolin`
   - Enterprise version: [Optional] Yes
      1. Create an account at: https://app.pangolin.net/
      2. Create an organization
      3. Navigate to 'Organization > Billing & Licenses > Licenses'
      4. Generate a license key. Make sure to check 'Personal use only (free license - no checkout)'
      5. Save the license key
   - PostgreSQL: [Optional] No
   - Base domain: `example.com`
   - Pangolin dashboard domain: `pangolin.example.com`
   - Use any email for Let's Encrypt certificates
   - Allow Gerbil tunneled connections: Yes
   - Enable email functionality: [Optional] No (Accounts managed through Authentik)
   - IPv6 capability: No
   - MaxMind GeoLite2 Country and ASN databases: Yes
   - Install and start containers: No
   - Crowdsec install: Yes
      - Managed: Yes

> [!IMPORTANT]
> Incase anything goes wrong, example files are in the [config folder](config).

4. Move the config location for standardisation and clean up the folder.
   ```
   cd /opt/docker/pangolin
   rm -rf installer
   rm -rf config.tar.gz
   rm -rf docker-compose.yml
   rm -rf docker-compose.yml.backup
   mkdir appdata
   mv config appdata
   chown -R dockerd:dockerd /opt/docker/pangolin
   ```

> [!IMPORTANT]
> The compose.yml is configure for Journalctl according to the manual found at [Pangolin docs -  Community Guide](https://docs.pangolin.net/self-host/community-guides/crowdsec#choose-the-right-logs)

4. Create pangolin-core stack in Komodo using [compose.yml](compose.yml) and [.env](.env)
5. Deploy the stack and check if it starts without issues (destroy it first if it's already running from the installation)
6. Destroy the stack in Komodo
7. Log iptables to Journalctl using
   ```
   sudo iptables -A INPUT -j LOG --log-prefix "iptables: "
   ```
8. Create a Journalctl file for Crowdsec
   ```
   printf 'source: journalctl\njournalctl_filter:\n  - "--directory=/var/log/host/"\nlabels:\n  type: syslog' >> ./appdata/config/crowdsec/acquis.d/journalctl.yaml
   ```
9. Modify Pangolin config so that users cannot create new organizations unless they are administrator [Pangolin docs - Configuration file](https://docs.pangolin.net/self-host/advanced/config-file)
   ```
   # Preserve YAML indentation, only match the full key line
   sed -i -E 's/^([[:space:]]*)disable_user_create_org:[[:space:]]*false$/\1disable_user_create_org: true/' /opt/docker/pangolin/appdata/config/config.yml
   ```

> [!IMPORTANT]
> Replace example.com

10. Configure wildcard certificates using instructions from [Pangolin docs - Wildcard domain](https://docs.pangolin.net/self-host/advanced/wild-card-domains)
    ```
    cd /opt/docker/pangolin
    sed -i '$!N;s/^      httpChallenge:\n        entryPoint: web$/      dnsChallenge:\n        provider: "cloudflare"/;P;D' ./appdata/config/traefik/traefik_config.yml
    ```

11. Get a Cloudflare API token and set it as `CLOUDFLARE_DNS_API_TOKEN` in the .env file.

   **Cloudflare API key requirements:**
    - DNS & Zones/Zone/Read
    - DNS & Zones/DNS/Edit
    - Specify domain or All domains

12. Add these 2 lines to the domain in the Pangolin `./appdata/config/config.yml` file
    ```diff
    domains:
        domain1:
            base_domain: "example.com"
    +       prefer_wildcard_cert: true
    +       cert_resolver: "letsencrypt"

    ```

> [!IMPORTANT]
> Replace example.com

13. Edit the Traefik dynamic_config.yml file for wildcards
    ```
    cd /opt/docker/pangolin
    sed -i '/^      tls:$/{N;s/^      tls:\n        certResolver: letsencrypt$/&\n        domains:\n          - main: "example.com"\n            sans:\n              - "*.example.com"/}' ./appdata/config/traefik/dynamic_config.yml
    ```

14. Deploy the stack and check if it starts without issues
15. Read the Setup Token from the Pangolin container log and go to https://pangolin.example.com/auth/initial-setup
16. Create an admin account and continue by creating an organisation with default settings
17. Add a new site and choose 'Local'. Call it `Pangolin`
18. Add a new public resource for Crowdsec
    - Subdomain: `crowdsec`
    - Site: `Pangolin`
    - Protocol: `http`
    - Address: `crowdsec-manager`
    - Port: `8080`
    - Enable authentication
19. 
20. Go to 'https://crowdsec.example.com' and configure CrowdSec
    1. Add Allowlist and Whitelist
       1. Go to 'Allowlists' in the left menu
       2. Add the public IP address of any connected Pangolin sites.
       3. Go to 'Whitelist' in the left menu
       4. Add the public IP address of any connected Pangolin sites.
    2. Enroll CrowdSec Security Engine
       1. Login at https://crowdsec.net
       2. Top right, next to profile picture: Click the + and choose 'Enroll a Sec.Engine'
       3. Copy the enroll key
       4. In the CrowdSec dashobard, top right: Click the red shield and choose 'Enroll CrowdSec'
       5. Fill in the enroll key
       6. Go back to https://crowdsec.net and 'Accept enroll'
    3. Configure Cloudflare Turnstile key
       1. Go to https://cloudflare.com and login
       2. Go to 'Application security > Turnstile'
       3. Add widget manually
          - Widget name: `CrowdSec`
          - Select the correct hostname
          - Widget Mode: 'Managed'
          - Enable 'Skip future security rule challenges for verified visitors'
          - Pre-clearance level: 'Interactive (high)'
       4. In the left menu go to 'Captcha'
       5. Go to Configure by clicking 'Next'
          - Paste Site key & Secret key from Cloudflare
       6. Save & Continue to Apply
       7. Apply Now
       8. Complete









19.
 - **Recommended** Option 11: Set up custom scenarios

11. Destroy the stack in Komodo

ℹ️ Continue using instructions from [HHF Technology Forum](https://forum.hhf.technology/t/implementing-geoblocking-in-pangolin-stack-with-traefik/490)

⚠️ Optionally check for new version [releases](https://github.com/david-garcia-garcia/traefik-geoblock/releases). This manual uses 1.1.1

12. ```
    cd /opt/docker/pangolin-core/appdata/config/traefik
    
    awk '/^      middlewares:$/ {print; print "        - pangolin-geoblock@file"; next} 1' traefik_config.yml > tmp && mv tmp traefik_config.yml
    awk '/^  plugins:$/ {print; print "    geoblock:"; print "      moduleName: github.com/david-garcia-garcia/traefik-geoblock"; print "      version: v1.1.1"; next} 1' traefik_config.yml > tmp && mv tmp traefik_config.yml
    
    awk '/^  middlewares:$/ {
      print;
      print "    pangolin-geoblock:";
      print "      plugin:";
      print "        geoblock:";
      print "          enabled: true";
      print "          defaultAllow: false";
      print "          databaseFilePath: \"/plugins-storage/IP2LOCATION-LITE-DB1.IPV6.BIN\"";
      print "          allowPrivate: true";
      print "          logBannedRequests: true";
      print "          banIfError: true";
      print "          disallowedStatusCode: 403";
      print "          allowedCountries:";
      print "            - AL # Albania";
      print "          allowedIPBlocks:";
      print "            - 192.168.0.0/16";
      print "            - 10.0.0.0/8";
      print "          bypassHeaders:";
      print "            X-Internal-Request: true";
      print "            X-Skip-Geoblock: 1";
      next
    } 1' dynamic_config.yml > tmp && mv tmp dynamic_config.yml
    ```

‼️ Decide which allowedCountries you want to add from [this list](https://github.com/platnub/titan-server/blob/main/docker/containers/pangolin/geoblock_country_list.yml) or find more [here](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements)

    ```
    nano /opt/docker/pangolin-core/appdata/config/traefik/dynamic_config.yml
    ...

13. Uncomment the following line in the compose.yml file (through Komodo)

    ```
     - .appdata/IP2LOCATION-LITE-DB1.IPV6.BIN:/plugins-storage/IP2LOCATION-LITE-DB1.IPV6.BIN
    ```

14. ```
    cd /opt/docker/pangolin-core/appdata
    wget https://github.com/david-garcia-garcia/traefik-geoblock/raw/refs/heads/master/IP2LOCATION-LITE-DB1.IPV6.BIN
    chown komodo:komodo /opt/docker/pangolin-core/appdata/IP2LOCATION-LITE-DB1.IPV6.BIN
    ```

15. Deploy the stack and check if it starts without issues
16. ```
    curl -s https://install.crowdsec.net | sudo sh
    apt update
    apt install crowdsec-firewall-bouncer-iptables -y
    ```
17. Open the terminal of CrowdSec in Komodo and use the following command. Copy the key
    ```
    cscli bouncers add host-firewall-bouncer-pangolin-service
    ```

‼️ Replace `<REPLACE_API_KEY>` with generated API key
    
18. ```
    awk '{gsub(/127.0.0.1:8080/, "localhost:8080")}1' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml > tmp.yaml && mv tmp.yaml /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
    awk '{gsub(/<API_KEY>/, "<REPLACE_API_KEY>")}1' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml > tmp.yaml && mv tmp.yaml /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
    awk '{gsub(/#  - DOCKER-USER/, "  - DOCKER-USER")}1' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml > tmp.yaml && mv tmp.yaml /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
    systemctl restart crowdsec-firewall-bouncer.service
    sed -i '/^  ipv6:/,/^    enabled:/ s/^    enabled: true/    enabled: false/' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
    ```
19. Destroy and deploy the stack in Komodo
22. Create site and link it to a [Newt container](https://github.com/platnub/container-host-templates/tree/main/docker/containers/pangolin/newt)
23. Connect resources
    <img width="1301" height="107" alt="image" src="https://github.com/user-attachments/assets/e3ced54c-8496-4702-ad27-f76ad1b34243" />
