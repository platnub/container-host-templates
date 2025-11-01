# Useful Information
## Default credentials
`admin/admin`
## Grocy Extensions
- [Grocy OAuth2 Middleware - Github](https://github.com/bboehmke/grocy-oauth)

# Manuals
## Installation
1. Run the following command to create the OAuth2 middleware file
   ```
   mkdir -p /opt/docker/grocy/appdata && cd /opt/docker/grocy/appdata && wget -O OAuthMiddleware.php https://raw.githubusercontent.com/bboehmke/grocy-oauth/refs/heads/master/OAuthMiddleware.php && chown -R komodo:komodo /opt/docker/grocy && chmod -R 700 /opt/docker/grocy && chmod 500 OAuthMiddleware.php
   ```
