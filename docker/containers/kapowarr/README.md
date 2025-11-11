# Manuals
## Configuration
1. Create a [Comic Vine](https://comicvine.gamespot.com/) account and get an [API key](https://comicvine.gamespot.com/api/).
2. Go to 'Settings > General'
    1. Comic Vine API Key: _Fill in key from Step 1._
    2. Login Password: _Set to preference_
    3. FlareSolverr Base URL: `http://flaresolverr-kapowarr:8191`
3. On the OMV host in the media share, run this command to create the required folders:
   ```mkdir comics && chown 1000:1000 comics && chmod 770 comics && mkdir -p downloads/kapowarr/temp && chown 1000:1000 -r downloads && chmod -r 770 downloads```
5. Go to 'Settings > Media Management'
    1. Add a Root Folder
        - Path: `/media/comics`
