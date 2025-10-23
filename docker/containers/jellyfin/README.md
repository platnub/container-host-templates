# Requirements
 - [NFS Shares setup](https://github.com/platnub/container-host-templates/blob/main/virtual-machines/open-media-vault/README.md)

# Useful links
 - [Collection of Plugins & Themes](https://github.com/awesome-jellyfin/awesome-jellyfin)
## Plugins
 - [Jellyfin SSO Plugin](https://github.com/9p4/jellyfin-plugin-sso/)
 - [Intro Skipper](https://github.com/intro-skipper/intro-skipper)
## Themes
 - [Finity](https://github.com/prism2001/finity)
 - [Ultrachromic](https://github.com/CTalvio/Ultrachromic)
 - [Zesty](https://forum.jellyfin.org/t-%F0%9F%8D%8B%EF%B8%8F-zestytheme)
# Manuals
## SSO Setup using [Jellyfin Plugin SSO](https://github.com/9p4/jellyfin-plugin-sso/)
1. [Install Jellyfin Plugin SSO](https://github.com/9p4/jellyfin-plugin-sso#installing)
2. Restart Jellyfin
3. Login to Authentik as administrator and open Admin interface
   -  Create Authentik Application with Provider
     - Name: Jellyfin
     - Slug: jellyfin
     - UI settings
       - https://jellyfin.example.com
   - Provider settings
     - Authorization flow: '...implicit-consent'
     - Client type: Confidential
     - Redirect URIs: Strict: https://jellyfin.example.com/sso/OID/redirect/authentik
4. Create link in Jellyfin
   - Open Plugin settings and create OID Provider 
     - Name: authentik
     - OID Endpoint: `https://authentik.example.com/application/o/jellyfin`
     - Client ID & OID Secret From Authentik Provider
     - Enabled: enabled
     - ‼️ Warning: If enabling 'Enable Authorization by Plugin' admin account will lose rights if 'Admin Roles' not configured correctly
     - Admin Roles: 'authentik-admin' ‼️ Make sure same as Authentik admin group
     - Scheme Override: https
 5. Modify login page with Authentik button
   - Dashboard > General
     - Login disclaimer. Make sure top modify the URL!!
       ```
       <form action="https://jellyfin.example.com/sso/OID/start/authentik">
         <button class="raised block emby-button button-submit" style="height: 75px; overflow: hidden; display: flex; align-items: center; justify-content: center;">
           <img src="https://goauthentik.io/img/social.png" style="height: 175px;">
         </button>
       </form>
       ```
     - Custom CSS code
       ```
       a.raised.emby-button {
         padding: 0.9em 1em;
         color: inherit !important;
       }
       
       .disclaimerContainer {
         display: block;
       }
       ```
## Setup Intel QSV
1. Run this command using SSH on the Docker host: Replace `<group render>` in the compose.yml
   ```
   getent group render | cut -d: -f3
   ```
2. Run these commands in the Jellyfin terminal through Komodo: QSV and VA-API codecs? Idk lol
   ```
   /usr/lib/jellyfin-ffmpeg/vainfo
   ```
   Runtime status
   ```
   /usr/lib/jellyfin-ffmpeg/ffmpeg -v verbose -init_hw_device vaapi=va -init_hw_device opencl@va
   ```
3. Enable transcoding in Jellyfin settings
4. Set QSV Device device to '/dev/dri/renderD128'
5. Enabled/disable [supported and unsupported codecs for hardware encoding and decoding](https://www.intel.com/content/www/us/en/docs/onevpl/developer-reference-media-intel-hardware/1-1/overview.html) in the transcoding settings
