# Manuals
## Installation
1. Create stack in Komodo using [compose.yml](https://github.com/platnub/container-host-templates/blob/main/docker/containers/sabnzbd/compose.yml) and [.env](https://github.com/platnub/container-host-templates/blob/main/docker/containers/sabnzbd/.env)
2. Run the following through the Komodo terminal
   ```
   mkdir /media/downloads/sabnzbd/complete -p && mkdir /media/downloads/sabnzbd/incomplete && cd /media/downloads/sabnzbd/complete && mkdir movies_en && mkdir movies_anime && mkdir movies_de && mkdir series_en && mkdir series_anime && mkdir series_de
   ```
3. Run this command on the Docker host
     - Import the scripts from the [TRaSH Guides](https://trash-guides.info/Downloaders/SABnzbd/scripts/)
       ```
       cd /var/lib/docker/volumes/sabnzbd_sabnzbd.scripts/_data && wget https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/sabnzbd/scripts/Clean.py && wget https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/sabnzbd/scripts/replace_for.py && chmod +x Clean.py && chmod +x replace_for.py && chown 1000:1000 Clean.py && chown 1000:1000 replace_for.py
       ```
4. Set scripts folder under Folders
5. Navigate to "Special" in the main menu bar at the top
     - Modify 'host_whitelist' to include `sabnzbd`
6. Configure SABNzbd following the [TRaSH guide](https://trash-guides.info/Downloaders/SABnzbd/Basic-Setup/)
     - Not configuring Tuning will let SABnzbd use ALL the download speed
     - Configure folders
         - `/media/downloads/sabnzbd/incomplete`
         - `/media/downloads/sabnzbd/complete`
     - Configure categories...
     - Switches
         - Pre-queue script: Clean.py
         - Propagation delay: 5 mins
         - Abort jobs that cannot be completed: Enable
         - Smart duplicate detection: Discard
         - Add [unwanted extensions](https://trash-guides.info/Downloaders/SABnzbd/Basic-Setup/#prevent-unwanted-extensions)
         - Action when unwanted extension detected: Fail job (move to History)
         - Download all par2 files: Enable
         - Enable SFV-based checks: Enable
         - Post-Process Only Verified Jobs: Enable
         - Enable recursive unpacking: Enable
         - Ignore any folders inside archives: Enable
         - Ignore Samples: Enable
         - Deobfuscate final filenames: Enable
     - Categories
         - movies_en
             - Script: `replace_for.py`
             - Folder/Path: `movies_en`
         - movies_anime
             - Script: `replace_for.py`
             - Folder/Path: `movies_anime`
         - movies_de
             - Script: `replace_for.py`
             - Folder/Path: `movies_de`
         - series_en
             - Script: `replace_for.py`
             - Folder/Path: `series_en`
         - series_anime
             - Script: `replace_for.py`
             - Folder/Path: `series_anime`
         - series_de
             - Script: `replace_for.py`
             - Folder/Path: `series_de`
