# Manuals
## Installation
1. On the media share host, cd to the media share and use:
   ```
   mkdir books && chown 1000:1000 books && chmod 770 books && mkdir audiobooks && chown 1000:1000 audiobooks && chmod 770 audiobooks
   ```
## Configuration
1. Create authentication credentials
    1. Authentication Method: 'Forms (Login Page)'
    2. Authentication Required: ✔️ Enabled
2. Go to `https://readarr.example.com/settings/development` and change:
    - Metadata Source: `https://api.bookinfo.pro`
3. Go to 'Settings > Media Management'
   - Add Root Folder
       - Path: `/media/books`
       - 
