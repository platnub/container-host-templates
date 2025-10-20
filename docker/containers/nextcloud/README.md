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
