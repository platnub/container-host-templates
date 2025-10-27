# Manuals
## Pangolin Resource configuration
- Proxy
  - Target
    - Method: 'http'
    - IP / Hostname: `nextcloud-aio-apache`
    - Port: `11000`
- Authentication
  - Use Platform SSO: Disabled

## Uploading user files
1. If using WinSCP to connect, in the site manager open 'Advanced... > Connection' and disable 'Optimize connection buffer size'
2. Upload the files in the user folder
3. Run the command `php occ files:scan --all` in the terminal of conatiner 'nextcloud-aio-nextcloud' using Komodo

## Installation
1. Setup NFS share
    1. Connect to dmz-information host using SHH
    2. ```
       apt update
       apt install nfs-common
       ```
    3. Replace NFS_HOST with the IP of the NFS host and run `mkdir /nfs/nextcloud_data && chown 1000:1000 /nfs/nextcloud_data && mount <NFS_HOST>:/Nextcloud /nfs/nextcloud_data`
    4. Test the connection by making a file `touch /nfs/nextcloud_data/test` and check if the file exists on the NFS host
    5. `nano /etc/fstab`
    6. Edit NFS_HOST and add this line to '/etc/fstap'
       ```
       <NFS_HOST>:/Nextcloud    /nfs/nextcloud_data   nfs auto,nofail,noatime,noolock,intr,tcp,actimeo=1800 0 0
       ```
2. Deploy Nextcloud in Komodo using the [compose.yml](https://github.com/platnub/container-host-templates/blob/main/docker/containers/nextcloud/compose.yml) and [.env](https://github.com/platnub/container-host-templates/blob/main/docker/containers/nextcloud/.env) files.
    1. Enable port 8080 in the Docker configuration
    2. Connect to https://IP:8080
    3. Save the passphrase and use it to login
    4. Continue setup and submit subdomain
    5. Optional apps:
        1. ClamAV
        2. Collabora
        3. Imaginary
        4. Nextcloud Talk
        5. _Save Settings_
    6. Download and start containers
4. Open the terminal of container 'nextcloud-aio-nextcloud' using Komodo
    1. Run `php occ maintenance:repair --include-expensive`
5. 'Administrator settings > Overview' will show the reverse proxy IP being throttled. Copy this IP and run this command through the terminal of the 'nextcloud-aio-nextcloud' container and replace <LOCAL_IP>
   ```
   php occ config:system:set trusted_proxies 2 --value="<LOCAL_IP>"
   ```
6. Restart the Nextcloud containers through the AIO management panel
7. Disable port 8080 in the Docker configuration and destroy & deploy the nextcloud container through Komodo

## SSO Setup using (preinstalled) [OpenID COnnect user backend](https://apps.nextcloud.com/apps/user_oidc) plugin
1. Follow the instructions from [Authentik - Nextcloud integration](https://integrations.goauthentik.io/chat-communication-collaboration/nextcloud)
    1. Login to Authentik as administrator and open 'Admin interface'
        1. Create Property mapping under 'Customization > Property mappings'
            1. Type: 'Scope mapping'
            2. Name: `Nextcloud Profile`
            3. Scope name: `nextcloud`
            4. Expression:
               ```
               # Extract all groups the user is a member of
               groups = [group.name for group in user.ak_groups.all()]
               
               # In Nextcloud, administrators must be members of a fixed group called "admin".
               
               # If a user is an admin in authentik, ensure that "admin" is appended to their group list.
               if user.is_superuser and "admin" not in groups:
                   groups.append("admin")
               
               return {
                   "name": request.user.name,
                   "groups": groups,
                   # Set a quota by using the "nextcloud_quota" property in the user's attributes
                   "quota": user.group_attributes().get("nextcloud_quota", None),
                   # To connect an existing Nextcloud user, set "nextcloud_user_id" to the Nextcloud username.
                   "user_id": user.attributes.get("nextcloud_user_id", str(user.uuid)),
               }
               ```
        2. Create Application with Provider
            1. Application
                1. Name: `Nextcloud`
                2. Slug: `nextcloud`
                3. UI Settings > Launch URL: `https://nc.example.com`
            2. Provider
                1. Type: 'OAuth2/OpenID Provider'
                2. Authorization flow: '...implicit-consent'
                3. Client type: Confidential
                4. Redirect URIs: Strict: `https://nc.example.com/apps/user_oidc/code`
                5. 'Advanced protocol settings > Available Scopes' select 'Nextcloud profile'
                6. 'Advanced protocol settings > Subject mode' select 'Based on the user's UUID'
    2. Open 'Administrator settings' in Nextcloud using admin account and go to 'OpenID Connect'
        1. Add a 'Registered Provider'
            1. Indentifier: `Authentik`
            2. Client ID: ...
            3. Client secret: ...
            4. Discovery endpoint: `https://authentik.example.com/application/o/nextcloud/.well-known/openid-configuration`
            5. Scope: `email profile nextcloud openid`
            6. Attribute mapping
                1. User ID: `preferred_username`
                2. Groups: `groups`
                3. Display name: `name`
                4. Email: `email`
            7. Disable 'Use unique user ID'
            8. Enable 'Use group provisioning'
            9. Group whitelist regex: `^admin$`
    3. Disable default Nextcloud login. Open terminal of container 'nextcloud-aio-nextcloud' using Komodo and run `php occ config:app:set --value=0 user_oidc allow_multiple_user_backends`

## Optional setup
1. Delete infected files using ClamAV
    1. Open 'Administrative settings > Security'
    2. Under "Antivirus for Files' set 'When infected files are found during a background scan' to 'Delete file'
