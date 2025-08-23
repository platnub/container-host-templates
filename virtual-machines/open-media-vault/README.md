## Useful Links
 - [OMV Extras - Plugin repository](https://wiki.omv-extras.org/)

# Manuals
## Resizing boot disk
https://forum.proxmox.com/threads/how-to-effectively-increase-omv-system-disk-space-in-proxmox-how-to.117339/
## NFS shares for Docker containers
1. Install Plugin "Multiple Device"
2. Create RAID volume
3. Mount file system
4. Create shared folders
   - If creating subfolders, connect to OMV using WinSCP (root user) and create sub folders in the Shared Folder "Absolute Path" 
