# Manuals
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
    6. Download and start containers
    7. Disable port 8080 in the Docker configuration and destroy & deploy the containers
4. Open the terminal of container 'nextcloud-aio-nextcloud' using Komodo
    1. Run `php occ maintenance:repair --include-expensive`
5. Configre Collabora
    1. Go into administrative settings > office
    2. Append the Pangolin public IP to the WOPI allow-list.

## SSO Setup using (preinstalled) [OpenID COnnect user backend](https://apps.nextcloud.com/apps/user_oidc) plguin
1. Login to Authentik as administrator and open 'Admin interface'
    1. /....
2. Open 'Administrator settings' in Nextcloud using admin account
    1. Add a 'Registered Provider'
    2. 
